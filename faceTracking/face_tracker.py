"""
Face Tracker - Sprint 2
Handles webcam access, OpenCV integration, face tracking, and WebSocket server.
Uses the new MediaPipe FaceLandmarker API (v0.10.30+).

Sends face data to Godot over WebSocket on ws://localhost:5555.
Data format: JSON string per message, e.g.:
  {"head_tilt": -3.2, "mouth_open": true, "face_detected": true}

First time setup:
  python3 -m venv venv
  source venv/bin/activate
  pip install opencv-python mediapipe websockets
  Then run this script - it will auto-download the model file.

Run: python3 face_tracker.py
"""

import asyncio
import cv2
import json
import logging
import math
import os
import threading
import urllib.request

import mediapipe as mp
import websockets
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

# -----------------------------------------------------------------------------
# Logging configuration
# -----------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("FaceTracker")

# -----------------------------------------------------------------------------
# Networking configuration
# -----------------------------------------------------------------------------
# This script acts as a local data producer for the game:
# - Python computes face signals from webcam frames.
# - Godot connects as a WebSocket client and receives those signals as JSON messages.
# Keeping host/port as constants makes this easy to share across both projects.
HOST = "127.0.0.1"
PORT = 5555

# -----------------------------------------------------------------------------
# Model location and download source
# -----------------------------------------------------------------------------
# MediaPipe FaceLandmarker needs a .task model file on disk.
# We keep the model next to this script so it works from any working directory,
# and download it once if it's not already present.
MODEL_PATH = os.path.join(os.path.dirname(__file__), "face_landmarker.task")
MODEL_URL = "https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task"


def download_model():
    """Download the face landmarker model if it doesn't exist."""
    # Startup dependency check:
    # this prevents runtime failure later when creating the landmarker.
    # If the file exists, this is a fast no-op.
    if not os.path.exists(MODEL_PATH):
        logger.info("Downloading face landmarker model (first time only)...")
        urllib.request.urlretrieve(MODEL_URL, MODEL_PATH)
        logger.info("Model downloaded.")


class FaceTrackServer:
    """WebSocket server that manages connected Godot clients."""

    def __init__(self):
        # Client state + lock:
        # The main loop sends data while the WebSocket handler may add/remove clients.
        # A lock keeps this shared set safe across threads.
        self.clients: set[websockets.WebSocketServerProtocol] = set()
        self.lock = threading.Lock()
        self.running = True

        # Asyncio event loop running in a background thread:
        # WebSocket server needs an event loop, but the main thread is busy
        # with OpenCV frame processing, so we spin up a dedicated loop.
        self._loop = asyncio.new_event_loop()
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()

        logger.info(f"WebSocket server starting on ws://{HOST}:{PORT}")
        logger.info("Waiting for Godot to connect...")

    def _run_loop(self):
        """Run the asyncio event loop in a background thread."""
        asyncio.set_event_loop(self._loop)
        self._loop.run_until_complete(self._serve())

    async def _serve(self):
        """Start the WebSocket server and run until shutdown."""
        async with websockets.serve(
            self._handler, HOST, PORT,
            ping_interval=20, ping_timeout=20,
        ) as ws_server:
            logger.info(f"WebSocket server is listening on ws://{HOST}:{PORT}")
            # Keep the server running until `self.running` is cleared.
            while self.running:
                await asyncio.sleep(0.1)
        logger.info("WebSocket server shut down.")

    async def _handler(self, websocket: websockets.WebSocketServerProtocol):
        """Handle a single WebSocket client connection."""
        remote = websocket.remote_address
        logger.info(f"Godot connected via WebSocket from {remote}")

        with self.lock:
            self.clients.add(websocket)

        try:
            # Keep the connection open; we only send data, but awaiting
            # recv detects disconnects cleanly.
            async for _ in websocket:
                pass  # Ignore any messages from the client
        except websockets.ConnectionClosed as e:
            logger.info(f"Godot client {remote} disconnected (code={e.code}, reason={e.reason!r})")
        finally:
            with self.lock:
                self.clients.discard(websocket)
            logger.info(f"Godot client {remote} removed from active connections.")

    def send(self, data_dict):
        """Send JSON data to all connected WebSocket clients."""
        message = json.dumps(data_dict)
        with self.lock:
            clients_snapshot = list(self.clients)

        for client in clients_snapshot:
            try:
                asyncio.run_coroutine_threadsafe(
                    client.send(message), self._loop
                )
            except Exception:
                # Client will be cleaned up by the handler when it detects disconnect.
                pass

    def close(self):
        """Graceful shutdown of all networking resources."""
        logger.info("Shutting down WebSocket server...")
        self.running = False

        # Close all active client connections
        with self.lock:
            for client in self.clients:
                asyncio.run_coroutine_threadsafe(
                    client.close(), self._loop
                )

        # Give the event loop a moment to complete cleanup, then stop it
        self._loop.call_soon_threadsafe(self._loop.stop)
        self._thread.join(timeout=2)
        logger.info("WebSocket server closed.")


def main():
    # -------------------------------------------------------------------------
    # 1) Startup dependency preparation
    # -------------------------------------------------------------------------
    # Ensures the FaceLandmarker model exists before opening camera/server.
    download_model()

    # -------------------------------------------------------------------------
    # 2) Camera initialization
    # -------------------------------------------------------------------------
    # Opens default webcam index 0. If unavailable, we stop early because
    # the rest of the pipeline depends on incoming frames.
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        logger.error("Could not access camera.")
        logger.error("Check: System Settings > Privacy & Security > Camera")
        return

    # -------------------------------------------------------------------------
    # 3) Networking initialization
    # -------------------------------------------------------------------------
    # Start local WebSocket server so Godot can subscribe to tracking data.
    server = FaceTrackServer()

    # -------------------------------------------------------------------------
    # 4) MediaPipe model/runtime setup
    # -------------------------------------------------------------------------
    # Running mode VIDEO expects monotonically increasing timestamps and enables
    # efficient tracking behavior between frames.
    base_options = python.BaseOptions(model_asset_path=MODEL_PATH)
    options = vision.FaceLandmarkerOptions(
        base_options=base_options,
        running_mode=vision.RunningMode.VIDEO,
        num_faces=1,
        min_face_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    landmarker = vision.FaceLandmarker.create_from_options(options)

    logger.info("Face tracker running. Press 'q' to quit.")

    frame_timestamp_ms = 0

    # -------------------------------------------------------------------------
    # 5) Main processing loop (runs once per camera frame)
    # -------------------------------------------------------------------------
    while cap.isOpened():
        # Read latest frame from webcam stream.
        ret, frame = cap.read()
        if not ret:
            logger.warning("Failed to read from camera.")
            break

        # Mirror for user-friendly preview (like looking in a mirror).
        frame = cv2.flip(frame, 1)

        # Convert OpenCV BGR frame to RGB and wrap in MediaPipe image container.
        # MediaPipe expects SRGB ordering for vision tasks.
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)

        # Run face landmark detection/tracking for this timestamp.
        # 33 ms step approximates 30 FPS and satisfies VIDEO mode timing.
        frame_timestamp_ms += 33  # ~30fps
        results = landmarker.detect_for_video(mp_image, frame_timestamp_ms)

        # Defaults for "no face" case.
        # These values are always sent so Godot receives stable schema every frame.
        head_tilt = 0.0
        mouth_open = False
        face_detected = False

        if results.face_landmarks:
            face_detected = True
            landmarks = results.face_landmarks[0]

            # -----------------------------------------------------------------
            # Feature extraction: head tilt
            # -----------------------------------------------------------------
            # We use two stable facial landmarks (outer eye corners) and compute
            # the angle of the eye-line relative to horizontal in image space.
            # Positive/negative sign indicates tilt direction.
            left_eye = landmarks[33]
            right_eye = landmarks[263]
            dy = right_eye.y - left_eye.y
            dx = right_eye.x - left_eye.x
            head_tilt = math.degrees(math.atan2(dy, dx))

            # -----------------------------------------------------------------
            # Feature extraction: mouth openness
            # -----------------------------------------------------------------
            # Compare vertical distance between upper/lower lip center landmarks.
            # Threshold converts a continuous distance into a game-friendly boolean.
            upper_lip = landmarks[13]
            lower_lip = landmarks[14]
            mouth_distance = abs(upper_lip.y - lower_lip.y)
            mouth_open = mouth_distance > 0.02

            # Debug HUD overlay for local operator visibility.
            cv2.putText(frame, f"Tilt: {head_tilt:.1f} deg", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame, f"Mouth: {'OPEN' if mouth_open else 'closed'}", (10, 60),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            # Show whether any Godot client is currently connected.
            n_clients = len(server.clients)
            status = f"Godot: {'connected' if n_clients > 0 else 'waiting...'}"
            cv2.putText(frame, status, (10, 90),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7,
                        (0, 255, 0) if n_clients > 0 else (0, 165, 255), 2)

            # Landmark visualization helps verify the chosen points are tracked.
            # Blue = eye points used for tilt.
            h, w, _ = frame.shape
            cv2.circle(frame, (int(left_eye.x * w), int(left_eye.y * h)), 3, (255, 0, 0), -1)
            cv2.circle(frame, (int(right_eye.x * w), int(right_eye.y * h)), 3, (255, 0, 0), -1)
            # Red = lip points used for mouth-open detection.
            cv2.circle(frame, (int(upper_lip.x * w), int(upper_lip.y * h)), 3, (0, 0, 255), -1)
            cv2.circle(frame, (int(lower_lip.x * w), int(lower_lip.y * h)), 3, (0, 0, 255), -1)
        else:
            # Visual feedback when no valid face is present in the frame.
            cv2.putText(frame, "No face detected", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

        # -----------------------------------------------------------------
        # Output: stream current frame's face state to Godot
        # -----------------------------------------------------------------
        # This runs every frame (face or no face), so gameplay code can rely on
        # receiving continuous updates rather than intermittent events.
        server.send({
            "head_tilt": round(head_tilt, 2),
            "mouth_open": mouth_open,
            "face_detected": face_detected
        })

        # Local preview window + quit key handling.
        cv2.imshow("Face Tracker - Sprint 2", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # -------------------------------------------------------------------------
    # 6) Shutdown and resource cleanup
    # -------------------------------------------------------------------------
    # Release camera, close windows, dispose model, and stop server thread/socket.
    cap.release()
    cv2.destroyAllWindows()
    landmarker.close()
    server.close()
    logger.info("Face tracker stopped.")


if __name__ == "__main__":
    main()
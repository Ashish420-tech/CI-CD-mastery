import os
import time
from flask import Flask, jsonify

app = Flask(__name__)

STARTUP_DELAY = int(os.getenv("STARTUP_DELAY", "5"))
started_at = time.monotonic()

@app.get("/health")
def health():
    ready = time.monotonic() - started_at >= STARTUP_DELAY
    if not ready:
        return jsonify(status="starting"), 503
    return jsonify(status="healthy"), 200

@app.get("/")
def root():
    return jsonify(service="dependency", status="ready")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

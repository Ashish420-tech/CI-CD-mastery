import os
import time
import requests
from flask import Flask, jsonify

app = Flask(__name__)

DEPENDENCY_URL = os.getenv("DEPENDENCY_URL", "http://dependency:5000")
MAX_RETRIES = int(os.getenv("MAX_RETRIES", "15"))
RETRY_DELAY = float(os.getenv("RETRY_DELAY", "1"))

def dependency_ready():
    for _ in range(MAX_RETRIES):
        try:
            response = requests.get(
                f"{DEPENDENCY_URL}/health",
                timeout=1
            )
            if response.ok:
                return True
        except requests.RequestException:
            pass
        time.sleep(RETRY_DELAY)
    return False

@app.get("/health")
def health():
    if dependency_ready():
        return jsonify(status="healthy", dependency="ready"), 200
    return jsonify(status="unhealthy", dependency="unavailable"), 503

@app.get("/")
def root():
    if not dependency_ready():
        return jsonify(status="dependency_unavailable"), 503

    return jsonify(
        service="application",
        status="ready",
        dependency="healthy"
    )

@app.get("/dependency")
def dependency():
    ready = dependency_ready()
    return jsonify(dependency_ready=ready), 200 if ready else 503

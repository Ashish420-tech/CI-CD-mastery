import os
import socket
import time

import requests
from flask import Flask, jsonify

app = Flask(__name__)
START_TIME = time.time()

SERVICE_A_URL = os.getenv("SERVICE_A_URL", "http://service-a:5000")
SERVICE_B_URL = os.getenv("SERVICE_B_URL", "http://service-b:5000")


@app.get("/")
def root():
    return jsonify({
        "project": "33",
        "service": "service-discovery-gateway",
        "hostname": socket.gethostname(),
        "status": "ready"
    })


@app.get("/health")
def health():
    return jsonify({"status": "healthy"})


@app.get("/discover")
def discover():
    results = {}

    for name, url in {
        "service-a": SERVICE_A_URL,
        "service-b": SERVICE_B_URL,
    }.items():
        try:
            response = requests.get(f"{url}/health", timeout=2)
            results[name] = {
                "url": url,
                "status": response.status_code,
                "healthy": response.ok,
            }
        except requests.RequestException as exc:
            results[name] = {
                "url": url,
                "healthy": False,
                "error": str(exc),
            }

    return jsonify({
        "gateway": "service-discovery-gateway",
        "services": results
    })


@app.get("/metrics")
def metrics():
    uptime = time.time() - START_TIME
    return (
        "# HELP service_discovery_uptime_seconds Application uptime\n"
        "# TYPE service_discovery_uptime_seconds gauge\n"
        f"service_discovery_uptime_seconds {uptime}\n"
    )

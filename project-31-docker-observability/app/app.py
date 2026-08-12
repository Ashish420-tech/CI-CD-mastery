import os
import time

from flask import Flask, Response, jsonify
from prometheus_client import Counter, Gauge, generate_latest

app = Flask(__name__)

REQUESTS = Counter(
    "application_requests_total",
    "Total application requests",
)

UPTIME = Gauge(
    "application_uptime_seconds",
    "Application uptime in seconds",
)

START_TIME = time.time()


@app.before_request
def count_request():
    REQUESTS.inc()


@app.after_request
def update_metrics(response):
    UPTIME.set(time.time() - START_TIME)
    return response


@app.get("/")
def root():
    return jsonify(
        service="docker-observability",
        status="ready",
        uid=os.getuid(),
    )


@app.get("/health")
def health():
    return jsonify(
        status="healthy",
        uid=os.getuid(),
    )


@app.get("/metrics")
def metrics():
    UPTIME.set(time.time() - START_TIME)
    return Response(
        generate_latest(),
        mimetype="text/plain; version=0.0.4",
    )

import os

from flask import Flask, jsonify
import redis

app = Flask(__name__)


def redis_client():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=int(os.getenv("REDIS_PORT", "6379")),
        socket_connect_timeout=float(os.getenv("REDIS_TIMEOUT", "2")),
        socket_timeout=float(os.getenv("REDIS_TIMEOUT", "2")),
        decode_responses=True,
    )


@app.get("/")
def index():
    return jsonify(
        service="project23-api",
        status="running",
        resilience="enabled",
    )


@app.get("/health")
def health():
    try:
        client = redis_client()
        client.ping()
        return jsonify(status="healthy", redis="healthy"), 200
    except Exception:
        return jsonify(status="unhealthy", redis="unavailable"), 503


@app.get("/ready")
def ready():
    try:
        redis_client().ping()
        return jsonify(status="ready"), 200
    except Exception:
        return jsonify(status="not-ready"), 503


@app.get("/cache")
def cache():
    client = redis_client()
    client.set("project23:resilience", "validated", ex=60)
    return jsonify(
        key="project23:resilience",
        value=client.get("project23:resilience"),
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))

import os
from pathlib import Path

from flask import Flask, jsonify


app = Flask(__name__)

SECRET_PATH = Path("/run/secrets/app_secret")


def read_secret():
    if not SECRET_PATH.exists():
        return None

    return SECRET_PATH.read_text(encoding="utf-8").strip()


@app.get("/")
def index():
    return jsonify(
        service="project-25-secrets",
        status="ok",
    )


@app.get("/health")
def health():
    return jsonify(status="healthy")


@app.get("/secret-status")
def secret_status():
    secret = read_secret()

    return jsonify(
        secret_available=bool(secret),
        secret_length=len(secret) if secret else 0,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

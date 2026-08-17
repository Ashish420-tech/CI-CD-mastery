from flask import Flask, jsonify, request
import os
import uuid
from datetime import datetime, timezone

app = Flask(__name__)

SERVICE_NAME = os.getenv("SERVICE_NAME", "transaction-api")
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "1.0.0")


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
    })


@app.get("/ready")
def ready():
    return jsonify({
        "status": "ready",
        "service": SERVICE_NAME,
    })


@app.post("/transactions")
def create_transaction():
    payload = request.get_json(silent=True) or {}

    transaction_id = str(uuid.uuid4())

    return jsonify({
        "transaction_id": transaction_id,
        "status": "ACCEPTED",
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "transaction": payload,
    }), 202


@app.get("/")
def root():
    return jsonify({
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "purpose": "FinTech transaction ingestion API",
    })


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080,
    )

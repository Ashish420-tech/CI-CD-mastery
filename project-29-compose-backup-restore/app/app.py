import json
import os
import tempfile
from pathlib import Path

from flask import Flask, jsonify, request

app = Flask(__name__)

DATA_DIR = Path(os.getenv("DATA_DIR", "/data"))
DATA_FILE = DATA_DIR / "application.json"


def ensure_data():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    if not DATA_FILE.exists():
        write_data(
            {
                "application": "backup-restore",
                "version": 1,
                "records": [],
            }
        )


def read_data():
    ensure_data()
    return json.loads(DATA_FILE.read_text())


def write_data(data):
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    fd, temp_name = tempfile.mkstemp(
        dir=DATA_DIR,
        prefix=".application-",
        suffix=".tmp",
    )

    try:
        with os.fdopen(fd, "w") as handle:
            json.dump(data, handle, indent=2)
            handle.write("\n")

        os.replace(temp_name, DATA_FILE)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)


@app.get("/health")
def health():
    try:
        ensure_data()
        return jsonify(status="healthy"), 200
    except OSError:
        return jsonify(status="unhealthy"), 503


@app.get("/")
def root():
    return jsonify(
        service="backup-restore-app",
        status="ready",
    )


@app.get("/data")
def get_data():
    return jsonify(read_data())


@app.post("/data")
def add_data():
    payload = request.get_json(silent=True)

    if not isinstance(payload, dict):
        return jsonify(error="JSON object required"), 400

    data = read_data()
    data["records"].append(payload)
    write_data(data)

    return jsonify(data=payload), 201


@app.delete("/data")
def delete_data():
    write_data(
        {
            "application": "backup-restore",
            "version": 1,
            "records": [],
        }
    )

    return jsonify(status="cleared"), 200

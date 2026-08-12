import os

from flask import Flask, jsonify

app = Flask(__name__)


def get_config():
    return {
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "message": os.getenv("APP_MESSAGE", "Hello from Project 15")
    }


@app.route("/")
def home():
    config = get_config()

    return jsonify({
        "project": "project-15-container-secrets-config",
        "message": config["message"],
        "version": config["version"],
        "environment": config["environment"]
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


@app.route("/config")
def config():
    current = get_config()

    return jsonify({
        "version": current["version"],
        "environment": current["environment"]
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

import logging
import os
import sys

from flask import Flask, jsonify

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)

logger = logging.getLogger("project-16")

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")


@app.route("/")
def home():
    logger.info(
        "request_received endpoint=/ environment=%s version=%s",
        ENVIRONMENT,
        APP_VERSION
    )

    return jsonify({
        "project": "project-16-container-logging",
        "version": APP_VERSION,
        "environment": ENVIRONMENT
    })


@app.route("/health")
def health():
    logger.info("healthcheck endpoint=/health")

    return jsonify({
        "status": "healthy"
    })


@app.route("/error")
def error():
    logger.error("simulated_application_error")

    return jsonify({
        "status": "error",
        "message": "simulated error"
    }), 500


if __name__ == "__main__":
    logger.info(
        "application_starting version=%s environment=%s",
        APP_VERSION,
        ENVIRONMENT
    )

    app.run(host="0.0.0.0", port=5000)

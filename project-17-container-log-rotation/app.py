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

logger = logging.getLogger("project-17")

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
        "project": "project-17-container-log-rotation",
        "version": APP_VERSION,
        "environment": ENVIRONMENT
    })


@app.route("/health")
def health():
    logger.info("healthcheck endpoint=/health")

    return jsonify({
        "status": "healthy"
    })


@app.route("/log")
def generate_log():
    message = os.getenv(
        "LOG_MESSAGE",
        "project-17 log rotation test"
    )

    logger.info("generated_log message=%s", message)

    return jsonify({
        "status": "logged",
        "message": message
    })


if __name__ == "__main__":
    logger.info(
        "application_starting version=%s environment=%s",
        APP_VERSION,
        ENVIRONMENT
    )

    app.run(host="0.0.0.0", port=5000)

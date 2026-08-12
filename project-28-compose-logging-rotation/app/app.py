import logging

from flask import Flask, jsonify

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("logging-rotation")


@app.get("/health")
def health():
    logger.info("health check requested")
    return jsonify(status="healthy"), 200


@app.get("/")
def root():
    logger.info("application request served")
    return jsonify(
        service="logging-rotation-app",
        status="ready",
    ), 200


@app.get("/generate-logs")
def generate_logs():
    for index in range(10):
        logger.info("production log event sequence=%s", index)

    return jsonify(events=10), 200

import logging
import os
import sys

from flask import Flask, jsonify
import redis

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)

logger = logging.getLogger("project-18")

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))


def get_redis():
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_connect_timeout=2
    )


@app.route("/")
def home():
    logger.info("request_received endpoint=/")

    return jsonify({
        "project": "project-18-compose-multi-container",
        "version": APP_VERSION,
        "environment": ENVIRONMENT
    })


@app.route("/health")
def health():
    try:
        client = get_redis()
        client.ping()

        logger.info("healthcheck redis=healthy")

        return jsonify({
            "status": "healthy",
            "redis": "healthy"
        }), 200

    except Exception as exc:
        logger.error("healthcheck redis=unhealthy error=%s", exc)

        return jsonify({
            "status": "unhealthy",
            "redis": "unhealthy"
        }), 503


@app.route("/counter")
def counter():
    client = get_redis()

    value = client.incr("project-18-counter")

    logger.info("counter_incremented value=%s", value)

    return jsonify({
        "counter": value
    })


if __name__ == "__main__":
    logger.info(
        "application_starting version=%s environment=%s redis=%s:%s",
        APP_VERSION,
        ENVIRONMENT,
        REDIS_HOST,
        REDIS_PORT
    )

    app.run(host="0.0.0.0", port=5000)

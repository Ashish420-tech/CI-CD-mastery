import logging
import os
import sys

from flask import Flask, jsonify
import redis

app = Flask(__name__)

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("project-19")

APP_NAME = os.getenv("APP_NAME", "project-19")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

FEATURE_COUNTER = (
    os.getenv("FEATURE_COUNTER", "true").lower() == "true"
)


def get_redis():
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_connect_timeout=2,
    )


@app.route("/")
def home():
    logger.info(
        "request_received app=%s version=%s environment=%s",
        APP_NAME,
        APP_VERSION,
        ENVIRONMENT,
    )

    return jsonify(
        {
            "application": APP_NAME,
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
            "log_level": os.getenv("LOG_LEVEL", "INFO"),
            "counter_enabled": FEATURE_COUNTER,
        }
    )


@app.route("/health")
def health():
    try:
        get_redis().ping()

        logger.info("healthcheck redis=healthy")

        return jsonify(
            {
                "status": "healthy",
                "redis": "healthy",
            }
        ), 200

    except Exception as exc:
        logger.error(
            "healthcheck redis=unhealthy error=%s",
            exc,
        )

        return jsonify(
            {
                "status": "unhealthy",
                "redis": "unhealthy",
            }
        ), 503


@app.route("/config")
def config():
    return jsonify(
        {
            "application": APP_NAME,
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
            "log_level": os.getenv("LOG_LEVEL", "INFO"),
            "redis_host": REDIS_HOST,
            "redis_port": REDIS_PORT,
            "counter_enabled": FEATURE_COUNTER,
        }
    )


@app.route("/counter")
def counter():
    if not FEATURE_COUNTER:
        return jsonify(
            {
                "error": "counter feature disabled"
            }
        ), 404

    value = get_redis().incr("project-19-counter")

    logger.info("counter_incremented value=%s", value)

    return jsonify(
        {
            "counter": value
        }
    )


if __name__ == "__main__":
    logger.info(
        "application_starting app=%s version=%s environment=%s",
        APP_NAME,
        APP_VERSION,
        ENVIRONMENT,
    )

    app.run(
        host="0.0.0.0",
        port=5000,
    )

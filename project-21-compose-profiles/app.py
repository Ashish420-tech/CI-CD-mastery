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

logger = logging.getLogger("project-21")

APP_NAME = os.getenv("APP_NAME", "project-21")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

SECRET_FILE = os.getenv(
    "APP_SECRET_FILE",
    "/run/secrets/app_secret",
)


def get_secret():
    try:
        with open(SECRET_FILE, "r", encoding="utf-8") as secret_file:
            return secret_file.read().strip()
    except FileNotFoundError:
        return None


def get_redis():
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_connect_timeout=2,
    )


@app.route("/")
def home():
    return jsonify(
        {
            "application": APP_NAME,
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
        }
    )


@app.route("/health")
def health():
    try:
        get_redis().ping()

        return jsonify(
            {
                "status": "healthy",
                "redis": "healthy",
                "secret_mounted": get_secret() is not None,
            }
        ), 200

    except Exception as exc:
        logger.error("healthcheck_failed error=%s", exc)

        return jsonify(
            {
                "status": "unhealthy",
                "redis": "unhealthy",
            }
        ), 503


@app.route("/secret-status")
def secret_status():
    secret = get_secret()

    return jsonify(
        {
            "secret_mounted": secret is not None,
            "secret_length": len(secret) if secret else 0,
        }
    )


@app.route("/counter")
def counter():
    value = get_redis().incr("project-20-counter")

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

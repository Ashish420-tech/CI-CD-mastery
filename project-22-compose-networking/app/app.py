import os

from flask import Flask, jsonify
import redis
from redis.exceptions import RedisError


def create_app():
    app = Flask(__name__)

    redis_host = os.getenv("REDIS_HOST", "redis")
    redis_port = int(os.getenv("REDIS_PORT", "6379"))
    redis_timeout = float(os.getenv("REDIS_TIMEOUT", "2"))

    client = redis.Redis(
        host=redis_host,
        port=redis_port,
        socket_connect_timeout=redis_timeout,
        socket_timeout=redis_timeout,
        decode_responses=True,
    )

    @app.get("/")
    def index():
        return jsonify(
            {
                "service": "project-22-compose-networking-api",
                "status": "running",
                "redis_host": redis_host,
                "redis_port": redis_port,
            }
        )

    @app.get("/health")
    def health():
        try:
            client.ping()
            return jsonify(
                {
                    "status": "healthy",
                    "redis": "healthy",
                }
            ), 200
        except RedisError:
            return jsonify(
                {
                    "status": "unhealthy",
                    "redis": "unhealthy",
                }
            ), 503

    @app.get("/api/network")
    def network():
        try:
            client.set("project22:network-test", "compose-dns-ok", ex=300)
            value = client.get("project22:network-test")

            return jsonify(
                {
                    "api": "reachable",
                    "redis": "reachable",
                    "redis_hostname": redis_host,
                    "redis_value": value,
                    "networking": "service-discovery-success",
                }
            ), 200

        except RedisError as exc:
            return jsonify(
                {
                    "api": "reachable",
                    "redis": "unreachable",
                    "error": str(exc),
                }
            ), 503

    return app


app = create_app()


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", "5000")),
    )

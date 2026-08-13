import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def root():
    return jsonify(
        service="service-a",
        hostname=socket.gethostname(),
        version=os.getenv("SERVICE_VERSION", "1.0.0"),
        status="healthy",
    )


@app.get("/health")
def health():
    return jsonify(status="healthy", service="service-a")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

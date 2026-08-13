from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.get("/")
def root():
    return jsonify(
        application="project-36-helm-app",
        version=os.getenv("APP_VERSION", "1.0.0"),
        environment=os.getenv("APP_ENVIRONMENT", "production"),
        deployment="helm",
    )


@app.get("/health")
def health():
    return jsonify(status="healthy")


@app.get("/ready")
def ready():
    return jsonify(status="ready")


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", "5000")),
    )

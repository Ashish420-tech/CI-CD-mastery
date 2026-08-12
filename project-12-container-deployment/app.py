import os
from flask import Flask, jsonify

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

app = Flask(__name__)


@app.get("/")
def home():
    return jsonify(
        application="ci-cd-mastery-project-12",
        version=APP_VERSION,
        environment=ENVIRONMENT,
        status="running",
    )


@app.get("/health")
def health():
    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

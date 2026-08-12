import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(
        status="healthy",
        uid=os.getuid(),
    ), 200


@app.get("/")
def root():
    return jsonify(
        service="production-hardening",
        status="ready",
        uid=os.getuid(),
    ), 200


@app.get("/runtime")
def runtime():
    return jsonify(
        uid=os.getuid(),
        gid=os.getgid(),
        tmp_writable=os.access("/tmp", os.W_OK),
        app_readable=os.access("/app/app.py", os.R_OK),
    ), 200

from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify(status="healthy"), 200

@app.get("/")
def root():
    return jsonify(service="resource-governed-app", status="ready"), 200

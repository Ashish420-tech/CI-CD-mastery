import os

from app import app


def test_home():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200


def test_health():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_runtime_configuration(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "2.0.0")
    monkeypatch.setenv("ENVIRONMENT", "production")

    client = app.test_client()

    response = client.get("/config")

    data = response.get_json()

    assert data["version"] == "2.0.0"
    assert data["environment"] == "production"

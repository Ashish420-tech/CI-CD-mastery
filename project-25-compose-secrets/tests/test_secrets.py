from pathlib import Path

from app.app import app


def test_health():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_root():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "service": "project-25-secrets",
        "status": "ok",
    }


def test_secret_path_is_runtime_path():
    assert Path("/run/secrets/app_secret").as_posix() == "/run/secrets/app_secret"


def test_secret_status_without_secret():
    client = app.test_client()

    response = client.get("/secret-status")

    assert response.status_code == 200

    payload = response.get_json()

    assert payload["secret_available"] is False
    assert payload["secret_length"] == 0

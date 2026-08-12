from unittest.mock import MagicMock, patch

from app import app


def test_home():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json()["project"] == "project-18-compose-multi-container"


@patch("app.get_redis")
def test_health(mock_redis):
    mock_client = MagicMock()
    mock_client.ping.return_value = True
    mock_redis.return_value = mock_client

    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json()["redis"] == "healthy"


@patch("app.get_redis")
def test_counter(mock_redis):
    mock_client = MagicMock()
    mock_client.incr.return_value = 1
    mock_redis.return_value = mock_client

    client = app.test_client()

    response = client.get("/counter")

    assert response.status_code == 200
    assert response.get_json()["counter"] == 1

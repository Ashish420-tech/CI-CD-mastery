from unittest.mock import MagicMock, mock_open, patch

from app import app


def test_home():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200

    body = response.get_json()

    assert body["application"] == "project-20"


@patch("app.get_redis")
def test_health(mock_redis):
    mock_client = MagicMock()
    mock_client.ping.return_value = True
    mock_redis.return_value = mock_client

    client = app.test_client()

    with patch(
        "builtins.open",
        mock_open(read_data="test-secret"),
    ):
        response = client.get("/health")

    assert response.status_code == 200

    body = response.get_json()

    assert body["status"] == "healthy"
    assert body["redis"] == "healthy"
    assert body["secret_mounted"] is True


@patch("builtins.open", mock_open(read_data="test-secret"))
def test_secret_status():
    client = app.test_client()

    response = client.get("/secret-status")

    assert response.status_code == 200

    body = response.get_json()

    assert body["secret_mounted"] is True
    assert body["secret_length"] == 11


@patch("app.get_redis")
def test_counter(mock_redis):
    mock_client = MagicMock()
    mock_client.incr.return_value = 1
    mock_redis.return_value = mock_client

    client = app.test_client()

    response = client.get("/counter")

    assert response.status_code == 200
    assert response.get_json()["counter"] == 1

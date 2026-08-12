from app.app import app


def test_index():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json()["service"] == "project23-api"


def test_health_without_redis():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code in (200, 503)


def test_ready_without_redis():
    client = app.test_client()
    response = client.get("/ready")

    assert response.status_code in (200, 503)

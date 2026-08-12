from app.app import app


def test_health_endpoint():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_root_endpoint():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "service": "project-24-observability",
        "status": "ok",
    }


def test_metrics_endpoint():
    client = app.test_client()

    client.get("/health")
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "flask_http_requests_total" in response.text
    assert 'endpoint="/health"' in response.text
    assert 'endpoint="/metrics"' in response.text


def test_metrics_content_type():
    client = app.test_client()

    response = client.get("/metrics")

    assert response.status_code == 200
    assert response.content_type.startswith("text/plain")

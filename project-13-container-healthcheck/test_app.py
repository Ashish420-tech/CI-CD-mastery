from app import app


def test_home():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()

    assert data["application"] == "ci-cd-mastery-project-13"
    assert data["status"] == "running"


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_environment():
    client = app.test_client()
    response = client.get("/")

    assert response.get_json()["environment"] == "development"

import pytest

from app.app import create_app


class FakeRedis:
    def ping(self):
        return True

    def set(self, *args, **kwargs):
        return True

    def get(self, key):
        return "compose-dns-ok"


@pytest.fixture
def client(monkeypatch):
    import app.app as application_module

    monkeypatch.setattr(
        application_module.redis,
        "Redis",
        lambda **kwargs: FakeRedis(),
    )

    application = create_app()
    application.config["TESTING"] = True

    with application.test_client() as test_client:
        yield test_client


def test_root(client):
    response = client.get("/")

    assert response.status_code == 200

    body = response.get_json()

    assert body["service"] == "project-22-compose-networking-api"
    assert body["status"] == "running"


def test_health(client):
    response = client.get("/health")

    assert response.status_code == 200

    body = response.get_json()

    assert body["status"] == "healthy"
    assert body["redis"] == "healthy"


def test_network_endpoint(client):
    response = client.get("/api/network")

    assert response.status_code == 200

    body = response.get_json()

    assert body["api"] == "reachable"
    assert body["redis"] == "reachable"
    assert body["redis_value"] == "compose-dns-ok"
    assert body["networking"] == "service-discovery-success"

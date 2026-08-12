from pathlib import Path

import yaml


COMPOSE_FILE = Path(__file__).parents[1] / "compose.yml"


def load_compose():
    with COMPOSE_FILE.open() as file:
        return yaml.safe_load(file)


def test_required_services_exist():
    compose = load_compose()
    assert set(compose["services"]) == {"api", "redis"}


def test_api_resilience_configuration():
    api = load_compose()["services"]["api"]

    assert api["restart"] == "unless-stopped"
    assert api["init"] is True
    assert api["stop_signal"] == "SIGTERM"
    assert api["stop_grace_period"] == "20s"
    assert "healthcheck" in api
    assert "depends_on" in api


def test_redis_resilience_configuration():
    redis = load_compose()["services"]["redis"]

    assert redis["restart"] == "unless-stopped"
    assert redis["init"] is True
    assert redis["stop_signal"] == "SIGTERM"
    assert redis["stop_grace_period"] == "15s"
    assert "healthcheck" in redis


def test_redis_has_no_host_port():
    redis = load_compose()["services"]["redis"]
    assert "ports" not in redis


def test_security_configuration():
    for service in load_compose()["services"].values():
        assert "security_opt" in service
        assert "no-new-privileges:true" in service["security_opt"]


def test_api_depends_on_healthy_redis():
    api = load_compose()["services"]["api"]
    assert api["depends_on"]["redis"]["condition"] == "service_healthy"

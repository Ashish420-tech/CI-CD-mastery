from pathlib import Path

import yaml

ROOT = Path(__file__).parents[1]


def compose():
    return yaml.safe_load(
        (ROOT / "docker-compose.yml").read_text()
    )


def test_required_services():
    services = compose()["services"]

    assert "app" in services
    assert "prometheus" in services
    assert "cadvisor" in services


def test_prometheus_config():
    config = ROOT / "prometheus" / "prometheus.yml"

    assert config.exists()

    text = config.read_text()

    assert "application" in text
    assert "app:5000" in text
    assert "cadvisor:8080" in text


def test_application_metrics():
    source = (ROOT / "app" / "app.py").read_text()

    assert "prometheus_client" in source
    assert "/metrics" in source
    assert "application_requests_total" in source


def test_non_root():
    dockerfile = (ROOT / "Dockerfile").read_text()

    assert "USER 10001:10001" in dockerfile


def test_healthcheck():
    services = compose()["services"]

    assert "healthcheck" in services["app"]
    assert "healthcheck" in services["prometheus"]


def test_security():
    app = compose()["services"]["app"]

    assert "no-new-privileges:true" in app["security_opt"]

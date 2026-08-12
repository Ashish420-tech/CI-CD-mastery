from pathlib import Path

import yaml

ROOT = Path(__file__).parents[1]


def compose():
    return yaml.safe_load(
        (ROOT / "docker-compose.yml").read_text()
    )


def test_logging_driver():
    service = compose()["services"]["app"]
    assert service["logging"]["driver"] == "json-file"


def test_max_size():
    service = compose()["services"]["app"]
    assert service["logging"]["options"]["max-size"] == "10m"


def test_max_file():
    service = compose()["services"]["app"]
    assert service["logging"]["options"]["max-file"] == "3"


def test_healthcheck():
    service = compose()["services"]["app"]
    assert "healthcheck" in service


def test_non_root():
    dockerfile = (ROOT / "Dockerfile").read_text()
    assert "USER 10001:10001" in dockerfile


def test_application_logging():
    source = (ROOT / "app/app.py").read_text()
    assert "logger.info" in source

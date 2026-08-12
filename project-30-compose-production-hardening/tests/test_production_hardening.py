from pathlib import Path

import yaml

ROOT = Path(__file__).parents[1]


def config():
    return yaml.safe_load(
        (ROOT / "docker-compose.yml").read_text()
    )


def service():
    return config()["services"]["app"]


def test_read_only():
    assert service()["read_only"] is True


def test_tmpfs():
    tmpfs = service()["tmpfs"]
    assert any("/tmp:rw" in item for item in tmpfs)


def test_cap_drop_all():
    assert "ALL" in service()["cap_drop"]


def test_no_new_privileges():
    assert "no-new-privileges:true" in service()["security_opt"]


def test_healthcheck():
    assert "healthcheck" in service()


def test_non_root():
    dockerfile = (ROOT / "Dockerfile").read_text()
    assert "USER 10001:10001" in dockerfile


def test_gunicorn():
    dockerfile = (ROOT / "Dockerfile").read_text()
    assert "gunicorn" in dockerfile


def test_restart_policy():
    assert service()["restart"] == "unless-stopped"


def test_init():
    assert service()["init"] is True


def test_logging_rotation():
    logging = service()["logging"]
    assert logging["driver"] == "json-file"
    assert logging["options"]["max-size"] == "10m"
    assert logging["options"]["max-file"] == "3"

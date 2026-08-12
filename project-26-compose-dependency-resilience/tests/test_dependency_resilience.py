from pathlib import Path
import yaml

ROOT = Path(__file__).parents[1]

def test_compose_dependency_health_condition():
    compose = yaml.safe_load((ROOT / "docker-compose.yml").read_text())
    dependency = compose["services"]["app"]["depends_on"]["dependency"]
    assert dependency["condition"] == "service_healthy"

def test_dependency_healthcheck_exists():
    compose = yaml.safe_load((ROOT / "docker-compose.yml").read_text())
    assert "healthcheck" in compose["services"]["dependency"]

def test_application_healthcheck_exists():
    compose = yaml.safe_load((ROOT / "docker-compose.yml").read_text())
    assert "healthcheck" in compose["services"]["app"]

def test_retry_logic_exists():
    source = (ROOT / "app/app.py").read_text()
    assert "MAX_RETRIES" in source
    assert "RETRY_DELAY" in source
    assert "requests.get" in source

def test_non_root_configuration():
    assert "USER 10001:10001" in (ROOT / "app/Dockerfile").read_text()
    assert "USER 10001:10001" in (ROOT / "dependency/Dockerfile").read_text()

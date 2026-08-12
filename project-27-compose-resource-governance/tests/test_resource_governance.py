from pathlib import Path
import yaml

ROOT = Path(__file__).parents[1]

def compose():
    return yaml.safe_load((ROOT / "docker-compose.yml").read_text())

def test_cpu_limit():
    assert compose()["services"]["app"]["cpus"] == "0.50"

def test_memory_limit():
    assert compose()["services"]["app"]["mem_limit"] == "256m"

def test_memory_reservation():
    assert compose()["services"]["app"]["mem_reservation"] == "64m"

def test_healthcheck():
    assert "healthcheck" in compose()["services"]["app"]

def test_security():
    assert "no-new-privileges:true" in compose()["services"]["app"]["security_opt"]

def test_non_root():
    assert "USER 10001:10001" in (ROOT / "Dockerfile").read_text()

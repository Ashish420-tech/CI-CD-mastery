from pathlib import Path

import yaml

ROOT = Path(__file__).parents[1]


def compose():
    return yaml.safe_load(
        (ROOT / "docker-compose.yml").read_text()
    )


def test_named_persistent_volume():
    config = compose()

    service = config["services"]["app"]

    assert "app-data:/data" in service["volumes"]
    assert "app-data" in config["volumes"]


def test_volume_is_named():
    config = compose()

    assert (
        config["volumes"]["app-data"]["name"]
        == "project-29-backup-restore-data"
    )


def test_healthcheck_exists():
    service = compose()["services"]["app"]

    assert "healthcheck" in service


def test_non_root():
    dockerfile = (ROOT / "Dockerfile").read_text()

    assert "USER 10001:10001" in dockerfile


def test_data_directory():
    source = (ROOT / "app/app.py").read_text()

    assert 'DATA_DIR = Path(os.getenv("DATA_DIR", "/data"))' in source
    assert "application.json" in source


def test_atomic_data_write():
    source = (ROOT / "app/app.py").read_text()

    assert "tempfile.mkstemp" in source
    assert "os.replace" in source

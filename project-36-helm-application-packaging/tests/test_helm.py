from pathlib import Path
import yaml

ROOT = Path(__file__).parents[1]
CHART = ROOT / "chart" / "project-36-app"


def test_chart_exists():
    assert (CHART / "Chart.yaml").exists()
    assert (CHART / "values.yaml").exists()


def test_required_templates_exist():
    templates = CHART / "templates"

    for filename in [
        "deployment.yaml",
        "service.yaml",
        "configmap.yaml",
        "namespace.yaml",
    ]:
        assert (templates / filename).exists()


def test_chart_metadata():
    data = yaml.safe_load((CHART / "Chart.yaml").read_text())

    assert data["apiVersion"] == "v2"
    assert data["name"] == "project-36-app"
    assert data["type"] == "application"


def test_secure_deployment_settings():
    text = (CHART / "templates" / "deployment.yaml").read_text()

    assert "runAsNonRoot: true" in text
    assert "allowPrivilegeEscalation: false" in text
    assert "automountServiceAccountToken: false" in text
    assert "readinessProbe:" in text
    assert "livenessProbe:" in text
    assert "resources:" in text

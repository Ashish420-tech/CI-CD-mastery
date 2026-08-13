from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
K8S = ROOT / "k8s"


def read(name):
    return (K8S / name).read_text()


def test_configmap_contains_expected_configuration():
    text = read("configmap.yml")

    for key in (
        "APP_ENVIRONMENT",
        "SERVICE_A_URL",
        "SERVICE_B_URL",
        "LOG_LEVEL",
    ):
        assert re.search(rf"^\s+{key}:", text, re.MULTILINE)


def test_deployments_consume_configmap_and_secret():
    text = read("services.yml") + read("gateway.yml")

    assert text.count("configMapRef:") >= 3
    assert text.count("secretRef:") >= 3
    assert "name: application-config" in text
    assert "name: application-secrets" in text


def test_secret_values_are_not_committed():
    for path in ROOT.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue

        if path.name == "test_config_secrets.py":
            continue

        try:
            content = path.read_text()
        except UnicodeDecodeError:
            continue

        assert "project34-demo-token" not in content
        assert "project34-demo-password" not in content


def test_workloads_use_secure_container_context():
    for manifest in ("services.yml", "gateway.yml"):
        text = read(manifest)

        assert "runAsNonRoot: true" in text
        assert "runAsUser: 10001" in text
        assert "allowPrivilegeEscalation: false" in text
        assert "drop:" in text
        assert "- ALL" in text

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = ROOT.parent


def test_workflow_exists():
    assert (
        REPO_ROOT / ".github" / "workflows" / "project-35-cicd.yml"
    ).exists()


def test_workflow_uses_oidc():
    text = (
        REPO_ROOT / ".github" / "workflows" / "project-35-cicd.yml"
    ).read_text()

    assert "id-token: write" in text
    assert "configure-aws-credentials" in text
    assert "role-to-assume" in text


def test_no_static_aws_credentials():
    text = (
        REPO_ROOT / ".github" / "workflows" / "project-35-cicd.yml"
    ).read_text()

    assert "AWS_ACCESS_KEY_ID" not in text
    assert "AWS_SECRET_ACCESS_KEY" not in text


def test_secure_deployment():
    text = (ROOT / "k8s" / "deployment.yml").read_text()

    assert "runAsNonRoot: true" in text
    assert "runAsUser: 10001" in text
    assert "allowPrivilegeEscalation: false" in text
    assert "- ALL" in text


def test_health_probes():
    text = (ROOT / "k8s" / "deployment.yml").read_text()

    assert "readinessProbe:" in text
    assert "livenessProbe:" in text

from pathlib import Path

import yaml

ROOT = Path(__file__).parents[1]


def load(name):
    return yaml.safe_load((ROOT / "k8s" / name).read_text())


def test_namespace():
    obj = load("namespace.yml")
    assert obj["kind"] == "Namespace"
    assert obj["metadata"]["name"] == "observability"


def test_deployment():
    obj = load("deployment.yml")

    assert obj["kind"] == "Deployment"
    assert obj["spec"]["replicas"] == 2

    container = obj["spec"]["template"]["spec"]["containers"][0]

    assert container["securityContext"]["allowPrivilegeEscalation"] is False
    assert container["securityContext"]["capabilities"]["drop"] == ["ALL"]

    assert container["resources"]["requests"]["cpu"] == "50m"
    assert container["resources"]["limits"]["memory"] == "256Mi"


def test_health_probes():
    obj = load("deployment.yml")
    container = obj["spec"]["template"]["spec"]["containers"][0]

    assert container["readinessProbe"]["httpGet"]["path"] == "/health"
    assert container["livenessProbe"]["httpGet"]["path"] == "/health"


def test_metrics_annotations():
    obj = load("deployment.yml")
    metadata = obj["spec"]["template"]["metadata"]

    annotations = metadata["annotations"]

    assert annotations["prometheus.io/scrape"] == "true"
    assert annotations["prometheus.io/path"] == "/metrics"
    assert annotations["prometheus.io/port"] == "5000"


def test_non_root():
    obj = load("deployment.yml")
    pod_security = obj["spec"]["template"]["spec"]["securityContext"]

    assert pod_security["runAsNonRoot"] is True
    assert pod_security["runAsUser"] == 10001


def test_service():
    obj = load("service.yml")

    assert obj["kind"] == "Service"
    assert obj["spec"]["type"] == "ClusterIP"
    assert obj["spec"]["ports"][0]["port"] == 5000


def test_rbac():
    documents = list(
        yaml.safe_load_all((ROOT / "k8s" / "rbac.yml").read_text())
    )

    kinds = {x["kind"] for x in documents}

    assert "ServiceAccount" in kinds
    assert "ClusterRole" in kinds
    assert "ClusterRoleBinding" in kinds


def test_prometheus_values():
    values = yaml.safe_load(
        (ROOT / "helm" / "values.yaml").read_text()
    )

    assert values["grafana"]["enabled"] is True
    assert values["prometheus"]["prometheusSpec"]["retention"] == "2d"
    assert values["kubeStateMetrics"]["enabled"] is True
    assert values["nodeExporter"]["enabled"] is True

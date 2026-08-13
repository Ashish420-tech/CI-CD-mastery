from pathlib import Path
import yaml

ROOT = Path(__file__).parents[1]


def docs(path):
    return list(yaml.safe_load_all(path.read_text()))


def test_namespace():
    data = docs(ROOT / "k8s/namespace.yml")[0]
    assert data["kind"] == "Namespace"
    assert data["metadata"]["name"] == "project-33"


def test_services_are_cluster_ip():
    data = docs(ROOT / "k8s/services.yml")
    services = [x for x in data if x["kind"] == "Service"]
    assert len(services) == 2
    assert all(x["spec"]["type"] == "ClusterIP" for x in services)


def test_gateway_uses_kubernetes_dns():
    data = docs(ROOT / "k8s/gateway.yml")
    deployment = data[0]
    env = deployment["spec"]["template"]["spec"]["containers"][0]["env"]
    values = [x["value"] for x in env]
    assert any("svc.cluster.local" in x for x in values)


def test_non_root():
    for path in [
        ROOT / "k8s/services.yml",
        ROOT / "k8s/gateway.yml",
    ]:
        for document in docs(path):
            if document["kind"] == "Deployment":
                security = document["spec"]["template"]["spec"]["containers"][0]["securityContext"]
                assert security["runAsNonRoot"] is True
                assert security["allowPrivilegeEscalation"] is False

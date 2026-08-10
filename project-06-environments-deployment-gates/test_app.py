from app import get_application_info


def test_application_info_contains_version_and_environment():
    info = get_application_info("development")

    assert info["version"] == "1.0.0"
    assert info["environment"] == "development"
    assert "Application Version: 1.0.0" in info["message"]
    assert "Environment: development" in info["message"]

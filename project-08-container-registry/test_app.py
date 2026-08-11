from app import get_application_info


def test_application_name():
    info = get_application_info()

    assert info["application"] == "ci-cd-mastery-project-08"


def test_default_version():
    info = get_application_info()

    assert info["version"] == "1.0.0"


def test_default_environment():
    info = get_application_info()

    assert info["environment"] == "development"

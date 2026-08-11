import os

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")


def get_application_info():
    return {
        "application": "ci-cd-mastery-project-08",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
    }


if __name__ == "__main__":
    info = get_application_info()

    print(
        f"Application: {info['application']} | "
        f"Version: {info['version']} | "
        f"Environment: {info['environment']}"
    )

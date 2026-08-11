APP_VERSION = "1.0.0"
DEFAULT_ENVIRONMENT = "development"


def get_application_info(environment=DEFAULT_ENVIRONMENT):
    return {
        "version": APP_VERSION,
        "environment": environment,
        "message": f"Application Version: {APP_VERSION} | Environment: {environment}",
    }


if __name__ == "__main__":
    info = get_application_info()
    print(info["message"])

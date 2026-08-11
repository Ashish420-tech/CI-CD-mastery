FROM python:3.12-slim

LABEL org.opencontainers.image.title="CI/CD Mastery Project 08"
LABEL org.opencontainers.image.description="Docker image registry and publishing demonstration"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/Ashish420-tech/CI-CD-mastery"

WORKDIR /app

COPY app.py .

ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

CMD ["python", "app.py"]

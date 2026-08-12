FROM python:3.12-slim

LABEL org.opencontainers.image.title="CI/CD Mastery Project 12"
LABEL org.opencontainers.image.description="Container deployment and runtime validation"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/Ashish420-tech/CI-CD-mastery"

WORKDIR /app

RUN pip install --no-cache-dir flask

COPY app.py .

ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

EXPOSE 5000

CMD ["python", "app.py"]

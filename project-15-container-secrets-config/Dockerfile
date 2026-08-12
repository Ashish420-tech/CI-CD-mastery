FROM python:3.12-slim

LABEL org.opencontainers.image.title="CI/CD Mastery Project 15"
LABEL org.opencontainers.image.description="Container runtime configuration and secret handling"
LABEL org.opencontainers.image.version="1.0.0"

WORKDIR /app

RUN pip install --no-cache-dir flask

COPY app.py .

ENV APP_VERSION=1.0.0
ENV ENVIRONMENT=development

EXPOSE 5000

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

CMD ["python", "app.py"]

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir Flask==3.1.1 gunicorn==23.0.0

COPY dependency/app.py .

USER 10001:10001

EXPOSE 5000

HEALTHCHECK --interval=2s --timeout=2s --retries=10 --start-period=1s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=1)" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--graceful-timeout", "5", "app:app"]

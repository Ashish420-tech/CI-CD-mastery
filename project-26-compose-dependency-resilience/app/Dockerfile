FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

RUN pip install --no-cache-dir \
    Flask==3.1.1 \
    gunicorn==23.0.0 \
    requests==2.32.4

COPY app/app.py .

RUN chown -R 10001:10001 /app

USER 10001:10001

EXPOSE 5000

HEALTHCHECK --interval=5s --timeout=3s --retries=10 --start-period=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

STOPSIGNAL SIGTERM

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--graceful-timeout", "5", "app:app"]

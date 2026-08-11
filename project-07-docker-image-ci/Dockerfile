FROM python:3.12-slim

ARG APP_VERSION=1.0.0
ARG VCS_REF=unknown

LABEL org.opencontainers.image.title="project-07-app"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"

WORKDIR /app

COPY app.py .

CMD ["python", "app.py"]

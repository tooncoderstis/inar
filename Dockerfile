# syntax=docker/dockerfile:1
FROM rocker/r-ver:4.5.3

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
ENV PORT=3838
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates openssl libcurl4-openssl-dev libssl-dev libxml2-dev libuv1 \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled --ncpus -1 \
        shiny bslib plotly DT readxl jsonlite digest

WORKDIR /app

COPY . /app

RUN test -f private/paper/paper.enc \
    && echo "encrypted paper present" || echo "WARNING: encrypted paper missing"

RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chmod +x /app/deploy/entrypoint.sh \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 3838

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/" >/dev/null || exit 1

ENTRYPOINT ["/app/deploy/entrypoint.sh"]

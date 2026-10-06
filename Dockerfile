FROM ghcr.io/astral-sh/uv:0.11.23 AS uv

FROM python:3.14-slim

WORKDIR /app

COPY --from=uv /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev \
    && apt-get update \
    && apt-get install -y --no-install-recommends cron \
    && rm -rf /var/lib/apt/lists/*

COPY /src/*.py /app/
COPY docker/lab5.cron /etc/cron.d/lab5-cron
COPY docker/run-extractor.sh /usr/local/bin/run-extractor

RUN chmod 0644 /etc/cron.d/lab5-cron \
    && chmod 0755 /usr/local/bin/run-extractor

ENV PATH="/app/.venv/bin:$PATH"

CMD ["cron", "-f"]
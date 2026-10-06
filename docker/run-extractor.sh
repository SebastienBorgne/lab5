#!/bin/sh
set -eu

cd /app
exec /app/.venv/bin/python -u /app/main.py
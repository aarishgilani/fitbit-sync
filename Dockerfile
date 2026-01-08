# --- Stage 1: Builder ---
FROM ghcr.io/astral-sh/uv:latest AS uv_bin
FROM python:3.13-slim-bookworm AS builder

# Install uv binary
COPY --from=uv_bin /uv /uvx /bin/

WORKDIR /app

# Ensure uv uses the system python (3.13) provided by the base image
ENV UV_PYTHON_PREFERENCE=only-system
ENV UV_COMPILE_BYTECODE=1
ENV UV_PROJECT_ENVIRONMENT=/app/.venv

# Install dependencies only (leverage caching)
COPY uv.lock pyproject.toml ./
RUN uv sync --frozen --no-install-project --no-dev

# --- Stage 2: Final Runtime ---
FROM python:3.13-slim-bookworm

WORKDIR /app

# Copy the venv from builder
COPY --from=builder /app/.venv /app/.venv

# Copy your code
COPY . .

# Set environment paths
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV=/app/.venv
ENV PYTHONUNBUFFERED=1

EXPOSE 8501

# Healthcheck (standard Streamlit path)
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')" || exit 1

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
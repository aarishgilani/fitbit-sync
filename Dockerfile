# --- Stage 1: Builder ---
FROM ghcr.io/astral-sh/uv:latest AS uv_bin
FROM python:3.11-slim-bookworm AS builder

# Install uv from the official image
COPY --from=uv_bin /uv /uvx /bin/

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
# Prevent uv from looking for a project root outside /app
ENV UV_PROJECT_ENVIRONMENT=/app/.venv

# Copy only dependency files first
COPY uv.lock pyproject.toml ./

# Install dependencies
# --frozen: ignores updates to lockfile
# --no-install-project: skip installing the app itself in this step
RUN uv sync --frozen --no-install-project --no-dev

# --- Stage 2: Final ---
FROM python:3.11-slim-bookworm

WORKDIR /app

# Copy the virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy your application code
COPY . .

# Set environment variables
# 1. Add venv to PATH so 'streamlit' command is found
# 2. Force python to look in the venv
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV=/app/.venv
ENV PYTHONUNBUFFERED=1

EXPOSE 8501

# Improved Healthcheck (doesn't require curl to be installed)
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')" || exit 1

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
# Use a lightweight Python image
FROM python:3.11-slim-bookworm AS builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set working directory
WORKDIR /app

# Enable bytecode compilation for faster startup
ENV UV_COMPILE_BYTECODE=1

# Copy only the dependency files first (for better caching)
COPY uv.lock pyproject.toml /app/

# Install dependencies into a virtual environment
# --frozen ensures uv doesn't update the lockfile during build
RUN uv sync --frozen --no-install-project --no-dev

# Final Stage
FROM python:3.11-slim-bookworm

WORKDIR /app

# Copy the virtual environment and the uv binary from the builder
COPY --from=builder /app/.venv /app/.venv
COPY . /app

# Ensure we use the virtual environment's python/packages
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8501

HEALTHCHECK CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')"]

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
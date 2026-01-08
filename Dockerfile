# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Copy your local code into the container
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Streamlit uses port 8501 by default
EXPOSE 8501

# Healthcheck to let Coolify know the app is ready
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
# --- Stage 1: Builder ---
FROM python:3.12-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc g++ default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Stage 2: Runtime ---
FROM python:3.12-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /root/.local /home/streamlit/.local
ENV PATH=/home/streamlit/.local/bin:$PATH

# Create non-root user
RUN useradd -m -u 1000 streamlit
USER streamlit

# Copy app files
COPY --chown=streamlit:streamlit . .

EXPOSE 8501

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Start Streamlit app
CMD ["streamlit", "run", "Home.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true"]

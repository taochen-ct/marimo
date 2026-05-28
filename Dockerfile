# syntax=docker/dockerfile:1.12
FROM python:3.11-slim AS base

LABEL org.opencontainers.image.source="https://github.com/marimo-team/marimo"
LABEL org.opencontainers.image.description="marimo reactive notebook"

# Make `uv` and `uvx` available in the PATH for all target images
COPY --from=ghcr.io/astral-sh/uv:0.10.9 /uv /uvx /bin/

# Create a non-root user
# RUN useradd -m appuser
RUN groupadd -g 301 appuser && \
    useradd -m -u 301 -g 301 appuser

WORKDIR /app

ARG marimo_version=0.23.6
LABEL org.opencontainers.image.version="${marimo_version}"

ENV MARIMO_SKIP_UPDATE_CHECK=1
ENV UV_SYSTEM_PYTHON=1
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    curl \
    git \
    pkg-config \
    cargo \
    rustc \
    unixodbc \
    unixodbc-dev \
    libgomp1 && \
    rm -rf /var/lib/apt/lists/*

RUN uv pip install  --no-cache-dir marimo==${marimo_version} && \
  mkdir -p /app/data && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser $(python -c "import site; print(site.getsitepackages()[0])") && \
  chown -R appuser:appuser /usr/local/

COPY --chown=appuser:appuser marimo/_tutorials tutorials
RUN rm -rf tutorials/__init__.py

ENV PORT=8080
EXPOSE $PORT

ENV HOST=0.0.0.0

STOPSIGNAL SIGTERM

FROM base AS custom
USER appuser
RUN uv pip install --no-cache-dir \
    featuretools \
    evidently \
    numba \
    pyspark \
    jupyterlab \
    requests \
    altair \
    marimo \
    numpy \
    pandas \
    pydantic_ai \
    duckdb \
    python-lsp-server \
    sqlglot \
    ruff \
    pytest \
    scipy \
    scikit-learn \
    statsmodels \
    xgboost \
    lightgbm \
    scorecardpy \
    optbinning \
    toad \
    category_encoders \
    matplotlib \
    plotly \
    pyecharts \
    sqlalchemy \
    pymysql \
    clickhouse-connect \
    redis \
    pyarrow \
    fastparquet \
    polars \
    duckdb \
    fastapi \
    uvicorn \
    pydantic \
    apscheduler \
    celery \
    python-docx \
    docxtpl \
    jinja2 \
    reportlab \
    openai \
    langchain \
    loguru \
    joblib \
    pyodbc \
    seaborn


CMD ["sh", "-c", "exec marimo edit --no-token -p $PORT --host $HOST"]

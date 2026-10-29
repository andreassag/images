# Multi-stage Dockerfile for clinker
# Builds clinker from upstream source into a clean python:3.12-slim runtime

# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel / setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install core scientific dependencies into venv
RUN pip install --no-cache-dir \
    numpy \
    scipy \
    biopython \
    disjoint-set \
    gffutils

# Tool version argument
ARG TOOL_VERSION=0.0.32

# Download and install clinker from official GitHub source tarball or PyPI
RUN set -eux; \
    TAR_URL="https://github.com/gamcil/clinker/archive/refs/tags/v${TOOL_VERSION}.tar.gz"; \
    echo "Downloading clinker v${TOOL_VERSION} from ${TAR_URL}..."; \
    if curl -fsSL -A "Mozilla/5.0" "${TAR_URL}" -o clinker.tar.gz; then \
        mkdir src && tar -xzf clinker.tar.gz -C src --strip-components=1; \
        cd src; \
        pip install --no-cache-dir --no-build-isolation .; \
    else \
        echo "Falling back to pip install clinker==${TOOL_VERSION}..."; \
        pip install --no-cache-dir "clinker==${TOOL_VERSION}"; \
    fi; \
    find /opt/venv -type f -name '*.pyc' -delete; \
    find /opt/venv -type d -name '__pycache__' -exec rm -rf {} +

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /data

ENTRYPOINT ["clinker"]

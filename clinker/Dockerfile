# Multi-stage Dockerfile for clinker
# Builds clinker from upstream GitHub source instead of Bioconda

# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel / setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install common dependencies into venv
RUN pip install --no-cache-dir \
    numpy \
    scipy \
    disjoint-set \
    gffutils

# Tool version argument
ARG TOOL_VERSION=0.0.32

# Download and install clinker from official GitHub source tarball
# Handle BioPython compatibility boundary: clinker < 0.0.28 requires biopython < 1.80
RUN set -eux; \
    TAR_URL="https://github.com/gamcil/clinker/archive/refs/tags/v${TOOL_VERSION}.tar.gz"; \
    echo "Downloading clinker v${TOOL_VERSION} from ${TAR_URL}..."; \
    curl -fsSL "${TAR_URL}" -o clinker.tar.gz; \
    mkdir src && tar -xzf clinker.tar.gz -C src --strip-components=1; \
    cd src; \
    python -c "import sys; v = '${TOOL_VERSION}'.split('.'); sys.exit(0 if (int(v[0]), int(v[1]), int(v[2])) < (0, 0, 28) else 1)" && { \
        echo "Installing legacy biopython for clinker < 0.0.28..."; \
        pip install --no-cache-dir "biopython<1.80"; \
    } || { \
        echo "Installing modern biopython for clinker >= 0.0.28..."; \
        pip install --no-cache-dir biopython; \
    }; \
    pip install --no-cache-dir .; \
    find /opt/venv -type f -name '*.pyc' -delete; \
    find /opt/venv -type d -name '__pycache__' -exec rm -rf {} +

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /data

ENTRYPOINT ["clinker"]

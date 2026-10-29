# Multi-stage Dockerfile for defense-finder
# Compiles HMMER 3.4 from source and installs defense-finder from GitHub source tarball / PyPI

# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Compile HMMER 3.4 from upstream source
ARG HMMER_VERSION=3.4
RUN set -eux; \
    if ! curl -fsSL -A "Mozilla/5.0" "http://eddylab.org/software/hmmer/hmmer-${HMMER_VERSION}.tar.gz" -o hmmer.tar.gz; then \
        echo "Direct tarball download failed, compiling HMMER + Easel from GitHub..."; \
        git clone --depth 1 --branch "hmmer-${HMMER_VERSION}" https://github.com/EddyRivasLab/hmmer.git "hmmer-${HMMER_VERSION}"; \
        cd "hmmer-${HMMER_VERSION}"; \
        git clone --depth 1 https://github.com/EddyRivasLab/easel.git easel; \
        apt-get update && apt-get install -y --no-install-recommends autoconf; \
        autoconf; \
        (cd easel && autoconf); \
    else \
        tar -xzf hmmer.tar.gz; \
        cd "hmmer-${HMMER_VERSION}"; \
    fi; \
    ./configure --prefix=/usr/local; \
    make -j"$(nproc)"; \
    make install; \
    cd easel; \
    make install; \
    cd /build; \
    rm -rf hmmer*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel / setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Tool version argument
ARG TOOL_VERSION=2.0.1

# Download and install defense-finder from official GitHub source tarball or PyPI
RUN set -eux; \
    TAR_URL="https://github.com/mdmparis/defense-finder/archive/refs/tags/v${TOOL_VERSION}.tar.gz"; \
    echo "Downloading defense-finder v${TOOL_VERSION} from ${TAR_URL}..."; \
    if curl -fsSL -A "Mozilla/5.0" "${TAR_URL}" -o defense-finder.tar.gz; then \
        mkdir src && tar -xzf defense-finder.tar.gz -C src --strip-components=1; \
        cd src; \
        pip install --no-cache-dir --pre .; \
    else \
        echo "Falling back to pip install mdmparis-defense-finder==${TOOL_VERSION}..."; \
        pip install --no-cache-dir --pre "mdmparis-defense-finder==${TOOL_VERSION}"; \
    fi; \
    find /opt/venv -type f -name '*.pyc' -delete; \
    find /opt/venv -type d -name '__pycache__' -exec rm -rf {} +

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

# Install git and ca-certificates (required by defense-finder update / models download)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy HMMER binaries from builder
COPY --from=builder /usr/local/bin/hmm* /usr/local/bin/
COPY --from=builder /usr/local/bin/esl* /usr/local/bin/

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /data

ENTRYPOINT ["defense-finder"]

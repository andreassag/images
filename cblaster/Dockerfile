# Multi-stage Dockerfile for cblaster
# Compiles DIAMOND from source, installs companion binaries (skani, mmseqs2, datasets, any2fasta),
# builds cagecleaner and clinker, and builds cblaster from GitHub source.

# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    zlib1g-dev \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Compile DIAMOND from upstream source
ARG DIAMOND_VERSION=v2.1.11
RUN set -eux; \
    git clone --depth 1 --branch "${DIAMOND_VERSION}" https://github.com/bbuchfink/diamond.git diamond_src; \
    mkdir -p diamond_src/build && cd diamond_src/build; \
    cmake -DCMAKE_BUILD_TYPE=Release ..; \
    make -j"$(nproc)"; \
    make install; \
    cd /build && rm -rf diamond_src

# Install companion binaries to /opt/companion/bin
RUN mkdir -p /opt/companion/bin

# 1. skani
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -fsSL "https://github.com/bluenote-1577/skani/releases/download/latest/skani" -o /opt/companion/bin/skani; \
        chmod +x /opt/companion/bin/skani; \
    else \
        apt-get update && apt-get install -y --no-install-recommends cargo rustc; \
        cargo install --root /opt/companion skani; \
        rm -rf /root/.cargo /var/lib/apt/lists/*; \
    fi

# 2. mmseqs2
ARG MMSEQS2_VERSION=15-6f452
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -fsSL "https://github.com/soedinglab/MMseqs2/releases/download/${MMSEQS2_VERSION}/mmseqs-linux-avx2.tar.gz" -o mmseqs.tar.gz || \
        curl -fsSL "https://github.com/soedinglab/MMseqs2/releases/download/${MMSEQS2_VERSION}/mmseqs-linux-sse41.tar.gz" -o mmseqs.tar.gz; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -fsSL "https://github.com/soedinglab/MMseqs2/releases/download/${MMSEQS2_VERSION}/mmseqs-linux-arm64.tar.gz" -o mmseqs.tar.gz; \
    fi; \
    tar -xzf mmseqs.tar.gz; \
    cp mmseqs/bin/mmseqs /opt/companion/bin/; \
    chmod +x /opt/companion/bin/mmseqs; \
    rm -rf mmseqs*

# 3. NCBI datasets CLI
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
        NCBI_ARCH="linux-amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        NCBI_ARCH="linux-arm64"; \
    fi; \
    curl -fsSL "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/${NCBI_ARCH}/datasets" -o /opt/companion/bin/datasets; \
    chmod +x /opt/companion/bin/datasets

# 4. any2fasta (Perl script)
RUN set -eux; \
    curl -fsSL "https://raw.githubusercontent.com/tseemann/any2fasta/master/any2fasta" -o /opt/companion/bin/any2fasta; \
    chmod +x /opt/companion/bin/any2fasta

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel / setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install PySimpleGUI-4-foss, clinker-py, and cagecleaner
RUN pip install --no-cache-dir \
    PySimpleGUI-4-foss \
    clinker-py \
    cagecleaner

# Tool version argument
ARG TOOL_VERSION=1.4.0

# Download and install cblaster from official GitHub source tarball
# Handle tag formatting (v1.4 for 1.4.0 or v${TOOL_VERSION}) and patch PySimpleGUI dependency
RUN set -eux; \
    TAG="v${TOOL_VERSION}"; \
    if [ "${TOOL_VERSION}" = "1.4.0" ]; then \
        TAG="v1.4"; \
    fi; \
    TAR_URL="https://github.com/gamcil/cblaster/archive/refs/tags/${TAG}.tar.gz"; \
    echo "Downloading cblaster ${TAG} from ${TAR_URL}..."; \
    curl -fsSL "${TAR_URL}" -o cblaster.tar.gz; \
    mkdir src && tar -xzf cblaster.tar.gz -C src --strip-components=1; \
    cd src; \
    if [ -f setup.py ]; then \
        sed -i 's/"PySimpleGUI"/"PySimpleGUI-4-foss"/g' setup.py; \
        sed -i "s/'PySimpleGUI'/'PySimpleGUI-4-foss'/g" setup.py; \
    fi; \
    pip install --no-cache-dir .; \
    find /opt/venv -type f -name '*.pyc' -delete; \
    find /opt/venv -type d -name '__pycache__' -exec rm -rf {} +

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

# Install perl and ca-certificates (required by any2fasta and remote NCBI requests)
RUN apt-get update && apt-get install -y --no-install-recommends \
    perl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy DIAMOND binary from builder
COPY --from=builder /usr/local/bin/diamond /usr/local/bin/diamond

# Copy companion binaries from builder
COPY --from=builder /opt/companion/bin/* /usr/local/bin/

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /data

ENTRYPOINT ["cblaster"]

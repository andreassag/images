# PyMOL Dockerfile
# Based on mambaorg/micromamba Debian-slim with Schrödinger pymol-bundle
# Supports X11/Wayland GUI forwarding and headless rendering

FROM mambaorg/micromamba:2.0.5-debian12-slim

USER root

# Install system GUI and OpenGL forwarding dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libdbus-1-3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user pymol (UID 1000, GID 1000)
RUN groupadd -g 1000 pymol \
    && useradd -u 1000 -g pymol -m -s /bin/bash pymol \
    && mkdir -p /home/pymol/.pymol /workspace \
    && chown -R pymol:pymol /home/pymol /workspace

# Copy default configurations
COPY pymolrc /home/pymol/.pymolrc
COPY pymolrc.py /home/pymol/.pymolrc.py
RUN chown pymol:pymol /home/pymol/.pymolrc /home/pymol/.pymolrc.py

# Switch to pymol user to install conda packages in base prefix
USER pymol

ARG TOOL_VERSION=3.0.0

# Install pymol-bundle from conda-forge and schrodinger channels
RUN micromamba install -y -n base \
    -c conda-forge \
    -c schrodinger \
    pymol-bundle=${TOOL_VERSION}* \
    && micromamba clean --all --yes \
    && find /opt/conda -follow -type f -name '*.a' -delete \
    && find /opt/conda -follow -type f -name '*.pyc' -delete

ENV PATH="/opt/conda/bin:$PATH"
WORKDIR /workspace

CMD ["pymol"]

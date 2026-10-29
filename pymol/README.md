# PyMOL Docker Container

Docker container packaging [PyMOL 3.x](https://pymol.org/) with display forwarding support (Linux X11/Wayland, macOS XQuartz, Windows WSLg), non-root execution, configuration presets, and headless ray-tracing capabilities.

## Features

- **PyMOL 3.x**: Packaged using Schrödinger's `pymol-bundle` conda packages.
- **GUI Support**: Seamless GUI forwarding for Linux (X11 & Wayland), macOS (XQuartz), and Windows (WSLg).
- **Non-root Security**: Runs as unprivileged user `pymol` (UID 1000).
- **Publication Presets**: Pre-configured `pymolrc` and `pymolrc.py` with publication-quality ray-tracing defaults.
- **Headless Scripting**: Full support for headless automation (`pymol -cq`).

---

## Quick Start

### 1. License Setup (Optional)
If you have an academic or commercial PyMOL license:
```bash
cp /path/to/your/license.lic ./license.lic
```
If no license is provided, PyMOL runs in open-source/evaluation mode.

### 2. Running on Linux

Allow local container connections to the X server:
```bash
xhost +local:root
# or for user:
xhost +local:$USER
```

Run using Docker Compose:
```bash
# Standard X11
docker compose up

# With hardware acceleration / Wayland support
docker compose -f docker-compose.linux.yml up
```

Or run directly with `docker run`:
```bash
docker run -it --rm \
  --net=host \
  --ipc=host \
  -e DISPLAY="${DISPLAY}" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$(pwd)":/workspace \
  -v "$(pwd)/license.lic":/home/pymol/.pymol/license.lic:ro \
  ghcr.io/andreassag/pymol:latest
```

### 3. Running on macOS (XQuartz)

1. Install [XQuartz](https://www.xquartz.org/).
2. In XQuartz preferences, enable **"Allow connections from network clients"** under the Security tab.
3. Restart XQuartz and run:
   ```bash
   xhost + 127.0.0.1
   ```
4. Start PyMOL using Docker Compose:
   ```bash
   docker compose -f docker-compose.mac.yml up
   ```

### 4. Running on Windows (WSL2 / WSLg)

On Windows 11 with WSLg, GUI forwarding works out of the box:
```bash
docker run -it --rm \
  -e DISPLAY="${DISPLAY}" \
  -e WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
  -e XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}":/tmp/wayland-0:ro \
  -v "$(pwd)":/workspace \
  ghcr.io/andreassag/pymol:latest
```

---

## Headless Batch Rendering

To run scripts headlessly without requiring an X display server, pass `-cq`:

```bash
docker run --rm \
  -v "$(pwd)":/workspace \
  ghcr.io/andreassag/pymol:latest \
  pymol -cq examples/render_structure.py
```

This will fetch the structure (e.g. `1crn`), apply styles, ray-trace, and output `1crn_rendered.png`.

---

## Building Locally

```bash
docker build -t ghcr.io/andreassag/pymol:latest --build-arg TOOL_VERSION=3.1.6.1 .
```

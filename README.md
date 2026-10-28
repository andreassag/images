<!--
This repository contains container definitions for bioinformatics and molecular
visualisation utilities. Each tool provides immutable images for supported releases
while maintaining convenient `latest`, `major`, and `minor` tags.
-->

# Container images for bioinformatics tools

This repository provides reproducible, optimized OCI/Docker images built from source for bioinformatics and molecular visualisation tools:

| Tool | Description | Versions | Container Type |
|------|-------------|----------|----------------|
| **clinker** | Gene cluster comparison and visualisation (`clinker-py`) | 0.0.12, 0.0.19 – 0.0.32 | Built from source (`python:3.12-slim`) |
| **cblaster** | Remote homologue detection and gene cluster search (ships with `cagecleaner`, `diamond`, `skani`, `mmseqs2`, `datasets`, `any2fasta`) | 1.3.9, 1.3.11 – 1.3.20, 1.4.0 | Built from source (`python:3.12-slim`) |
| **defense‑finder** | Systematic search for anti‑phage defense systems (ships with `HMMER 3.4`) | 1.2.2, 1.3.0, 2.0.0, 2.0.1 | Built from source (`python:3.12-slim`) |
| **pymol** | Molecular visualisation system with X11/Wayland GUI forwarding & publication presets | 3.0.0 | GUI / Headless (`micromamba:debian-slim`) |

Command-line utilities (`clinker`, `cblaster`, `defense-finder`) are built from upstream source code and official releases using multi-stage Python slim Dockerfiles rather than bioconda distributions, yielding lightweight, secure containers.

PyMOL 3.x is packaged with GUI forwarding libraries and publication-quality ray-tracing presets. See [pymol/README.md](file:///home/andre/repo/images/pymol/README.md) for detailed GUI forwarding and compose instructions.

---

## Repository layout

```
/
├─ clinker/
│  ├─ Dockerfile                           # Parameterised via ARG TOOL_VERSION
│  └─ versions.txt                         # Supported releases
├─ cblaster/
│  ├─ Dockerfile
│  └─ versions.txt
├─ defense-finder/
│  ├─ Dockerfile
│  └─ versions.txt
├─ pymol/
│  ├─ Dockerfile
│  ├─ versions.txt
│  ├─ README.md                            # Display forwarding & usage guide
│  ├─ docker-compose.yml                   # Compose setup
│  ├─ docker-compose.linux.yml             # Linux Wayland/DRI GPU compose
│  ├─ docker-compose.mac.yml               # macOS XQuartz compose
│  ├─ pymolrc / pymolrc.py                 # Publication-quality presets
│  ├─ license.lic.example                  # License mount instructions
│  └─ examples/render_structure.py         # Headless ray-tracing script
├─ tests/
│  ├─ clinker/test.sh
│  ├─ cblaster/test.sh
│  ├─ defense-finder/test.sh
│  └─ pymol/test.sh
├─ scripts/
│  └─ generate-dependabot.sh               # Dependabot generator
├─ .github/
│  ├─ workflows/build-container.yml        # CI matrix & caching workflow
│  └─ dependabot.yml                       # Dependency updates
├─ AGENTS.md                               # Guidelines for AI / Antigravity
└─ README.md
```

---

## Building locally

Each image can be built locally using `docker build` or `podman` by supplying `--build-arg TOOL_VERSION=<version>`:

```sh
# clinker
docker build -t clinker:0.0.32 --build-arg TOOL_VERSION=0.0.32 ./clinker

# cblaster
docker build -t cblaster:1.4.0 --build-arg TOOL_VERSION=1.4.0 ./cblaster

# defense-finder
docker build -t defense-finder:2.0.1 --build-arg TOOL_VERSION=2.0.1 ./defense-finder

# pymol
docker build -t pymol:3.0.0 --build-arg TOOL_VERSION=3.0.0 ./pymol
```

---

## Testing locally

Each tool has a functional test script in `tests/<tool>/test.sh`. The script accepts the built image tag and expected version:

```sh
# Test clinker
docker build -t test/clinker:0.0.32 --build-arg TOOL_VERSION=0.0.32 ./clinker
tests/clinker/test.sh test/clinker:0.0.32 0.0.32

# Test defense-finder
docker build -t test/defense-finder:2.0.1 --build-arg TOOL_VERSION=2.0.1 ./defense-finder
tests/defense-finder/test.sh test/defense-finder:2.0.1 2.0.1

# Test cblaster
docker build -t test/cblaster:1.4.0 --build-arg TOOL_VERSION=1.4.0 ./cblaster
tests/cblaster/test.sh test/cblaster:1.4.0 1.4.0

# Test pymol (headless)
docker build -t test/pymol:3.0.0 --build-arg TOOL_VERSION=3.0.0 ./pymol
tests/pymol/test.sh test/pymol:3.0.0 3.0.0
```

---

## Continuous Integration

GitHub Actions workflow (`.github/workflows/build-container.yml`) automatically detects changes:
1. **Detect Changes**:
   - `<tool>/Dockerfile` modified: Builds, tests, and pushes **all** versions listed in `<tool>/versions.txt`.
   - `<tool>/versions.txt` modified: Parses newly added version lines and builds, tests, and pushes **only those added versions**.
   - `tests/<tool>/` modified: Builds and tests all versions for that tool (**no push** to registry).
2. **Matrix Build**:
   - Multi-stage parallel builds with scoped BuildKit GitHub Actions cache (`scope=${{ matrix.tool }}`).
   - OCI metadata labels attached linking images to the repository.
   - Tags published on `main`: `:${TOOL_VERSION}`, plus `:latest`, `:${MAJOR}`, and `:${MINOR}` for the highest version.

---

## Running PyMOL

For full details on configuring X11, Wayland, XQuartz (macOS), WSLg (Windows), and mounting licenses, refer to [`pymol/README.md`](file:///home/andre/repo/images/pymol/README.md).

Quick test run (headless):
```sh
docker run --rm ghcr.io/andreassag/pymol:latest pymol -cq -d "print('PyMOL works!')"
```

---

## Contributing & Guidelines

Please refer to [`AGENTS.md`](file:///home/andre/repo/images/AGENTS.md) for architectural guidelines, build-from-source conventions, versioning workflows, and Dependabot synchronization rules.

---

## License & Attribution

This repository does not contain the tools themselves, which are distributed under their respective licenses.
The container definitions are provided under the [MIT License](LICENSE).

---

_Maintained by andreassag_

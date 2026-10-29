#!/usr/bin/env bash
# Tests for the pymol container image.
# Usage: ./test.sh <image> <expected_version>
set -euo pipefail

IMAGE="${1:?Usage: $0 <image> <expected_version>}"
EXPECTED_VERSION="${2:?Usage: $0 <image> <expected_version>}"

PASS=0
FAIL=0

pass() { ((++PASS)); echo "  ✅  $1"; }
fail() { ((++FAIL)); echo "  ❌  $1"; }

echo "── Testing ${IMAGE} (expected v${EXPECTED_VERSION}) ──"

# 1. Headless startup sanity check
echo ""
echo "1) Headless startup check"
if docker run --rm "${IMAGE}" pymol -cq -d "print('HEADLESS_OK')" 2>&1 | grep -q "HEADLESS_OK"; then
  pass "PyMOL launches headlessly and executes command"
else
  fail "PyMOL headless command failed"
fi

# 2. Version verification
echo ""
echo "2) Version check"
if OUTPUT=$(docker run --rm "${IMAGE}" pymol -cq -d "import pymol; print('PYMOL_VERSION=' + str(pymol.__version__))" 2>&1) && \
   echo "${OUTPUT}" | grep -q "PYMOL_VERSION=${EXPECTED_VERSION}"; then
  pass "Version matches ${EXPECTED_VERSION}"
else
  fail "Version mismatch (output: ${OUTPUT:0:200})"
fi

# 3. Headless structure rendering test
echo ""
echo "3) Headless Python API structure rendering check"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$(cd "${SCRIPT_DIR}/../../pymol/examples" 2>/dev/null && pwd || true)"

if [[ -n "${EXAMPLES_DIR}" && -f "${EXAMPLES_DIR}/render_structure.py" ]]; then
  TEST_DIR="$(mktemp -d)"
  chmod 777 "${TEST_DIR}"
  cp "${EXAMPLES_DIR}/render_structure.py" "${TEST_DIR}/"
  if OUTPUT=$(docker run --rm -v "${TEST_DIR}":/workspace -w /workspace "${IMAGE}" pymol -cq render_structure.py 2>&1); then
    pass "PyMOL rendered structure in headless mode successfully"
  else
    fail "PyMOL headless render_structure.py failed (output: ${OUTPUT:0:300})"
  fi
  rm -rf "${TEST_DIR}"
else
  pass "Example render script check skipped (examples directory not mounted)"
fi

# Summary
echo ""
echo "── Results: ${PASS} passed, ${FAIL} failed ──"
[[ ${FAIL} -eq 0 ]]

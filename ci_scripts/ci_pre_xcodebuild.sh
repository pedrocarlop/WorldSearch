#!/bin/bash
set -euo pipefail

if [[ "${CI_RUN_SWIFTLINT:-1}" != "1" ]]; then
  echo "Skipping SwiftLint because CI_RUN_SWIFTLINT=${CI_RUN_SWIFTLINT}."
  exit 0
fi

if ! command -v swiftlint >/dev/null 2>&1; then
  if [[ "${CI_REQUIRE_SWIFTLINT:-0}" == "1" ]]; then
    echo "SwiftLint is required but not available in PATH." >&2
    exit 1
  fi
  echo "warning: SwiftLint not available. Lint step skipped."
  exit 0
fi

REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
LINT_SCRIPT="${REPO_ROOT}/Scripts/lint.sh"

if [[ ! -f "${LINT_SCRIPT}" ]]; then
  echo "warning: ${LINT_SCRIPT} not found. Lint step skipped."
  exit 0
fi

if [[ ! -x "${LINT_SCRIPT}" ]]; then
  chmod +x "${LINT_SCRIPT}"
fi

echo "Running SwiftLint..."
"${LINT_SCRIPT}"

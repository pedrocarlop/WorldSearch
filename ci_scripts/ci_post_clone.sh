#!/bin/bash
set -euo pipefail

if [[ "${CI_INSTALL_SWIFTLINT:-1}" != "1" ]]; then
  echo "Skipping SwiftLint install because CI_INSTALL_SWIFTLINT=${CI_INSTALL_SWIFTLINT}."
  exit 0
fi

if command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint already available: $(swiftlint version)"
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  BREW_BIN="$(command -v brew)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
  BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
  BREW_BIN="/usr/local/bin/brew"
else
  echo "warning: Homebrew is not available. SwiftLint install skipped."
  exit 0
fi

echo "Installing SwiftLint with Homebrew..."
HOMEBREW_NO_AUTO_UPDATE=1 "${BREW_BIN}" install swiftlint

# Ensure the current shell can resolve the newly installed binary.
eval "$("${BREW_BIN}" shellenv)"
echo "SwiftLint installed: $(swiftlint version)"

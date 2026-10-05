#!/usr/bin/env bash
# Regenerate lib/l10n_fork/generated from the fork-only catalogues in l10n_fork/.
# A Flutter project reads a single l10n.yaml, so the fork catalogue is generated
# from its own directory, which carries a second l10n.yaml and a stub pubspec.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}/l10n_fork"
flutter gen-l10n
cd "${ROOT}"
dart format lib/l10n_fork/generated

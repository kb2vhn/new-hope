#!/bin/sh
# Verify the documentation-first repository scaffold only; NOT a kernel acceptance test.
set -eu

cd "$(dirname "$0")/.."
for required in \
    README.md AGENTS.md CONTRIBUTING.md SECURITY.md \
    docs/architecture/ARCHITECTURE.md \
    docs/architecture/DECISIONS.md \
    docs/architecture/ADR-0001-MICROKERNEL-BOUNDARY.md \
    docs/architecture/ADR-0002-UMI-ENFORCEMENT.md \
    docs/architecture/OPEN-QUESTIONS.md \
    docs/roadmap/ROADMAP.md \
    docs/development/GETTING-STARTED.md \
    docs/development/HANDOFF.md \
    docs/development/VALIDATION.md \
    kernel/README.md services/README.md interfaces/README.md \
    tests/README.md tools/README.md
 do
    [ -f "$required" ] || {
        printf 'Missing required file: %s\n' "$required" >&2
        exit 1
    }
 done

# Check canonical architecture and UMI terminology survived the scaffold.
grep -q 'Unified Message Interface' docs/architecture/ARCHITECTURE.md
grep -q 'default deny\|Default deny' docs/architecture/ARCHITECTURE.md

echo 'PASS: documentation scaffold structure (no OS build/test performed)'

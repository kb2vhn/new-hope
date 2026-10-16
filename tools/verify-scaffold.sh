#!/bin/sh
# Documentation integrity only: NOT a kernel or security acceptance test.
set -eu
cd "$(dirname "$0")/.."

for required in \
    README.md AGENTS.md CONTRIBUTING.md SECURITY.md \
    docs/architecture/ARCHITECTURE.md \
    docs/architecture/DESIGN-GOALS.md \
    docs/architecture/RECONCILIATION.md \
    docs/architecture/DECISIONS.md \
    docs/architecture/OPEN-QUESTIONS.md \
    docs/architecture/ADR-0001-MICROKERNEL-BOUNDARY.md \
    docs/architecture/ADR-0002-UMI-ENFORCEMENT.md \
    docs/architecture/ADR-0003-UMI-POLICY-AND-EXECUTION.md \
    docs/architecture/ADR-0004-PROTECTED-NETWORK-FIREWALL.md \
    docs/architecture/ADR-0005-APPLICATION-HID-AND-DEVICE-BOUNDARIES.md \
    docs/architecture/ADR-0006-FILESYSTEM-OWNERSHIP-AND-ACL.md \
    docs/architecture/ADR-0007-IDENTITIES-PRIVILEGE-AND-LOCKDOWN.md \
    docs/architecture/ADR-0008-LOGGING-AND-SECURITY-JOURNALS.md \
    docs/architecture/ADR-0009-BACKUP-AND-RESTORE-AUTHORITY.md \
    docs/architecture/ADR-0010-LITIGATION-HOLDS-AND-SECURITY-AUDITOR.md \
    docs/architecture/ADR-0011-VERIFIED-BOOT-RECOVERY-AND-SECURITY-STATE.md \
    docs/architecture/ADR-0012-NATIVE-COMMAND-AND-CONFIGURATION.md \
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

grep -q 'Unified Message Interface\|Unified.*Message.*Interface' docs/architecture/ARCHITECTURE.md README.md
grep -q 'Default deny\|default deny' docs/architecture/ARCHITECTURE.md docs/architecture/ADR-0003-UMI-POLICY-AND-EXECUTION.md
grep -q 'RECOVERY cannot unlock\|RECOVERY.*cannot.*unlock' docs/architecture/ADR-0011-VERIFIED-BOOT-RECOVERY-AND-SECURITY-STATE.md
grep -q 'Browser.*browser\|browser.*browser' docs/architecture/ADR-0005-APPLICATION-HID-AND-DEVICE-BOUNDARIES.md

echo 'PASS: documentation scaffold and key architectural links (NO OS TEST RUN)'

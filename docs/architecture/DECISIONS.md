# New Hope — Architecture decision register

**Implementation status:** design-only. Each ADR records accepted intent and explicitly **unselected engineering details**; acceptance of a direction is not approval of a concrete interface or working code.

## Decision maturity labels

Use these three labels consistently throughout architecture, examples, roadmap, and implementation planning:

- **Accepted:** An architectural requirement or direction approved for New Hope. It is binding at the stated abstraction level, but does not assert any implementation exists or freeze unspecified algorithms, interfaces, encodings, or hardware assumptions.
- **Open:** A substantive design or engineering choice that has not been approved. Resolve, analyze consequences, and document it before implementing the affected feature; an Open item does not block unrelated earlier milestones.
- **Illustrative:** A nonbinding example, such as a command spelling, configuration path, sample ACL, policy entry, diagram, message format, or output. It communicates intent and must never be treated as a frozen API, on-disk format, or test specification.

An ADR may contain **Accepted** principles, **Open** mechanisms, and **Illustrative** examples at the same time. Decisions are refined as engineering progresses, with explicit approval and recorded validation.

| ID | Decision | Status |
| --- | --- | --- |
| [ADR-0001](ADR-0001-MICROKERNEL-BOUNDARY.md) | Kernel scheduling/memory/interrupt/IPC boundary | Accepted (2026-10-13) |
| [ADR-0002](ADR-0002-UMI-ENFORCEMENT.md) | Universal mandatory UMI authorization | Accepted (2026-10-13) |
| [ADR-0003](ADR-0003-UMI-POLICY-AND-EXECUTION.md) | Firewall-like ACL policy, delegated authority, execution contexts | Accepted direction (2026-10-16) |
| [ADR-0004](ADR-0004-PROTECTED-NETWORK-FIREWALL.md) | Protected native networking firewall | Accepted direction (2026-10-16) |
| [ADR-0005](ADR-0005-APPLICATION-HID-AND-DEVICE-BOUNDARIES.md) | Browser/application responsibility, protected HID/device | Accepted direction (2026-10-16) |
| [ADR-0006](ADR-0006-FILESYSTEM-OWNERSHIP-AND-ACL.md) | Owner/creator, independent file/dir ACLs | Accepted direction (2026-10-16) |
| [ADR-0007](ADR-0007-IDENTITIES-PRIVILEGE-AND-LOCKDOWN.md) | Least privilege, OPS/DR/SecAuditor, frozen security locks | Accepted direction (2026-10-16) |
| [ADR-0008](ADR-0008-LOGGING-AND-SECURITY-JOURNALS.md) | Native logs, protected journals, retention, anomalies | Accepted direction (2026-10-16) |
| [ADR-0009](ADR-0009-BACKUP-AND-RESTORE-AUTHORITY.md) | Scoped backup, operators, original-location restore | Accepted direction (2026-10-16) |
| [ADR-0010](ADR-0010-LITIGATION-HOLDS-AND-SECURITY-AUDITOR.md) | Holds and hold-only auditor visibility | Accepted direction (2026-10-16) |
| [ADR-0011](ADR-0011-VERIFIED-BOOT-RECOVERY-AND-SECURITY-STATE.md) | Boot assurance, 26-char RECOVERY, persistent security state | Accepted direction (2026-10-16) |
| [ADR-0012](ADR-0012-NATIVE-COMMAND-AND-CONFIGURATION.md) | Native prompt, base utilities, constrained rc | Accepted direction (2026-10-16) |

Original `ARCHITECTURE.md` **DEC-001–DEC-010** refer to the original kernel/UMI baseline; they remain logically accepted. Later ADRs add scope rather than retroactively claiming the first two ADRs included it.

## Change discipline

1. Explain the existing contract and proposed difference, including security, performance and failure behavior.
2. Separate accepted principles from ABI, format, algorithms and implementation choices not yet ratified.
3. Obtain explicit user approval for architectural changes, and **separate approval for GitHub writes**.
4. Add/modify an ADR; preserve and mark earlier decisions as superseded rather than silently deleting design history.
5. Keep `ARCHITECTURE.md`, `OPEN-QUESTIONS.md`, roadmap, component readmes and tests consistent.
6. Do not claim code, test, or hardware support from documentation-only checks.

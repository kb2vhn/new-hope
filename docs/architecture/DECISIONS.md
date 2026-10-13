# Architecture Decision Register

Architecture decisions are durable and deliberately reviewable. The 2026-10-13 baseline records agreed principles as DEC-001 through DEC-010 in [ARCHITECTURE.md](ARCHITECTURE.md). ADRs below summarize the two binding architectural boundaries for future contributors.

| ID | Date | Status | Decision |
| --- | --- | --- | --- |
| [ADR-0001](ADR-0001-MICROKERNEL-BOUNDARY.md) | 2026-10-13 | Accepted | Rust microkernel owns scheduling, interrupts, memory mechanisms, primitive IPC |
| [ADR-0002](ADR-0002-UMI-ENFORCEMENT.md) | 2026-10-13 | Accepted | Universal, mandatory, NGFW-like UMI authorization for external communication |

## Decision change procedure

1. Explain the existing contract and why changing it is necessary.
2. Describe the options, security/performance effects, fallback and failure behavior.
3. Obtain explicit project-owner approval for the architectural change.
4. Add a numbered ADR using the same headings as the records above.
5. Mark the earlier ADR as **Superseded** and link to the replacement, rather than deleting the history.
6. Update the architecture baseline, roadmap, related tests and component documentation together.

An exploratory sketch, message example, or chat suggestion is not an accepted ABI or design decision. Track unresolved choices in [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md).

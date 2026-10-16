# Design reconciliation — 2026-10-16

**Purpose:** Explain differences between the initial 2026-10-13 scaffold and the expanded architecture discussions. This is not an implementation report. The architecture baseline and ADRs contain the resulting requirements; this register is an audit trail for documentation reviewers.

| Topic | Previous repository baseline | Reconciled direction | References |
| --- | --- | --- | --- |
| CPU/host | x86-64 IdeaPad described as development host | Workstation builds; x86-64 QEMU then IdeaPad; later ARM64; one portable OS | README, ARCHITECTURE, ROADMAP |
| UMI | Mandatory NGFW-like IPC boundary | Policy/ACL enforcement engine, explicit denies, authenticated identities, bounded operations; no application-specialized logic | ADR-0002, ADR-0003 |
| Child execution | Delegation undecided | App-created children may have equal or reduced authority, never more; immutable kernel-owned lineage enforces termination of all descendants when a parent ends; user-requested launches are independently policy checked and protected services cannot adopt application children | ADR-0003 |
| Networking | Undesigned | Stateful firewall integrated in isolated networking service; kernel forbids bypass; no inline TLS interception | ADR-0004 |
| Browser/HID | Undesigned | Browser internals stay browser-owned; kernel/resource-service handles process boundaries and device access | ADR-0005 |
| Files | Filesystem permissions unspecified | Owner distinct from creator; no world class; Traverse/List/Read separated; private-by-default; administrative takeover auditable | ADR-0006 |
| Privileged identities | Unspecified | Least-privilege users, doas-like operation, timed `eu -`, separate OPS/DR/SecAuditor/RECOVERY local accounts | ADR-0007, ADR-0011 |
| Compromise containment | Unspecified | Security-locked *base identity*, frozen attributable processes, DR-only review/recovery, preserved incident | ADR-0007 |
| Logs/journals | Bounded UMI audit only | Native logs and protected append-only security journals; rotation, 90-day default retention, integrity, DR-owned anomaly parameter | ADR-0008 |
| Backups | Undesigned | Owner opt-in for private user data; shared `/projects` and system-state policy; service-identity backup/restore separation | ADR-0009 |
| Litigation hold | Undesigned | Account-scoped mandatory preservation; held content accessed by dedicated SecAuditor identity | ADR-0010 |
| Boot security | Undesigned | Three reported assurance classes; hardware-rooted verification if supported, QEMU development allowed | ADR-0011 |
| Native prompt | No concrete contract | Small executor, bundled utilities, separate shell interpreters, per-user settings bounded by global policy | ADR-0012 |

## Conflicts resolved in language

1. **No application-specific UMI:** A browser handles browser extensions. An OS security service must not rely on interpreting TLS or page content.
2. **Admin is not general file-read authority:** Administrators may inspect permitted metadata and perform explicit ownership/ACL recovery; an audited takeover changes authority, not an implicit content grant.
3. **Recovery types differ:** Routine admin reset, DR clearance of security-locked accounts, and boot-only RECOVERY of protected account credentials are distinct operations.
4. **Backup differs from hold:** Owner-opted backup and system-state backup do not remove the preservation requirements of an authorized administrative/litigation hold.
5. **Filesystem `x` is not overloaded:** Directory Traverse and file Execute are independent; List is distinct from file-content Read.
6. **Root-level power is limited:** No dedicated account, including DR, OPS, SecAuditor, and RECOVERY, receives general-purpose access by virtue of its name.

## Open design points (not silently approved)

- The proposed 10% journal anomaly threshold is accepted, but **its statistical reference/baseline and monitoring interval are not decided**. Rollover size alone is not proof of compromise.
- Hold activation/release authority and the precise hold scope for creator-versus-owner paths remain open.
- Whether SecAuditor's word “execute” means running held executables or only directory Traverse is open; file execution is **not assumed**.
- Backup enrollment inheritance, snapshot/retention formats, restore collision policy, and how system-state recovery treats user data outside scoped backups remain implementation decisions subject to the established principles.
- The exact equal-or-reduced child-authority representation, independently authorized user launch, kernel-owned process-tree termination ordering, service-broker attribution and revocation contracts need engineering validation.
- The password verifier design, recovery secrets and keys, filesystem format, UMI ABI and policy storage are not frozen.
- Boot integrity on a specific IdeaPad or ARM64 board is unverified. A self-reported software checksum is not a hardware root of trust.

**Status:** The above are documentation targets and accepted directions, *not* implemented behavior.

# New Hope — Architecture baseline

- **Version:** Proposed v0.5 documentation reconciliation (2026-10-16)
- **Status:** Agreed design principles; **no kernel implementation or accepted runtime test**
- **Repository:** https://github.com/kb2vhn/new-hope
- **Authoritative decisions:** [Decision register](DECISIONS.md) and linked ADRs
- **Open implementation choices:** [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md)

> New Hope is an independent, multiuser, portable Rust **microkernel operating system**, not a Linux/FreeBSD distribution, MINIX fork or mandated POSIX clone. **x86-64 is first** (QEMU, then available Lenovo IdeaPad); ARM64 is intended later. One OS, separate architecture-specific mechanisms.

## 1. Original decisions preserved (DEC-001 through DEC-010)

| Original decision | Retained invariant |
| --- | --- |
| DEC-001 — Real Rust microkernel | Small freestanding privileged kernel and isolated external services |
| DEC-002 — Kernel mechanism ownership | Scheduling/context switch, exception/interrupt entry, physical/virtual memory mapping/protection, core IPC and UMI checks are kernel mechanisms |
| DEC-003 — Mandatory UMI | External-to-kernel and external-to-external communication requests cross a kernel-authorized UMI boundary; internal kernel functions and CPU interrupts are not UMI requests |
| DEC-004 — Firewall-inspired UMI | Kernel-authenticated caller, destination, operation, capability/context, bounds, default deny, audit; application payload interpretation stays outside kernel |
| DEC-005 — Split policy plane | Small enforcement engine inside microkernel; protected user-space policy administration; no fail-open if administrator service disappears |
| DEC-006 — Named typed calls | Logical named service/operation model over efficient IPC, **not** a requirement for TCP/IP or human-readable wire data |
| DEC-007 — Isolated services | Service registry, process-manager policy, storage/filesystem, drivers, terminal and supervision outside kernel where feasible; restart/state need explicit contracts |
| DEC-008 — Authorized shared memory | Explicit grant, mapping, revocation; zero-copy does not become a bypass |
| DEC-009 — Security observability | Bounded event/audit generation and honest threat limits; no promise against compromised kernel or uncontrolled DMA |
| DEC-010 — Incremental proof | First prove QEMU boot/halt; then memory isolation; then UMI allow/deny; then restart/revocation—not a complete OS on first boot |

**ADR-0001 and ADR-0002 remain accepted.** Later ADRs provide additional product and security requirements, not evidence that those mechanisms exist today.

## 2. Architectural responsibility map

| Component / boundary | Owner of policy or mechanism |
| --- | --- |
| CPU, process address spaces, interrupts, kernel entry, primitive IPC | Privileged microkernel |
| UMI identities, cross-boundary authorization and authorized shared resources | Microkernel enforcement; protected external policy controller |
| Process launch/sessions/user authentication | Protected user-space identity/session/process services and UMI checks |
| File ACL, owner/creator, backup and hold metadata | Protected filesystem and dedicated backup/hold services |
| Mandatory firewall and network connection state | Protected networking service; kernel-enforced driver/device isolation |
| HID delivery, raw input, clipboard/screen capture | Protected input/display/device services under UMI policy |
| Browser extensions, webpage origin and DOM, cookies | **Browser alone**; OS does not understand extensions |
| TLS and SSH plaintext/keys | Application or protocol implementation; administrator-authorized diagnostic export only |
| Journal append, segment sealing, retention, integrity verification | Protected logging/journal services; kernel enforces service authority |
| HIDS correlation/alerts | Isolated analyzer, not automatic universal policy writer |
| Normal administration, DR, OPS, SecAuditor, RECOVERY | Separate fixed local identities and narrow authorized operations |

## 3. New accepted direction by domain

### UMI and process authority — ADR-0003

UMI evaluates authenticated source, destination, operation, applicable ACL/policy and state, with explicit-deny precedence and fail-closed authorization. **Services own application-specific object checks.** Policy revisions are built and validated outside the kernel and installed atomically. Application-created children have **strictly lower delegated authority** than their parent; independently authorized user-requested executable launches do not receive arbitrary privileges from the prompt. Neither UMI nor the kernel parses browser extensions or TLS payloads.

### Native network security — ADR-0004

The bidirectional stateful firewall operates in a **protected user-space networking service**. There is no normal-network bypass via raw sockets, drivers or helper services; an OS networking permission does not override a firewall destination deny. Packet traffic has no administrative policy authority. The firewall fails closed, operates with bounded resources, and must not require a per-packet security-service round trip. TLS/SSH interception is not built into the firewall. Participating TLS libraries may allow separately authorized and logged session-secret export.

### Applications and human-interface devices — ADR-0005

OS process/resource isolation is distinct from browser/application logic. Focused input works normally; global keyboard monitoring, raw devices, screen capture and system-wide clipboard monitoring are **separately authorized**, not inherited from ordinary app permissions. Input authentication must have a trusted path. Hardware isolation/DMA capabilities vary by target.

### Filesystem — ADR-0006

Owner and creator are distinct; objects normally inherit **parent-designated ownership**. A creator in someone else's directory receives no automatic ownership or file content access. Directories distinguish `Traverse`, `List`, `Create`, entry changes and ACL management; files distinguish `Read`, `Write`, `Execute` and ACL management. **Traverse != List != file Read**. Permission inheritance is scoped per operation with explicit deny precedence. There is no world class or `777` equivalent. A user can modify an owned object's ACL only for authorized groups they belong to; the `users` group requires administrative assignment. An administrator may enumerate authorized file metadata, not private contents by default; takeover and added rights require separately journaled administration.

### Users, special accounts and containment — ADR-0007

Multiuser/least-privilege sessions; `doas`-style narrow elevation; timed `eu -` sessions (10-minute default, user may shorten under global max, `end` or `exit`). OPS, DR and SecAuditor are **specific local accounts, not assignable roles or groups**. They use distinct protected credentials, generic password-policy rejection and narrow, non-overlapping authorities. High-confidence privileged compromise locks the **base user account** and freezes all attributable processes including elevated/child tasks. DR alone reviews/recovers security-locked identities, viewing **only locked account process metadata**. Neither DR nor ordinary admin receives broad file-content or process-memory access.

### Logs and journals — ADR-0008

System logging is native, independent of HIDS and network availability; forward securely later. Security journals are append-only and sealed with hash-linked integrity, immutable after commit, and independently verifiable where possible. Segment rollover **7 days or 128 MB**, default retention **90 days**, extended by DR; incidents/holds prevent premature retirement. Proposed anomaly threshold **10%**, changeable only by DR, with its measurement definition still open. High-risk activity is subject to attributable containment, not simple rollover-triggered lockout. Failed journal integrity suspends privileged security changes without unnecessarily stopping safe normal operations.

### Backups and litigation holds — ADR-0009 / ADR-0010

Owner controls normal backup enrollment for private `/home/<user>` files. Shared `/projects` coverage and system-state recovery have their own policy. `system.backup` is a protected **noninteractive service** holding a reconciled inventory of eligible file IDs, owners/creators, **original paths** and metadata; operators authorized by OPS initiate jobs but do not inherit data reads. User-scoped backup selects owner-enrolled files, system mode selects eligible coverage. Restoration is separate authority restricted to authorized original location, with conflict prevention. An active administrative/litigation hold overrides opt-out and preserves scoped files/versions. SecAuditor may discover and read **only held objects**; hold activation/release authority and actual file Execute scope are not decided.

### Boot, restricted RECOVERY and persistent state — ADR-0011

Report assurance classes: Development, Software-Verified, and Hardware-Rooted as available. Verified boot is a target, not a blocker for G1. Installer generates a **one-time 26-character random alphanumeric** code for a local, boot-menu `RECOVERY` environment. RECOVERY may reset OPS/DR/SecAuditor credentials and create an administrator, **never unlock a SECURITY_LOCKED account**, delete incidents or act as universal root. Only DR reviews/clears security-locked accounts. Hold/lock/journal security state persists across reboot, while frozen process RAM does not necessarily survive; affected processes must not auto-restart.

### Native command environment — ADR-0012

A lightweight command executor with arguments, quoting, `&&`/`||`, bundled filesystem tools and optional external shells. Per-user non-executable configuration covers aliases and preferences; protected system policy establishes security ceilings. The command executor contains no general security bypass or browser-specific functionality.

## 4. Threat and assurance boundaries

**Targets:** forged caller identities, unauthorized IPC/device access, over-privileged children/helpers, unauthorized keyboard monitoring, network policy bypass, unjournaled privileged file changes, silent admin account recovery, backup-restoration privilege laundering, and premature retirement of held security records.

**Not guaranteed by design alone:** a malicious/compromised privileged kernel, hostile firmware, an OS-level device without hardware DMA isolation, physical key extraction, application-internal browser extension compromise, all covert exfiltration over permitted connections, arbitrary data encryption-key recovery, or a working OS before implementation and tests. Hardware-backed boot/anti-rollback guarantees are target dependent.

## 5. Implementation and milestone discipline

Use [ROADMAP.md](../roadmap/ROADMAP.md). Initial gates G0–G5 are still:

- **G0:** real environment inventory; nondestructive QEMU and physical-target planning.
- **G1:** deterministic freestanding Rust x86-64 QEMU boot, serial diagnostic, controlled halt.
- **G2:** memory mapping and exception/interrupt primitives.
- **G3:** two isolated user-mode address spaces, controlled kernel entry and authenticated origin.
- **G4:** authorized and denied UMI messages with bounded audit.
- **G5:** failure/restart, stale handle, malformed message and revocation negative tests.

Later, separate acceptance gates will cover user/session authority, native executor, storage/ACLs, HID, protected networking/firewall, journal integrity, backups, litigation holds, recovery and ARM64. **No gate has been completed.** Do not introduce an entire security administration stack into the first serial-print kernel.

## 6. Decision discipline

`DECISIONS.md` is the ADR index; `OPEN-QUESTIONS.md` carries unresolved format/algorithm/platform choices. If a decision changes, record reasons, tradeoffs, tests, approval and supersession; do not silently edit accepted guarantees. No GitHub write without the owner's explicit approval of its scope. Do not cross-reference unrelated projects in this personal repository.

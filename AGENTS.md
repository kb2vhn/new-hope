# New Hope — Agent and contributor engineering contract

This is New Hope's independent engineering, architecture, security, testing, and change-control rulebook. **Architecture documents are requirements, not claims that working security or an operating system exists.** Before material work read `README.md`, `docs/architecture/ARCHITECTURE.md`, `docs/architecture/DECISIONS.md`, `docs/architecture/OPEN-QUESTIONS.md`, `docs/roadmap/ROADMAP.md`, `docs/development/VALIDATION.md`, and the relevant component README.

## Binding system design

- **One independent Rust microkernel OS**, x86-64 QEMU/IdeaPad first, ARM64 later. Not a Linux/FreeBSD distribution, MINIX fork or assumed POSIX clone.
- Privileged kernel owns execution/scheduling, CPU interrupt/exception entry, physical/virtual memory mechanisms and isolation, primitive IPC, and **mandatory UMI enforcement**. Kernel internal calls/CPU interrupts are not UMI RPCs.
- Every external-to-kernel and external-to-external privileged request goes through the logical named, typed **UMI** authorization boundary. UMI is **a small, kernel-enforced policy/ACL engine**, not unrestricted IPC, textual TCP/IP RPC, a centralized proxy, or a browser-aware parser.
- Default deny; authenticated kernel-owned identity; explicit deny precedence; bounded operations, handles, messages and audit; no bypass via shared memory, device access, raw networking, child/helper escalation or optimized hot paths. A service name grants no authority by itself.
- External protected services administer policies, files/ACLs, drivers, networking, user sessions, account recovery, logging, shell and backup. Do not drag application parsers, filesystem path ACL evaluation, TLS inspection or policy compiler into kernel.
- Native stateful firewall is **mandatory in the isolated networking service**, independent of general UMI network permission. No unnecessary packet round trips or silent fail-open if firewall enforcement dies.
- Browser extensions, webpage origins and browser credentials belong to the **browser**, not UMI. HID/global keyboard recording, screen capture, clipboard monitoring and input injection require separately authorized OS capability.
- User/file/admin/DR/OPS/SecAuditor/RECOVERY rights are separate and narrowly scoped. A filesystem admin is not an automatic content reader, a backup operator is not a file owner, and DR is not general root. Respect ADR-0006 through ADR-0011.
- Root authority never justifies bypassing an enforced security lock, protected journal, hold, or independent service boundary. Where hardware trust is absent, **disclose the real assurance limit**.

## Authorization, code and performance

- For each operation check *actual* calling identity, endpoint, operation, delegated authority, resource limits and relevant state; make ambiguity, malformed requests, stale/expired handles, missing policy or policy-service failure fail closed.
- App-created children may have **equal or reduced authority, never greater**. The kernel owns immutable parent-child lineage: no child takeover, detachment, orphaning, self-reparenting or supervisor adoption. If a parent exits, crashes or is killed, terminate its **entire descendant tree** and revoke descendant UMI authority before further execution. An independently authorized system service has its own designated protected supervisor, not a lifecycle escape for an app-created child. A user-requested launch is separate and independently authorized; do not confuse `spawn` shortcuts with authentication. Protect against privileged helpers laundering caller permissions.
- Put only minimal verifiable mechanisms in kernel. Prefer bounded simple modules, explicit interfaces, minimal dependencies, and measured costs. Source code should remain auditable on constrained physical targets.
- Prefer freestanding Rust for kernel (`no_std` as appropriate), tightly scoped documented `unsafe`, clear architecture-specific modules, explicit ownership/invariants, deterministic builds and no placeholder success. Do not select Rust stable/nightly, bootloader crates or OS ABI on assumption.
- Avoid surprise allocations, implicit background workers, unnecessary copies or proxy hops, unsafe DMA, unbounded logging or lock contention in critical paths. An optimized data path must preserve the authorization contract.

## Security-state protections

- Filesystem: independent directory Traverse/List/Create and file Read/Write/Execute; explicit ACLs; parent-designated owner and distinct creator; **no world-access permission or chmod 777**. File owners may grant ordinary group access only to their groups; assigning to special `users` requires administration. Ordinary users cannot `chown`. Admin content access requires journaled takeover + grants, not implicit read.
- Explicit narrow elevation (`doas`-like) and time-bounded `eu -`; session idle limit capped by system configuration; user configuration cannot broaden it.
- High-confidence administrative security lockdown affects base identity and all attributable tasks including elevated processes, **freezing** rather than silently logging out. DR recovery never auto-resumes suspicious frozen tasks. DR can inspect only processes of security-locked accounts.
- Dedicated OPS, DR, SecAuditor, boot-only RECOVERY are accounts, **not ordinary assignable groups/roles**. Generic protected password-policy errors; no cross-account credential reuse. Boot RECOVERY cannot unlock an incident-locked identity; only DR reviews it.
- Security journals are append-only, verified where possible, sealed and subject to retention/holds; never edit historical accepted entries. Log failures and limitations, not an invented success. Journal threshold comparison basis is **open** even though its initial value is 10%.
- Backup, restore, system-state recovery and administrative/litigation holds have distinct authorization. No general file-read privilege is implied by initiating backup/recovery or administering a hold. Preserve original paths/metadata and independently authorize restore.

## Implementation gates and tests

1. **G0:** read-only inventory of workstation and IdeaPad environment; non-destructive QEMU plan.
2. **G1:** freestanding x86-64 QEMU kernel prints deterministic serial message and halts safely.
3. **G2:** memory, exception and interrupt mechanisms; memory protection tests.
4. **G3:** two isolated user-mode tasks and controlled kernel entry.
5. **G4:** authorized and denied UMI request/reply with bounded audit.
6. **G5:** service restart, revocation, stale handles, malformed/oversized requests; parent death cascades to all descendants without orphaning/reparenting.

Do **not** claim boot implies isolation, IPC implies authorization, documentation checks imply a kernel test, or QEMU behavior implies physical hardware support. Record `NotTested`, `Partial`, `Failed`, `Passed` distinctly and preserve failed runs. For negative tests specify exact threat, expected denial, actual result, platform and limits. Do not perform real NVMe writes, irreversible firmware/key changes, or physical-board provisioning without a separate approved plan.

## Decision maturity and documentation discipline

- **Accepted:** Binding architectural direction, not proof of an implementation or a commitment to unspecified interfaces.
- **Open:** Unresolved engineering question; decide and record it before implementing the affected mechanism, without blocking unrelated earlier gates.
- **Illustrative:** Nonbinding command, path, ACL, schema, diagram or pseudocode; never silently promote it into an ABI or standard.
- A document may contain all three kinds of material. Keep them distinguishable and require explicit review before an Open or Illustrative design becomes Accepted.

## Documentation and repository hygiene

- Keep `README.md` brief, detailed architectural design under `docs/architecture`, gate planning under `docs/roadmap`, and actual procedures/tests under `docs/development`/`docs/validation`.
- Maintain ADR history. New decisions require rationale, options, tradeoffs, risks, tests and explicit owner approval. Do not silently alter accepted boundaries. Examples are not frozen syscall names/JSON schemas.
- No claims of implemented UMI, signed boot, log verification, HIDS, filesystem security or application compatibility without observed results.
- No secrets, recovery codes, private keys, account verifiers, traces with personal data, raw disk images, Rust `target/`, editor swaps, or machine secrets in repo. No references to unrelated projects in this personal repository.
- No license has been selected. Do not add one without approval.

## GitHub change control — strict

**Approval for one action is not approval for subsequent actions.** Without explicit user authorization for the **specific** remote write do not commit, push, merge, open/close a PR, create/delete branches or tags, change repository/ruleset settings, license or publish releases. Inspection, drafts, reviewed patches and uncommitted local preparation are permitted.

Before an approved commit, inspect `git status --short`, `git diff --check`, `git diff --stat`, the complete diff and staged paths. Never stage unreviewed artifacts en masse. After an approved remote action, fetch/verify the resulting object and commit. If a tool denies a write, report it; do not assert success. The smallest correct mechanism beats an oversized superficially functional subsystem.

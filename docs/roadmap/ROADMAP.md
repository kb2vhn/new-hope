# New Hope — Acceptance roadmap

**As of 2026-10-16, no executable acceptance gate is complete.** Project is documentation-only. Passing scaffold checks does **not** mean the kernel boots or protections work. Gates are acceptance criteria, not calendar promises.

## First implementation: x86-64 QEMU, then Lenovo IdeaPad

### G0 — Workstation and target inventory

Inventory actual workstation Rust/Cargo/QEMU/firmware availability, x86-64 cross-build path, serial debugging, selected boot process, plus non-destructive IdeaPad CPU/UEFI/disk characteristics. Identify preservation/rollback plans; do not modify the IdeaPad disk in G0. **Pass:** documented actual environment, build and test plan, tool versions, confirmed non-destructive image path.

### G1 — Deterministic kernel boot

Minimal freestanding Rust x86-64 kernel prints build/version and serial message in QEMU, then halts safely. No storage, network, UMI services, file ACLs or required heap. **Pass:** reproducible build, boot command, captured serial output, safe halt.

### G2 — Core protected mechanisms

Exception/interrupt receipt, initial memory map/protected mappings, bounded early resource handling. **Pass:** observed positive and negative exception/memory behavior, no false UMI claim.

### G3 — Independent user-mode tasks

Two protected address spaces, controlled kernel entry, kernel-sourced caller identity. **Pass:** valid entry works; unauthorized kernel or other-process memory access fails.

### G4 — UMI authorization

Typed/named IPC between isolated callers; operation-specific allow and deny before delivery; bounded audit. **Pass:** direct allow/deny/forged-source tests with recipient healthy, documented costs.

### G5 — Recovery and revocation

Kill/restart a service; stale authority denied, failures bounded, malformed/oversized messages rejected, policy revocation honored. **Pass:** repeatable negative tests, no convenient bypass or fail-open.

## Later separately approved milestones (sequence to refine)

1. **OS service and account foundation:** supervision, trusted authentication, multiuser sessions, process creation/delegation, UMI policy administration, native command executor, basic bundled utilities.
2. **Storage and file authorization:** drivers, filesystem, object IDs, owner/creator, independent directory/file ACLs, journaled ownership recovery, file utility acceptance.
3. **HID and UI:** trusted input, focused dispatch, raw monitoring denial, screen/clipboard capability separation.
4. **Networking:** protected drivers, IP networking, isolated stateful bidirectional firewall, performance and no-bypass tests; then remote logging and optional TLS diagnostic key export.
5. **Security operations:** native protected journals and retention, DR/OPS/SecAuditor identities, restricted `eu -`, high-confidence account-wide lockdown, frozen-task attribution, integrity recovery.
6. **Continuity and protection:** owner opt-in backup and original-location restore, system-state recovery, litigation holds, SecAuditor discovery, boot RECOVERY and platform trust/rollback defenses.
7. **Portability and applications:** physical IdeaPad acceptance followed by ARM64 bring-up on explicitly selected hardware, then editors, Go/Rust application runtime, optional interpreters and other facilities.

The sequencing above is **not** an assertion that final protected account recovery can be secure before verified boot/secure persistent state. Each later gate must declare dependencies, environmental limits and adversarial tests before implementation begins.

## Reports and change control

Write reproducible test records under `docs/validation/` with `NotTested`, `Partial`, `Failed` or `Passed`; capture exact revision, host/guest, tool versions, commands, expected/observed results, denial tests and known limitations. Never relabel an earlier failed attempt as passed. No real-disk/destructive work, GitHub branch/write, or hardware-key provisioning without explicit approval.

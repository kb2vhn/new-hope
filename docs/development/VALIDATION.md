# Validation and security acceptance policy

**No kernel, security, firewall, file, account, boot, backup or journal acceptance tests have passed.** Current GitHub Actions only checks documentation structure; that is not OS validation.

## Required record fields

For every real test record the date, revision, CPU/VM/firmware and OS/host, exact tool versions, input commands, intended behavior, actual output, outcome (`NotTested`, `Partial`, `Failed`, `Passed`), limitations, and any observed security impact. Never erase a failure by replacing it with a later successful run. Keep tests deterministic and nondestructive by default.

## Early gates

G0 inventory; G1 QEMU serial/halt; G2 exceptions/mapping; G3 attempted unauthorized memory; G4 authorized and denied typed UMI calls; G5 handle revocation, restart, malformed messages and bounded audit. Hardware verification requires actual hardware, not just QEMU.

## Later security acceptance matrix (design-stage)

| Security area | Essential negative test |
| --- | --- |
| UMI | Forged origin, explicit-deny override, unauthorized helper/delegation and stale handle |
| Filesystem | Traverse without List; List without file Read; create without ownership; illegal `users` group or world permissions |
| Admin | Normal admin unable to read private file; journaled takeover grants only specified rights |
| Elevated session | User `eu.timeout` cannot exceed global max; unrelated synthetic input cannot prolong privilege |
| Security lockdown | `eu -` offender's base identity and attributable child tasks frozen; no reboot/logout escape |
| DR | Can inspect locked-account processes only; cannot read memory/private files or lift own authority |
| RECOVERY | Boot-only code; resets protected account credentials, creates admin; cannot lift `SECURITY_LOCKED` |
| Networking | Explicit firewall destination deny despite UMI network allow; raw/driver bypass denied; fail-closed crash |
| HID | Unapproved global keyboard logging denied; focused input works; clipboard/screen privileges independent |
| Security journal | Changed/missing/rollback segment detected where claimed; full journal blocks sensitive mutations but preserves safe operations |
| Backup/restore | Backup operator cannot view owner files; restore only to original authorized path; symlink/collision attack denied |
| Hold | Backup opt-out overridden for held object; SecAuditor denied unrelated data; hold survives safe restart |

Some protections cannot be validated on hardware without a verified boot chain, DMA isolation or durable integrity anchor. Clearly report resulting lower-assurance behavior rather than treating this as a test pass.

## Reports and repository check

Real gate results should be filed in `docs/validation/`, e.g. `G0-WORKSTATION-IDEAPAD-INVENTORY-YYYY-MM-DD.md` or `G1-QEMU-X86_64-BOOT-YYYY-MM-DD.md`. Do not post secrets, recovery codes or hardware identifiers that are not needed.

`sh tools/verify-scaffold.sh` verifies the documentation contract and references only. It cannot substitute for later `cargo fmt`, clippy, tests, fuzzing, QEMU integration, and physical-board characterization.

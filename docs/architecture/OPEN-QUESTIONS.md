# New Hope — Explicitly open architecture questions

**Accepted principles are in the ADRs.** An illustrative path, command, policy line or format is not an approved ABI or implementation detail. These issues are not licenses to silently weaken UMI or least privilege.

| Topic | Open engineering/design question | First relevant stage |
| --- | --- | --- |
| Workstation / IdeaPad | Actual build host toolchain, target CPU/UEFI, disk safety, QEMU boot method | G0–G1 |
| Rust / boot | Stable versus nightly, pinned compiler/tool versions, signed-image format, bootloader | G0–G1 |
| Portable kernel | Abstract interrupt/page-map interfaces; planned ARM64 board and bring-up | G1 and later |
| Scheduler | Algorithm, SMP, interrupt preemption, priority inversion, freeze implementation | G2+ |
| UMI | Syscall ABI, typed envelope, versioning, endpoint naming/handles, revocation, safe fast paths | G3–G5 |
| Policy | Rule matching/precedence representation, atomic install, delegation of child strict-subset rights, user-intended execution authorization | G3–G5 |
| User input | Trusted authentication UI, session focus, HID capture/accessibility, clipboard and screen capture | Later |
| Filesystem | On-disk format, directory entry rights, ACL inheritance details, rename/hardlinks/symlinks, file execute inheritance | Later |
| Private files | Metadata visibility without leaking content; parent ownership, creator rights, admin takeover atomicity | Later |
| Authentication | Credential store, salts/verifiers, unique protected passwords, account lifecycle, sealed credential recovery | Later |
| Security lock | Safe freeze of all attributed work; pending shared-service operations; process disposition after DR recovery | Later |
| Journal anomaly | **Meaning of 10%**: comparison baseline, measurement interval, rate / type decision criteria | Before containment implementation |
| Journal integrity | Canonical encoding, crash-consistent append/seal, retention retirement, independent checkpoint anchors, remote forwarding | Later |
| Security journals | How to recover from corruption without bypassing locks or losing DR audit | Later |
| Backup | Owner enrollment inheritance, opt-out boundaries, snapshot/storage format, backup metadata inventory, restore collision and overwrite policy | Later |
| Litigation hold | Who activates/release holds; scope of creator-owned versus owner-owned objects; retention authorization | Later |
| SecAuditor | **Does Execute mean running held binaries or only Traverse?** Scope of export authority and read-only discovery | Before auditor implementation |
| System restore | OS-state versus `/projects` backup integration; persistence of independent journals/holds/locks | Later |
| Hardware trust | Exact IdeaPad Secure Boot keys/TPM; ARM64 hardware root; anti-rollback limits | Later |
| RECOVERY | Code verifier, rate limiting, root-of-trust and anti-rollback protection, trusted recovery environment | Later |
| Networking | Driver/DMA bypass, conntrack, IPv6, queue bounds, firewall crashes, data-plane efficiency | Later |
| Compatibility | Native ABI for Go/Rust/tools; optional POSIX/Bash/Zsh compatibility; licensing | Later |
| Native executor | File preferences syntax, aliases, command chaining grammar, command search path | Later |

The initial x86-64 QEMU → IdeaPad sequence is **decided**, even though the exact board details are not verified. ARM64 remains a later goal, with physical board choice uncommitted.

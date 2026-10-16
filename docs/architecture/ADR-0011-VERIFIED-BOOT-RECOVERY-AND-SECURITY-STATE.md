# ADR-0011 — Verified boot, boot-only RECOVERY, and persistent security state

- **Status:** Accepted high-level model; platform trust and recovery storage mechanisms open
- **Date:** 2026-10-16

## Boot assurance

- One portable OS supports three **explicitly reported** boot assurance levels: `Development` (no mandatory signature enforcement), `SoftwareVerified` (signed component checking without hardware-anchored verifier), and `HardwareRooted` (firmware/hardware authenticates the verifier and chain where supported and provisioned).
- Owner-controlled trusted signing keys are preferred. Hardware support must be **verified per board**; x86-64 QEMU and the IdeaPad are first targets, ARM64 hardware later. An unsigned first-boot QEMU experiment is allowed as development, not a production security claim.
- Signing a kernel does not by itself protect all persistent state. Replay/rollback of security journals, holds, or locks requires separate protection/verification; local hashes alone do not resist an attacker replacing both stored records and anchors.

## Boot-only RECOVERY account

- On initial installation, generate an unpredictable **26-character alphanumeric recovery code** using a cryptographically secure randomness source. Display it once, require the installer to acknowledge safe preservation, and never re-display or log the plaintext. Store only protected verification material. If the code is lost, there is **no undocumented master override**; inaccessible protected accounts may remain unrecoverable.
- At the **boot menu**, a physical operator types `RECOVERY` to enter a restricted local recovery environment, then authenticates using the code. This is **not an ordinary interactive account, shell, remote access service, or `eu -` capability**.
- RECOVERY may **reset OPS, DR and SecAuditor credentials** and **create a new administrator account**, under narrow independent authorization and protected journaling. It cannot perform their operations, read ordinary private files, change UMI/firewall/security policy, erase incidents or modify security journals.
- Crucially, **RECOVERY cannot unlock a `SECURITY_LOCKED` account**. Only DR can review and clear that incident lock (ADR-0007); an administrator created via RECOVERY does not inherit DR authority.

## Protected persistent state

- Security locks, identities, privileged journal integrity/retention, litigation holds, and incident restrictions survive reboot independently of ordinary system-state restores. Reverting to an older disk image may not silently clear those controls on hardware with a valid protected state anchor.
- Frozen process RAM is not expected to survive normal power loss. Persist identity, incident and process records; **do not restart processes attributable to locked accounts** automatically after boot.
- If security records are demonstrably missing, corrupted, or unverifiable, **allow safe ordinary operations where possible but prohibit new privileged security modifications**. Preserve available diagnostics and incident state. DR may review within its narrow rights; neither DR nor RECOVERY may bypass enforced integrity restrictions simply to proceed.
- Explicitly distinguish `IntegrityFailed` from `Unverifiable` (e.g., weaker hardware assurance). Record the difference. Complete guarantees require tested trusted boot and rollback-resistant anchors.

## Unresolved

Verified-boot key lifecycle, firmware ownership, TPM/secure element/IOMMU availability, journal integrity anchor, anti-rollback implementation, RECOVERY verifier protection and retry limits, lost-code handling, encrypted-data recovery without keys, offline restore authorization, state repairs under corruption, and how new-admin creation is protected from a physical attacker.

## Tests required

QEMU development first boot; signed-component failure; changed boot verifier under available hardware assurance; boot RECOVERY menu/auth; recovered protected credentials cannot clear incident locks; create admin but no DR authority; journal rollback detection where claimed; persistent locked account after reboot; no auto-restart of locked processes.

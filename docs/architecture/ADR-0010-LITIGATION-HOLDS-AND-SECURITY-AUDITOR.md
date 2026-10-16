# ADR-0010 — Administrative/litigation holds and SecAuditor access

- **Status:** Accepted preservation/identity intent; hold authorization and Execute scope open
- **Date:** 2026-10-16

## Context

Ordinary owner-controlled backup enrollment cannot suppress legally or administratively required preservation. Hold access must not create generalized administrator or auditor file privileges.

## Decision

- An authorized **administrative/litigation hold** on account `userk` causes **all in-scope data to be snapshotted and preserved**, including files normally excluded from personal backup. Retain stable object IDs, original paths, owner and creator, timestamps, ACLs, relevant versions, changes and deletions during the hold.
- A hold is a separate immutable security-state object with case identity, effective activation, scope and retention/release conditions. Users cannot disable holds by toggling the backup property, moving, renaming or deleting files.
- **SecAuditor is a dedicated, authenticated physical local account, not a role/group.** Its authorized discovery/read access extends **only to file objects within active administrative/litigation hold scope**. It does not gain ordinary access to unrelated files or user processes and cannot change ownership, ACLs, hold content, UMI policy or security journals.
- SecAuditor's directory traversal and listing for authorized scope must not reveal unrelated private content by accident. Audit all hold changes, discoveries, accesses, exports and releases in protected journals.
- No ordinary administrator, OPS, DR, or backup operator acquires SecAuditor held-content access just from their account designation.

## Important unresolved decisions

- **Who can activate, amend, and release a hold**; what secondary approval is required; whether the hold originator can also read the held data.
- **Scope:** Account-owned files outside `/home`, files **created** by the subject but owned by another identity, shared content and shared-directory snapshots. This needs an explicit scope contract, not guessing from a home-directory prefix.
- User referred to SecAuditor `read/execute` rights, but New Hope separates file Execute from directory Traverse. **Do not assume SecAuditor may run potentially hostile held executables.** Decide whether Execute was intended to mean actual code execution or traversal/metadata discovery.
- Retention/release and export authorization, legal review/audit chain, preservation with offline storage and secure data destruction after lawful release.

## Tests required

Hold overrides opt-out; preserved file after rename/delete; unchanged journal history; SecAuditor read on held vs denial on unrelated objects; no arbitrary content export, policy edit, group changes or process memory read; hold survives reboots and restore without rollback.

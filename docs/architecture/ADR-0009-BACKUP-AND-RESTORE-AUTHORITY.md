# ADR-0009 — Owner-controlled backup, protected backup service, and restore rights

- **Status:** Accepted authorization boundaries; snapshot/storage implementation open
- **Date:** 2026-10-16

## Backup classes

1. **Owner-opted personal backup:** Owners decide whether files they own are eligible for ordinary user backups. By default files in `/home/<user>` are **not backed up unless explicitly enrolled** under their applicable backup policy. An administrator cannot silently enroll someone else's private file to obtain its contents; documented audited ownership-recovery rules remain separate.
2. **Shared-folder backup:** Shared operational areas such as `/projects` are protected under their authorized shared-directory backup policy, independently of any individual's home backup preference.
3. **System-state backup:** OS installation state, protected configuration, services and applicable shared/system data needed to restore a functioning system to a recorded state. This is not an automatic full plaintext extraction of every user's private home directory.
4. **Administrative/litigation hold:** Mandatory preservation of held data **regardless** of opt-in; see ADR-0010. Hold is not an ordinary recoverable user backup preference.

## Identity and inventory

- `system.backup` is a noninteractive, protected execution identity with scoped authority **only during authorized backup/restore operations**. The operator does not receive file Read authority merely by starting the job.
- Maintain an authoritative/reconciled **inventory of backup-enabled files** including stable object identity, **original path**, current owner, creator, applicable ACL/metadata, eligibility, change/move history and successful backup version identifiers.
- `system.backup -user jwood` means **eligible files whose owner is `jwood`**, not all files created by them under other people's directories. `system.backup -system` means all eligible files across owners under the applicable backup policy. Exact command spelling is illustrative.
- OPS is a dedicated local account that may designate a backup **operator** and a separate recovery **operator**. OPS is not made file owner or plaintext reader through these assignments.

## Separate authorizations

- `backup.initiate.user`, `backup.initiate.system`, `backup.restore.original`, `backup.inventory.view` and direct `backup.content.read` are **distinct authorities**. Operators cannot automatically read stored backup data or export it.
- Restore is an independently permitted operation to write **the recorded original content and metadata to the authorized original path**. This is not a general write grant, nor permission to restore elsewhere. Path ownership changes, collisions, symlinks, object replacement, or unsafe targets require safe conflict handling; do not silently overwrite.
- A restore attempt is journaled with source backup version, requester, destination and result. Hold-retained data is subject to hold preservation and disclosure rules.
- Encrypt/protect stored backups, job secrets and restore credentials by policy; users, operators and OPS must not obtain unrelated owner plaintext through archives or unscoped restore.

## Open design points

Directory backup-property inheritance, opt-in coverage over renamed objects, snapshot consistency and open-file semantics, storage encryption/key recovery, shared-folder policy owner, system-state image scope, retention, deduplication, restore conflict handling, metadata rebinding and offline integrity validation.

## Tests required

Opt-out personal file excluded; opted-in owner backup; owner-versus-creator mismatch; system operation across enrolled owners; ordinary operator cannot read content; restore original path only; symlink/directory substitution blocked; backup flag cannot be misused by admin to bypass privacy; shared `/projects` coverage.

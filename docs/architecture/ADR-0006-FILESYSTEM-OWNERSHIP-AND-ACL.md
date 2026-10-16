# ADR-0006 — Filesystem identity, inheritance, and least privilege

- **Status:** Accepted access model; filesystem and ACL encoding open
- **Date:** 2026-10-16

## Context

Familiar file utilities are wanted, but New Hope must not duplicate POSIX's world-access class or overload directory execute/traverse semantics. Admin authority must not silently expose private file contents.

## Decision

### Identity and creation

- Record **owner** and **creator** separately as authenticated identities. Under a directory whose owner is `jwood`, objects normally inherit owner `jwood`. Under a directory owned by another identity, newly created objects inherit that directory's designated owner, while `jwood` remains their recorded creator if they performed the create. An inherited directory-owner rule must be enforced against the actual parent, not a superficial pathname prefix.
- Creating an object requires **Create** authority for the parent and gives the creator **no implicit ownership, ACL management, or content access** when those belong to someone else.
- New files created in the owner's own area default to **owner Read+Write, no Execute, and no other principals**. New directories start with minimum needed owner access. A directory's intentionally configured inherited ACLs may further restrict or grant specific rights; they never create world access.

### Independent permissions

- **Directory:** `Traverse`, `List`, `Create`, entry `Rename/Modify`, entry `Delete`, `ManageACL` (with precise semantics to be engineered).
- **File:** `Read`, `Write`, `Execute`, `ManageACL`, plus separately governed ownership and backup/preservation properties.
- Directory **Traverse** grants passage along a known path, not listing. `List` reveals names, not file bytes. `Read` of a file is a separate check; `Execute` of a file is distinct from directory traversal.
- Per-permission inheritance may be configured on directory trees, including file `Execute` for descendants where explicitly established. A descendant may break inheritance or explicitly deny the inherited permission; **deny wins**. Directory Traverse or List never implies file Read or Execute.
- Resolve hard links, symbolic links, moves and path substitution without bypassing object-level or ancestor authorization; precise treatment is open.

### User, group, and administrator authority

- There is **no `other/world` permission class** and no equivalent of `chmod 777`.
- Owners may change permitted ACLs on files they own, granting to ordinary groups **only if they belong to the group**. Non-owners do not gain ACL authority by creating an object. Ordinary users cannot `chown`.
- A special `users` group may be assigned to a file/directory **only through authorized administration**, even if the owner belongs to that group. Membership alone neither grants access nor allows assignment.
- Admins may inspect directory/file structure and authorized metadata, **not private content by default**. Ownership takeover and subsequent grant of Read/Write/Execute must be **separate, authenticated, journaled administrative changes**; such changes do permit resulting access, but not silently.
- FS service performs object-specific ACL/metadata checks. UMI controls the caller's authority to invoke those operations; kernel policy does not parse individual file ACLs.

### Explicitly not a general root bypass

An administrator may perform audited ownership recovery if permitted by policy. This is not implicit universal read authority; restricted accounts, protected journal records, and system security locks cannot be bypassed by arbitrary `chown` or raw disk access.

## Unresolved

Native on-disk filesystem, metadata and directory-ACL format; ACL masks and group precedence; file `Execute` inheritance into new files; directory entry Rename/Delete semantics; ownership changes on moved/renamed items; existing inherited grants versus user private default; snapshot and link object identity; performance under large ACLs.

## Tests required

Traverse-without-List; List-without-file-Read; Create-without-ownership; owner/creator mismatch; deny precedence; `users` group prohibition; no world permission; administrative metadata versus file read; journaled takeover; hardlink/symlink/move bypass attempts.

# ADR-0007 — Authenticated identities, elevated sessions, protected accounts, security lockdown

- **Status:** Accepted requirements; authentication, persistence and scheduler mechanisms open
- **Date:** 2026-10-16

## Normal authentication and elevation

- New Hope is multiuser, with separate accounts, sessions, process identities, execution authority and immutable origin/initiator attribution. Multiple sessions do not merge privileges.
- Administrators normally run applications as unprivileged users. Like `doas`, **single-command elevation** requires explicit, authenticated authorization. Authentication is not an override of UMI explicit denies.
- `eu -` enters a separately authorized administrative environment (`#` prompt) while keeping the **underlying user identity** and process attribution. `exit` or `end` returns to normal (`>` prompt).
- Default elevated-session inactivity timeout is **10 minutes**. Monitor authenticated interaction while waiting for a command, and start/resume the idle timer after a foreground command completes; do not kill a legitimate foreground command simply due to the timer. Unrelated/synthetic input cannot refresh it. Global maximum is protected system policy. Users may set `eu.timeout` in a restricted preference file only to a **shorter** value. Timeouts revoke elevation, not account identity.
- Routine authorized administrators may reset other administrator credentials. A **security lock cannot be cleared by an ordinary admin reset**, reauthentication, a new `eu -` session, account modification or a new admin created by RECOVERY.

## Dedicated physical local accounts — not roles/groups

- `OPS`: narrowly administers assignment of **backup and restoration operators**, not protected file contents. The exact OPS configuration surface is separate from DR.
- `DR`: break-glass account for inspecting security/system journals and **only processes attributable to security-locked accounts** (metadata/status, not private process memory); restoring authorized network service operation; administering the protected journal anomaly threshold; reviewing and recovering security-locked administrator/base accounts. DR has **no arbitrary file read, group grants, ACL changes, process intervention, hold content access, or general UMI/firewall configuration authority**.
- `SecAuditor`: dedicated discovery/read identity **only for held data** under valid administrative/litigation-hold scope; not an administrator, owner, or arbitrary filesystem reader. Exact file-execution authority is open; see ADR-0010.
- `RECOVERY`: dedicated **boot-only** identity documented in ADR-0011, not normal login or an override of DR lock clearance.
- `system.backup`: separately restricted **service identity**, not an interactive privileged user; see ADR-0009.
- Protected local accounts have independent credentials, different from one another and administrator credentials. Password-policy rejection uses a **generic message**, including when a candidate matches another protected account. Independently salted verifiers must be checked with the candidate against each stored verifier; equality of salted hashes is insufficient. Fail closed if uniqueness cannot be checked. Precise verifier protocol is open.
- These accounts cannot elevate themselves into universal root, silently change their own policy, or impersonate each other.

## Security lock and process freezing

1. A high-confidence privileged security incident changes the **underlying user account** to `SECURITY_LOCKED`, including when the incident occurs inside `eu -`. All that user's sessions lose authority to continue and reauthenticate.
2. Every process **attributable to the locked initiating identity** is **frozen by scheduler/authorization enforcement, not merely logged out or terminated**. Child and separately elevated processes retain origin attribution. In-flight work in shared services is safely isolated; freezing one user must not suspend unrelated users' shared services.
3. The lock, causal incident, process inventory and restrictions persist durably across reboots. Volatile frozen RAM state does not survive an ordinary reboot unless explicit checkpointing is developed. Processes must not be auto-restarted under the locked identity.
4. DR may view **process identity, status and metadata of locked accounts only**. It cannot list unrelated users' processes by virtue of DR authority, read their memory, change their ACLs, resume/kill arbitrary frozen processes, or grant itself elevated privileges.
5. DR review authorizes recovery and new credentials, invalidating prior sessions. **Account recovery does not automatically resume frozen processes or erase the incident.** Those processes require a separately authorized disposition mechanism still to be designed.
6. Suspending a session for security reasons must be attributable and tested against malicious log spam, request floods and false-positive containment; a general journal rollover is not alone proof of compromise.

## Consequences and open details

Trusted authentication UI, account database, credential uniqueness and verification cost, security-lock persistence, scheduler freezing, in-flight operation rollback, frozen process disposition, independent high-assurance DR recovery, denial-of-service protections, and DR inability to bypass an integrity failure require design and tests.

## Tests required

Privilege elevation and idle timeout; shorter user setting and global maximum; failed direct content access by admin; authenticated session reentry; account-wide lock across `eu -`; frozen process origin attribution; unaffected other users; DR metadata-only view; normal admin reset denied on locked account; DR review without automatic process resumption.

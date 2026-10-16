# ADR-0003 — UMI policy, execution authority, and administration

- **Status:** Accepted architecture direction; ABI, policy syntax, and delegation mechanics open
- **Date:** 2026-10-16
- **Builds upon:** [ADR-0002](ADR-0002-UMI-ENFORCEMENT.md)

## Context

New Hope needs one native, understandable policy model resembling firewall rules and ACLs, not independent opt-in sandbox stacks or application-specific hardcoded kernel behavior. The privileged kernel remains small; configuration and compilation stay outside it.

## Decision

1. UMI authorizes **authenticated caller identity, destination, requested operation, valid delegated authority, context where relevant, and bounded resources**. Names are discovery, not authorization. Kernel-derived identities cannot be supplied by untrusted payloads.
2. Policies are administrator-controlled and inspectable. **Default deny** and **explicit deny precedence** apply. A general allow to contact a service is not permission to access every resource behind it. The destination service applies its own resource ACL.
3. A separately protected policy controller validates and installs compiled, immutable policy revisions atomically; normal enforcement cannot require asking the controller for every request. A controller outage does not fail open. Changes to policy, identity, revocation and denial are auditable.
4. App-created child processes receive **strictly reduced delegated authority** compared with their parent; creation never expands effective authority. The mechanics for expressing a proper subset without preventing trivial helpers remain open.
5. A **user-requested launch** through the native executor is a distinct, independently authenticated/policy-checked process-manager operation. The prompt does not grant arbitrary authority to the launched program, and an application must not impersonate a user-initiated launch to escape delegation restrictions.
6. Privileged services must enforce authority on the actual request, guarding against a confused-deputy path through another service or transferred handle. Shared-memory grants and privileged device access are checked, not implicit bypasses.
7. An elevated operation is independently authorized. Normal user sessions remain least-privilege even for administrator accounts. See [ADR-0007](ADR-0007-IDENTITIES-PRIVILEGE-AND-LOCKDOWN.md).
8. UMI has no knowledge of browser extensions, page contents, encrypted protocol payloads, or per-application business rules. Operating-system mediation ends at enforceable OS boundaries.

## Consequences and invariants

- Policy checks are mandatory for defined trust crossings; **not every kernel-internal call or Ethernet packet is an RPC**.
- Service-specific semantics, file paths/ACL evaluation and browser extension policy stay with their responsible services/apps.
- Authorization and logging costs must be bounded. Cacheable authorized handles may be used only with correct revocation and failure behavior.

## Unresolved

Policy representation and matching precedence within a category; stable subject/resource identity; strict-child permission subset semantics; authenticating user-intended launches; handle transfer; expiry/revocation; direct data-path equivalence; atomic install/rollback; audit backpressure.

## Tests required

Positive and negative UMI checks; explicit-deny overrides; forged identity; child escalation attempt; helper/confused-deputy attempts; handle replay and revocation; policy-service failure; low-cost repeated authorized operations.

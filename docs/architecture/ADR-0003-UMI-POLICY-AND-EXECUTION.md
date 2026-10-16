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
4. App-created child processes may receive **equal or reduced effective authority**, never more than their parent. Equality is allowed; no child gains higher effective privileges through creation, delegation, or a parent policy change. Authority remains constrained by applicable UMI policies and revocation.
5. A **user-requested launch** through the native executor is a distinct, independently authenticated/policy-checked process-manager operation. The prompt does not grant arbitrary authority to the launched program, and an application must not impersonate a user-initiated launch to escape delegation restrictions.
6. Privileged services must enforce authority on the actual request, guarding against a confused-deputy path through another service or transferred handle. Shared-memory grants and privileged device access are checked, not implicit bypasses.
7. An elevated operation is independently authorized. Normal user sessions remain least-privilege even for administrator accounts. See [ADR-0007](ADR-0007-IDENTITIES-PRIVILEGE-AND-LOCKDOWN.md).
8. UMI has no knowledge of browser extensions, page contents, encrypted protocol payloads, or per-application business rules. Operating-system mediation ends at enforceable OS boundaries.
9. **Parent-child lineage is immutable and kernel-owned.** An application child may not impersonate, replace, supervise, adopt, detach from, or reparent itself above or away from its parent. Upon any parent termination (normal exit, crash or forced kill), the kernel terminates **all descendants transitively**; they never continue as orphans. Deny continued execution and authority use during teardown, revoke descendant UMI handles/grants as appropriate, and ensure bounded cleanup of outstanding operations. An independently authorized system service belongs to its designated protected supervisor, not a convenient adoption/reparenting path for application children. A broker may not launder lifecycle or caller authority.

## Consequences and invariants

- Policy checks are mandatory for defined trust crossings; **not every kernel-internal call or Ethernet packet is an RPC**.
- Service-specific semantics, file paths/ACL evaluation and browser extension policy stay with their responsible services/apps.
- Authorization and logging costs must be bounded. Cacheable authorized handles may be used only with correct revocation and failure behavior.

## Unresolved

Policy representation and matching precedence within a category; stable subject/resource identity; equal-or-reduced child authority representation and dynamic revocation; authenticating user-intended launches; immutable process-tree identity; transitive termination ordering, in-flight requests and bounded cleanup; handle transfer; expiry/revocation; direct data-path equivalence; atomic install/rollback; audit backpressure.

## Tests required

Positive and negative UMI checks; explicit-deny overrides; forged identity; equal-authority child allowed and escalation denied; detach/reparent/parent-impersonation attempts denied; normal, crash and forced parent termination cascade to children and grandchildren; no residual descendant execution or UMI grants; broker/supervisor laundering attempts; handle replay and revocation; policy-service failure; low-cost repeated authorized operations.

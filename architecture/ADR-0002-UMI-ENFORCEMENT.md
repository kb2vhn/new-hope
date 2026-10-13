# ADR-0002 — Mandatory Unified Message Interface

- **Status:** Accepted
- **Date:** 2026-10-13
- **Context:** Ordinary IPC alone does not meet the project's requirement for security policy at every external communication boundary.

## Decision

Any component outside the microkernel communicating with the kernel **or another external component** must pass through **UMI**, a logical named, typed, message-based contract enforced by the kernel. The model resembles network/RPC calls even when the transport is entirely local; it does not imply TCP/IP, HTTP, or text encoding.

UMI has NGFW-inspired **mandatory** authorization: kernel-authenticated caller identity; destination endpoint and requested operation; capability/policy; relevant request/session state; bounded resources; auditable decisions; and default deny. Service discovery does not itself grant authority. Shared-memory grants are controlled through the same enforcement boundary. Internal kernel operations and hardware interrupts are not RPC.

The **enforcement/data plane** stays tiny inside the kernel. A protected user-space **control plane** administers policy, with explicit narrowly authorized bootstrap behavior and no fail-open upon policy-manager outage. Application-specific resource checks remain the destination service's responsibility unless a later approved contract explicitly places them elsewhere.

## Alternatives considered

- Unrestricted process-to-process IPC: violates mandatory policy enforcement.
- One central user-space proxy for all privileged dispatch: creates an avoidable availability/security bottleneck and bypass risk for kernel calls.
- Full deep inspection of every service payload inside kernel: expands privileged complexity and attack surface.

## Consequences and open details

Exact message ABI, syscall shape, capability revocation, service names, policy encoding, audit durability, rate enforcement and remote transport are not yet selected. A fast path is permitted only if it proves authorization equivalence. Timeouts, replay, stale handles, failed services and audit backpressure must have testable semantics.

## Tests necessary

G3 kernel-verified identity and isolation; G4 positive and negative named-operation tests with audit; G5 stale handle, service restart, malformed request, and revocation tests. See [roadmap](../roadmap/ROADMAP.md).

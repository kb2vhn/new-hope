# ADR-0004 — Mandatory firewall in a protected networking service

- **Status:** Accepted architecture direction; implementation architecture open
- **Date:** 2026-10-16

## Context

A general UMI permission to use networking is **not** a grant to contact every destination. Network enforcement must be native, mandatory, stateful, efficient, and protected against hostile inbound traffic without growing the privileged microkernel into a full packet parser.

## Decision

- Implement the **stateful, bidirectional firewall in a protected networking service**, outside the microkernel, as an inseparable part of the normal network path.
- Separate packet-enforcement/data plane and protected administrative control plane. Untrusted packets cannot invoke policy-management authority; packet-driven state changes are validated and resource bounded.
- Default deny inbound unsolicited traffic and require authorized outbound policy; narrow explicit initialization allowances (e.g. DHCP) must not be a blanket bypass. **Explicit deny prevails over general UMI network permission.**
- Microkernel identity, memory, driver and device-access controls prevent raw sockets, alternate stacks, helpers, bridging, shared buffers, or direct NIC access from bypassing firewall enforcement.
- On firewall crash, invalid policy, or lost enforcement, **fail closed**: no fallback to unfiltered networking. Supervision/restart must respect connection state.
- Keep datapath efficient: avoid unnecessary copies, allocations, scheduling changes, central proxies, and one policy-management RPC per packet. Use authorized bounded/shared data paths if they preserve enforcement. Measure throughput, CPU, and latency.
- Do **not** require TLS/SSH interception, SSL bumping, or network plaintext inspection. Optional TLS-secret logging is an **administrator-authorized diagnostic interface** supported by a participating TLS library/application, not a built-in firewall MITM or a universal ability to decrypt packets.
- Host packet routing and device DMA controls remain mandatory security considerations; hardware IOMMU coverage varies by platform.

## Separate responsibilities

UMI: process/service authority to request networking. Firewall: packet/connection destination and policy decisions. TLS/SSH implementations: encrypted session security. Optional external proxy/appliance: any deployment-specific application traffic inspection.

## Unresolved

Protocol stack boundaries; driver isolation and DMA requirements; zero-copy buffers; conntrack limits/eviction; policy reload semantics; observability; IPv6 parity; packet-rate DoS controls; safe recovery of in-flight flows.

## Tests required

Inbound/outbound denial, established return flows, explicit destination deny from an otherwise network-authorized process, attempted driver/raw-interface bypass, service crash fail-closed, malformed packet/resource exhaustion, and measured overhead.

# New Hope — Rust Microkernel OS Architecture Baseline

**Status:** Agreed architectural direction; implementation not started
**Version:** 0.3 (repository-scaffold edition)
**Recorded:** 2026-10-13
**Project codename:** `new-hope`
**Canonical GitHub repository:** https://github.com/kb2vhn/new-hope.git
**Repository publication:** Local scaffold prepared; GitHub write access was denied (403) on 2026-10-13. No remote commit has been made.
**Purpose:** Preserve the design decisions made before development so a later session begins from the same architecture instead of revisiting it.

> **Scope of agreement:** The microkernel boundary, UMI-as-NGFW principle, named-call communication model, and intent to start extremely small are agreed. Detailed APIs, algorithms, binary wire layouts, toolchains, and boot components are *not* approved simply because examples appear in this document.

## 0. Project identity

- **Codename:** New Hope (`new-hope` in paths and tooling).
- **Repository:** `kb2vhn/new-hope`.
- **Documentation location:** `docs/architecture/ARCHITECTURE.md` in the prepared project scaffold.
- **Repository policy:** This scaffold was requested for the personal GitHub repository. Future remote writes require explicit approval for their particular scope.

## 1. Project goal and target machine

Build an independent operating system from the ground up in **Rust**, inspired by **MINIX-style microkernel isolation**, but **not** a MINIX fork or a requirement to emulate UNIX/POSIX. The user wants direct architectural control, a small initial system, fault containment, and deliberate engineering rather than a large framework or feature-heavy base.

Initial development machine:

- Lenovo IdeaPad with an Intel Core i3 (10th-generation family, model to verify).
- 12 GB RAM (verify at first working session).
- Planned Samsung 970 500 GB NVMe upgrade, replacing the original ~256 GB NVMe.
- Host OS and toolchain **not yet confirmed**.
- Initial kernel boots and tests in **QEMU**; physical IdeaPad boot comes **later** and must not overwrite the host disk as an early test.
- Target CPU architecture: **x86-64**.

## 2. Ratified architectural decisions

### DEC-001 — A genuine Rust microkernel

The goal is a freestanding Rust OS with a deliberately small privileged kernel and isolated external components. Starting from a kernel capable only of booting, reporting status, and halting is acceptable. Do **not** quietly substitute a monolithic Linux/FreeBSD-based design.

### DEC-002 — Mechanisms owned by the microkernel

The following belong **inside** the microkernel:

- CPU scheduling, context switching, and core execution/thread mechanisms.
- Hardware exception and interrupt handling and dispatch.
- Physical and virtual memory management, including address-space protection and mapping enforcement.
- Core IPC transport, endpoint/capability enforcement, and mandatory UMI enforcement.

The microkernel uses ordinary internal Rust/function calls for **internal** operations. CPU hardware interrupts enter through architectural interrupt paths; they are not fabricated as network requests.

### DEC-003 — UMI is universal at the kernel boundary

**Unified Message Interface (UMI)** is the mandatory communication boundary for **anything outside the microkernel** that communicates with:

1. the microkernel, or
2. any other external service/process.

This includes user applications, process-management services, storage and filesystem services, user-space drivers, terminal services, service management, and all other external components as they are built.

**The invariant:** No external component can bypass UMI authorization to invoke a privileged kernel action, interact with another isolated component, or establish shared communication resources.

UMI is a *network-call-like semantic model*, **not** a requirement to run TCP/IP/HTTP, do network I/O, or serialize human-readable strings for intra-machine messages. Local transport should be efficient kernel-mediated IPC.

### DEC-004 — UMI is an OS-level next-generation firewall

UMI must behave like a **next-generation firewall at the operating-system communication boundary**, not like an unrestricted event bus. For each controlled request, the kernel enforcement mechanism should be able to evaluate:

- **Authenticated caller identity:** derived from kernel-owned execution context, not blindly trusted from request payload.
- **Destination:** named service or kernel-facing operation, ultimately resolved to an authorized endpoint.
- **Operation/method:** what action is requested, not merely whether an endpoint exists.
- **Permission/capability:** caller's authority for this destination and operation.
- **Context/session state:** request-response correlation and permitted state transitions where relevant.
- **Resource controls:** message bounds and applicable quotas/rate controls.
- **Decision/accounting:** allow, deny, relevant failure, and appropriate audit information.

**Default deny.** Name discovery alone is not permission. Malformed messages and absent/invalid authority are rejected. There must be no implicitly trusted user-space bypass.

The resemblance to an NGFW is the **security model**. UMI need not deeply parse every service-specific payload inside the kernel: the kernel applies a small, verifiable protocol/authorization contract, while individual services perform their own resource-level authorization (for example, permission to read a particular file).

### DEC-005 — Separate minimal kernel enforcement from user-space policy administration

UMI's **enforcement/data plane** lives inside the microkernel and must stay minimal, bounded, and predictable. **Policy administration/control plane** belongs in a protected external service. The control plane may create and validate policy revisions, but cannot bypass the kernel's enforcement checks.

Loss or restart of the user-space policy service must not mean fail-open. An existing validated, installed enforcement policy continues operating, and unapproved changes are denied. Bootstrap authority must be explicit and minimal—not a blanket allow-all state.

### DEC-006 — Named, structured operations for all external calls

Callers conceptually use names such as:

- `kernel.memory` / `map`
- `kernel.task` / a defined task operation
- `system.process` / `spawn`
- `system.storage` / `open`
- `system.terminal` / `write`

These are **illustrative names only**, not finalized API names or an approved message schema.

Each operation should have defined identity, destination, method, version/compatibility contract, bounded arguments, and an outcome. Support for request-response and asynchronous notifications should be designed intentionally. The precise binary encoding, syscall ABI, endpoint-handle strategy, and timeouts are **open**.

A single **logical protocol** does not require a single hardware syscall or textual name lookup on every request. An initial authorized name resolution may produce a bounded endpoint/capability handle for efficient subsequent requests, subject to revocation and re-authorization rules.

### DEC-007 — User-space services remain protected and independently supervised

System-level services and hardware drivers are intended to be isolated **outside** the microkernel where practical, inspired by MINIX. A process manager, terminal, storage driver, service registry, and policy manager are eventual services, not things to implement immediately.

A failed service should be containable where technically possible. Service restart is **not** automatically equivalent to safe recovery: open handles, device state, pending operations, permissions, and client retries must be accounted for.

### DEC-008 — Authorized shared memory is an optimization, not a bypass

For bulk data later, explicitly granted shared-memory mappings may avoid extra copies. All creation, delegation, mapping, and revocation of such access must be authorized by the microkernel under UMI rules. Shared memory does not create an uninspected path for new permissions or service control.

### DEC-009 — Security and observability are designed into the mechanism

UMI should allow auditing of denied and relevant allowed communication, identity, operation, destination, policy decision, and correlated failures. Logging must itself be bounded and must not create an uncontrolled denial-of-service path. Do not assume a security policy protects against a compromised microkernel, DMA without adequate isolation, hardware compromise, or a legitimately authorized but malicious service.

### DEC-010 — Start extremely small; preserve the final architecture

The first result is a booting kernel in a virtual machine—not a complete OS, POSIX layer, driver stack, or elaborate policy engine. Temporary bootstrap shortcuts must be explicitly marked and removed before claiming meaningful process isolation or mandatory UMI enforcement.

## 3. Kernel and UMI boundary rules

| Interaction | Expected mechanism |
| --- | --- |
| Kernel scheduler calls kernel-internal memory function | Normal internal kernel call, **not** UMI |
| CPU interrupt delivered to kernel | Hardware exception/interrupt path, **not** UMI request |
| User process asks kernel to map memory | Defined system entry, then **UMI authorization**, then kernel memory mechanism |
| User process sends request to another user process | **UMI-authorized IPC** via the kernel |
| External process asks process manager to spawn another process | **UMI-authorized service operation**; process manager invokes kernel primitives through UMI |
| External storage service requests privileged device operation | **UMI-authorized kernel operation**, with controlled hardware access |
| Two user services share memory | **UMI-authorized grant/mapping**, bounded scope and lifetime |
| A service crashes and is restarted | Supervisor service controls restart; old permissions/handles must not silently grant replacement process access |

**Important distinction:** UMI is mandatory at the trust boundary; it is not the mechanism by which internal kernel functions call one another. Hardware interrupts are events handled by kernel code and may later produce UMI notifications to drivers.

## 4. Conceptual message flow (NOT a frozen ABI)

Example: application calls a terminal service.

1. Caller asks for permission to access a named terminal operation (or uses a previously authorized, valid endpoint).
2. Kernel obtains the **actual caller identity** from its execution context.
3. Kernel UMI enforcement checks the endpoint, operation, capability, state, and bounds.
4. If denied: no delivery; emit bounded decision/audit information and return a defined failure.
5. If allowed: deliver a structured message to the isolated destination service.
6. Service executes its own domain checks, sends a correlated response, and may ask the kernel to perform privileged work through UMI.
7. Kernel checks each crossing of the external/kernel boundary. Internal privileged kernel implementation remains direct.

Example logical envelope (documentation only):

```text
source:       [kernel-authenticated identity]
destination:  system.terminal
operation:    write
request_id:   1042
interface:    terminal.v1
payload:      [bounded binary data]
authority:    [validated endpoint/capability]
```

This is **not** a decision to use JSON, string parsing, a specific envelope order, or a literal `authority` field that the caller can forge.

## 5. Threat model: first pass

**Design for:** compromised or defective user-space service; forged caller-provided identity; unauthorized service discovery/invocation; malformed or oversized IPC messages; denial-of-service via request floods; stale endpoints after restart; accidental service privilege escalation; illegal shared-memory grants.

**Do not claim solved yet:** malicious kernel, insecure firmware/boot chain, side channels, physical attacks, unsafe DMA without IOMMU mediation, imperfect per-resource security in a driver, or hard real-time guarantees. Those require further architecture and test work.

**Bootstrapping tension to solve explicitly:** if default deny applies to everything, the initial trusted services still need narrowly scoped, kernel-installed bootstrap identities/capabilities. Define a tiny, auditable initial bootstrap sequence rather than disabling UMI until startup completes.

## 6. Incremental implementation and acceptance gates

These are target gates, **not** a sprint schedule or a promise that they can all be completed in one sitting.

**G0 — Environment inventory (no disk changes).** Record actual IdeaPad CPU, firmware mode, installed host OS, RAM, disk layout, Rust toolchain, and QEMU/OVMF availability. Decide how to preserve the host and how to boot virtual images.

**G1 — Kernel boot.** A freestanding x86-64 Rust kernel starts in QEMU, prints deterministic diagnostics (serial preferred), identifies its build/version, and halts in a controlled way. No filesystem, network, user-space services, or heap required.

**G2 — Kernel mechanisms.** Establish and test a minimal memory map, protected mappings, exception handling, interrupt primitives, and the foundations necessary for isolated execution. Keep privileged functionality narrow.

**G3 — Isolated tasks and UMI entry.** Launch at least two independent user-mode address spaces. Define a minimal kernel entry/exit contract and caller identity mechanism. Verify a user component cannot directly access privileged state or another task's private memory.

**G4 — UMI allow/deny.** Caller A sends an authorized named-operation request to isolated Service B; B returns a correlated response. Attempt an unauthorized operation; kernel denies before delivery; denial is auditable; Service B stays alive.

**G5 — Recovery and revocation.** Kill/restart B; demonstrate stale endpoint rejection, bounded error delivery to A, explicit new authorization, and safe continuation. Add malformed and oversized message tests.

The **first session** is G0 followed, if the actual host supports it, by the smallest steps toward G1. Do not skip the isolation and authorization prerequisites and then incorrectly declare UMI implemented.

## 7. Explicitly not decided yet

These are important, but **not blockers** to preserving the design:

- Final product/OS name (the project codename `new-hope` and personal repository are established).
- Host OS on the upgraded IdeaPad; partitioning/installation approach.
- Specific bootloader/UEFI implementation, Rust toolchain versions, and use of stable versus nightly features.
- Source directory structure, exact syscall ABI, encoding, interface definitions, and handle sizes.
- Capability ownership, inheritance, revocation and delegation mechanics.
- Service namespace hierarchy, name resolution details, and interface version-negotiation rules.
- Exact UMI control-plane policy format and how compiled policy is delivered atomically to kernel.
- Detailed audit storage, overflow strategy, log persistence, and policy recovery after reboot.
- Scheduler algorithm, SMP/multicore support, driver safety/IOMMU plan, and devices supported beyond early serial diagnostics.
- POSIX compatibility (not presumed); actual networking or remote UMI endpoints (not required for initial OS).

**Change discipline:** If we revisit an agreed rule, record a new numbered decision, its motivation, security/performance implications, and what it supersedes. Do not silently rewrite the baseline.

## 8. Next-session resume checklist

1. Read this entire baseline before making code changes.
2. Confirm architecture has **not** been silently changed to monolithic/POSIX or an ordinary unrestricted IPC bus.
3. Verify physical IdeaPad inventory and whether Samsung 970 500 GB NVMe is installed.
4. Confirm the development host OS and available build/QEMU tools, without assuming FreeBSD or Linux.
5. Work **only** on G0 and the smallest G1 boot experiment unless the user explicitly expands scope.
6. Preserve separate source repository discipline; **do not** create/push/merge GitHub changes without explicit user authorization.
7. Record actual test results and update this baseline with approved design decisions only.

## 9. Short handoff for a new chat

> We are designing a fresh x86-64 Rust OS for my Intel Core i3 Lenovo IdeaPad, planned with a Samsung 970 500 GB NVMe upgrade. We chose a MINIX-inspired microkernel. CPU scheduling, interrupts/exceptions, memory management/protection, and kernel IPC belong inside the microkernel. **Everything outside the microkernel** that communicates with the kernel or other external components must use **UMI (Unified Message Interface)**: named network/RPC-like calls over efficient kernel IPC. UMI is envisioned as an **OS-level next-generation firewall**: mandatory kernel enforcement of caller identity, endpoint, operation, capabilities, state, resource limits, default deny, and audit. User-space control plane manages policies; kernel data plane enforces them. No UMI bypass, including shared-memory grants. Hardware interrupts and internal kernel function calls are not RPC. Keep user-space drivers/services isolated, as in MINIX. Start extremely small in QEMU, then test actual hardware later. Do not conflate architectural intent with implemented isolation or select unstated APIs/toolchains. Read `docs/architecture/ARCHITECTURE.md` and begin by inventorying the actual host and working toward a simple boot/serial/halt test. Do not change GitHub without permission.

---

*Baseline created from the architecture discussion on 2026-10-13. Nothing in this document indicates a working kernel. The local scaffold is prepared but remote publication has not succeeded.*

# ADR-0001 — Rust Microkernel Ownership Boundary

- **Status:** Accepted
- **Date:** 2026-10-13
- **Context:** Build a tiny independent operating system inspired by MINIX fault isolation, without inheriting a monolithic kernel or imposing POSIX compatibility.

## Decision

The Rust x86-64 microkernel owns scheduling/context switching, CPU exception and interrupt handling, physical/virtual memory mechanisms, address-space protection, IPC primitives, and mandatory UMI enforcement. Kernel-internal calls are ordinary privileged functions. CPU interrupts arrive as hardware events, not UMI messages.

Processes, service discovery, policy administration, storage/filesystem services, device drivers, terminal, and service supervision are intended to live in protected external processes where practical. External requests for privileged kernel mechanisms must use the validated UMI entry contract.

## Alternatives considered

- Monolithic kernel: easier initial access to drivers but conflicts with desired component fault isolation.
- Pure userspace management of all mechanisms: impossible to implement architectural interrupt receipt and required privilege enforcement entirely outside the kernel.
- Linux/FreeBSD host as the finished operating system: contrary to the independent-OS objective.

## Consequences

Address-space isolation, exception entry/exit, and IPC will demand careful low-level unsafe Rust. Early serial/halt code alone will not demonstrate microkernel isolation. Scheduler algorithm, specific boot path, driver model details, ABI and SMP strategy remain open.

## Tests necessary

QEMU boot/halt (G1); fault/interrupt/memory isolation (G2); two independently protected user-mode address spaces and controlled kernel entry (G3). See [roadmap](../roadmap/ROADMAP.md).

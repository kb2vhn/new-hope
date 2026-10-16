# New Hope

**New Hope** is an experimental, independent, portable Rust microkernel operating-system project. **x86-64 is the first implementation and acceptance target** (QEMU, then the available Lenovo IdeaPad); **AArch64/ARM64 is a subsequent target**. These are implementations of one OS, not separate operating systems.

New Hope is not a Linux distribution, a MINIX fork, or a required UNIX/POSIX clone. Its microkernel owns scheduling, exceptions/interrupts, memory protection, primitive IPC, and mandatory **Unified Message Interface (UMI)** authorization. UMI is a small, policy-driven, OS-wide authorization mechanism inspired by firewall ACLs; service-specific permissions remain with their responsible services. Native network firewall enforcement is planned in a protected networking service, not a mandatory TLS-inspecting kernel component.

Long-term goals include authenticated multiuser operation; a small native command executor and bundled file utilities; secure file ownership and ACLs; protected HID, storage, and networking; explicit least-privilege administration; protected security journals; and isolated system services. Detailed security requirements are **design contracts, not working software**.

**Current status:** documentation scaffold only. **No bootable kernel, runtime isolation, security implementation, or OS acceptance gate has passed.** A passing GitHub documentation check validates only repository structure.

## Documentation

- [Architecture baseline](docs/architecture/ARCHITECTURE.md) — kernel/UMI boundaries and authoritative overview.
- [Design goals](docs/architecture/DESIGN-GOALS.md) — intended user experience and scope.
- [Architecture decisions](docs/architecture/DECISIONS.md) — accepted ADR index and change process.
- [Open questions](docs/architecture/OPEN-QUESTIONS.md) — issues we deliberately have not settled.
- [Repository reconciliation](docs/architecture/RECONCILIATION.md) — prior-baseline corrections and decision maturity.
- [Roadmap and acceptance gates](docs/roadmap/ROADMAP.md) — G0 through G5, then later stages.
- [Getting started](docs/development/GETTING-STARTED.md) and [handoff](docs/development/HANDOFF.md).
- [Validation standards](docs/development/VALIDATION.md) and [agent/contributor rules](AGENTS.md).

## First target and approach

Build on the development workstation; perform the initial **x86-64 QEMU** boot/serial/halt acceptance test, then test the Lenovo IdeaPad non-destructively. Keep architecture-dependent boot/interrupt/memory mechanisms apart from shared kernel logic. ARM64 physical-board selection remains open; no currently functioning Linux device is to be overwritten for the project. No bootloader or Rust toolchain version is selected yet.

## Ownership and licensing

This is an independently maintained personal project in [kb2vhn](https://github.com/kb2vhn). **No license has been selected.** Public visibility does not confer reuse rights. Changes to GitHub require explicit, scoped approval.

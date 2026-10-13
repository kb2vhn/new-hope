# New Hope

**New Hope** is an experimental, independently developed **x86-64 Rust operating system**. Its intended architecture is a MINIX-inspired microkernel with a mandatory **Unified Message Interface (UMI)** for communication across the kernel boundary and between isolated external components.

UMI takes its security model from a **next-generation firewall**: kernel-authenticated caller identity, endpoint and operation authorization, state, resource bounds, default deny, and auditable decisions. Calls are network-like in structure, but local IPC does **not** require TCP/IP.

**Status:** initial project scaffold published to `main`; architecture documented. **No bootable kernel, runtime tests, or acceptance gates have been completed.**

## Documentation

- [Architecture baseline](docs/architecture/ARCHITECTURE.md) — agreed rules versus open design choices.
- [Architecture decisions](docs/architecture/DECISIONS.md) — decision register and change control.
- [Open questions](docs/architecture/OPEN-QUESTIONS.md) — deliberately unresolved choices.
- [Roadmap and acceptance gates](docs/roadmap/ROADMAP.md) — G0 through G5.
- [Getting started](docs/development/GETTING-STARTED.md) — IdeaPad inventory and QEMU-first approach.
- [Session handoff](docs/development/HANDOFF.md) — context for a later development session.
- [Contributor and agent rules](AGENTS.md) — engineering and authorization policy.

## Hardware and first objective

Development machine: Lenovo IdeaPad, 10th-generation Intel Core i3, approximately 12 GiB RAM, planned Samsung 970 500 GB NVMe upgrade (details to verify). Host OS, firmware configuration, Rust toolchain, and QEMU availability are **not yet established**.

The first executable acceptance test will be a freestanding kernel booting under QEMU, printing a deterministic serial message, and halting safely. No storage driver, graphical interface, network stack, or POSIX layer is required to reach that goal.

## Ownership and licensing

This is an independent, personally maintained project hosted under [kb2vhn](https://github.com/kb2vhn). **No license has been selected**. Public GitHub visibility is not an open-source license or permission to reuse the code.

This is a design-stage project. Do not interpret repository scaffolding or passing document checks as evidence of an operational OS.

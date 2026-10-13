# New Hope — Next-session handoff (2026-10-13)

Project codename **new-hope**. Canonical repository: https://github.com/kb2vhn/new-hope.git (public; publication of the local scaffold pending GitHub write access). We are building a small, independent x86-64 Rust OS for my Intel Core i3 Lenovo IdeaPad; I plan to install my Samsung 970 500 GB NVMe. Inspired by MINIX, but not a MINIX fork or necessarily a UNIX/POSIX clone.

**Agreed:** CPU scheduling, interrupt/exception handling, memory management/protection, and primitive IPC live **inside** the microkernel. All communication by components **outside** the microkernel (to the kernel or to each other) goes through UMI, the **Unified Message Interface**. Treat those communications like **named network/RPC calls**, even when local, without requiring TCP/IP. UMI is like a **next-generation firewall built into the OS**: kernel-enforced identity, destination, operation, capabilities/permissions, state, bounds, default deny, and audit. No bypass for process-to-process communication or shared-memory grants. Keep kernel enforcement small; user-space protected policy control plane. Internal kernel calls are not UMI; hardware interrupts are hardware events.

Longer-term, drivers, storage, process management, terminal, discovery, and policy management should live in isolated user-space services. First milestone is **tiny**: inventory the actual laptop, then boot a freestanding Rust kernel under QEMU, print serial diagnostics, and halt. After kernel foundations and isolated user-mode tasks, test UMI allow/deny/audit between two services. Do not prematurely implement a network stack, filesystem, GUI, or POSIX environment. No GitHub/repo changes without approval.

**Primary architecture record:** `docs/architecture/ARCHITECTURE.md`. Read that first; it distinguishes approved architectural decisions from implementation choices still open. Continue from the baseline rather than reopening our agreed microkernel/UMI design.


**Repository policy:** Choosing the codename and repository did not authorize a commit or push. The architecture belongs under `docs/architecture/`; leave `README.md` concise and link to documentation. GitHub writes require explicit authorization and working connector permissions.

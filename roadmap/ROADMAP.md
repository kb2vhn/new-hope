# New Hope — Incremental Roadmap

**As of 2026-10-13: no gate has been completed.** Gates describe acceptance criteria, not calendar commitments. A later gate never retroactively turns an earlier failure into a pass.

## G0 — Host and toolchain inventory

- Record precise IdeaPad CPU, RAM, firmware/UEFI state, host OS, disk layout and NVMe model.
- Record Rust toolchain availability, QEMU, UEFI firmware/OVMF and debugger options.
- Establish reproducible build commands and a non-destructive virtual-disk path.
- **Pass:** committed inventory (sanitized of personal secrets) and a chosen, documented first boot/test method.

## G1 — First kernel boot

- Minimal freestanding x86-64 Rust kernel; deterministic serial output and controlled halt in QEMU.
- No network stack, filesystem, GUI or required heap.
- **Pass:** exact build command, tool versions, boot command and captured serial output; repeatable clean boot/halt.

## G2 — Kernel foundations

- Exception handling and minimal interrupt setup; inspect memory map; initial page/mapping control.
- **Pass:** targeted positive/negative validation without confusing exceptions with UMI requests.

## G3 — Isolation and controlled entry

- Two distinct user-mode address spaces; kernel-authenticated caller identity and message entry primitive.
- **Pass:** attempted forbidden kernel/private-memory access fails; valid controlled entry succeeds.

## G4 — UMI authorization proof

- Authorized named request/reply between isolated callers; operation-specific denial before delivery.
- **Pass:** permit, deny, bounded audit and continued recipient operation are all observed.

## G5 — Failure, recovery and revocation

- Service death/restart, old-handle invalidation, malformed/oversized request rejection, bounded failure delivery.
- **Pass:** repeatable negative tests with explicit authority and recovery behavior.

## Out of initial scope

Networking, POSIX compatibility, real NVMe drivers, filesystem, shell UI, graphical desktop, real-hardware disk modifications, and a broad scheduler or policy language. They require separate, explicitly approved milestones.

## Evidence record

Each gate report should capture: date, revision, host/guest platform, tool versions, exact commands, expected result, actual result, failures/limitations, and acceptance decision. `NotTested` is not `Passed`.

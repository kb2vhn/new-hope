# Getting started — workstation build, x86-64 QEMU first

**No Rust compiler version, bootloader or host configuration is yet selected.** This is an inventory and planning guide, not a script authorizing disk writes.

The primary build host is the development workstation. The first guest is a freestanding **x86-64 New Hope kernel in QEMU**; the first physical target is the available Lenovo IdeaPad (10th-gen Intel Core i3; exact firmware, memory and disk must be inventoried). ARM64 hardware follows later and must not be silently treated as the first acceptance target.

## G0 inventory (read-only)

On the actual development workstation (macOS or other verified host), record:

```sh
uname -a
uname -m
command -v rustc || true
command -v cargo || true
command -v rustup || true
command -v qemu-system-x86_64 || true
command -v git || true
rustc --version 2>/dev/null || true
cargo --version 2>/dev/null || true
```

On the IdeaPad, perform an **appropriate host-OS-specific, read-only** CPU, memory, firmware, Secure Boot capability, storage and partition inventory before any disk or BIOS change. Do not assume the laptop OS is Linux or FreeBSD and do not overwrite its NVMe to prove a G1 boot.

Decide and document one exact QEMU firmware/boot method, target/compiler profile, console, test binary/image and clean rebuild command. Firmware/key changes are **not** G0 requirements. A physical board lacking hardware Secure Boot is still a legitimate development target with lower reported boot assurance.

## First acceptance target

G1 only: print deterministic serial identification from a freestanding x86-64 kernel, halt cleanly, and retain exact commands/output. Do not install the future user service layer, networking, filesystem, policy administration or browser/HID support during G1.

Read [ARCHITECTURE.md](../architecture/ARCHITECTURE.md), [ROADMAP.md](../roadmap/ROADMAP.md), [OPEN-QUESTIONS.md](../architecture/OPEN-QUESTIONS.md), and [AGENTS.md](../../AGENTS.md) before material changes.

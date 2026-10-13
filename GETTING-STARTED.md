# Starting New Hope on the IdeaPad

New Hope has **no selected toolchain or bootloader yet**. The first session begins with G0, not with destructive disk installation or a speculative bootloader dependency.

## Intended environment

- Lenovo IdeaPad with Intel Core i3 (10th generation; exact model unverified).
- Approximately 12 GiB RAM; planned Samsung 970 500 GB NVMe upgrade.
- Initial guest target x86-64; QEMU virtual machine, serial output, deterministic halt.
- Text-based development workflow is preferred, but host OS is **unconfirmed**.

## Read-only inventory commands

On a Linux host:

```sh
uname -a
uname -m
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
rustc --version 2>/dev/null || true
cargo --version 2>/dev/null || true
rustup show 2>/dev/null || true
command -v qemu-system-x86_64 || true
command -v git || true
```

On FreeBSD:

```sh
uname -a
sysctl hw.model hw.physmem 2>/dev/null
geom disk list
rustc --version 2>/dev/null || true
cargo --version 2>/dev/null || true
command -v qemu-system-x86_64 || true
command -v git || true
```

Record only necessary device facts; redact volume identifiers and personal data before committing output. No repartitioning, BIOS changes, firmware flashing, NVMe writes or bootloader installation as part of this inventory.

## First development decision

After the inventory, select and document a Rust toolchain/target and one boot strategy under an ADR. Create an actual kernel crate/workspace **only once that decision is made**; do not introduce noncompiling placeholder code or a fake successful CI target.

See [roadmap](../roadmap/ROADMAP.md) and [validation](VALIDATION.md).

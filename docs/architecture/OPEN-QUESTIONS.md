# Open Architecture Questions

These decisions are **not yet approved**. Do not pick a default in code and later describe it as agreed.

| Area | Open question | Earliest gate |
| --- | --- | --- |
| Developer host | What OS and disk layout are actually installed on the IdeaPad? | G0 |
| Firmware and boot | UEFI/bootloader selection, QEMU/OVMF strategy and image packaging | G0–G1 |
| Rust | Stable/nightly features, compiler version and pinned target | G0–G1 |
| Build structure | Cargo workspace/crate boundaries once executable code starts | G1 |
| Kernel entry | Exact syscall entry, user/kernel ABI, request envelope and error codes | G3 |
| Identity | Capability creation/delegation, policy identity and revocation generations | G3–G4 |
| UMI | Service registry ownership, name formats, version negotiation, buffer sizes | G3–G4 |
| Policy | Compiled control-plane representation, atomic installation, audit overflow | G4 |
| Scheduling | Algorithm, SMP support and priority/inversion management | G2+ |
| Devices | Driver DMA/IOMMU protection, hardware coverage beyond QEMU serial | Later |
| Licensing | License and external contribution policy; do not assume OSI permission | Prior to selecting license |
| Compatibility | UNIX/POSIX surface and any remote UMI transport | Later |

The **codename** `new-hope`, **repository location** `kb2vhn/new-hope`, **x86-64 goal**, and **UMI/NGFW trust boundary** are established, not open questions.

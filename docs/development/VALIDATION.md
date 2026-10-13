# Validation and Test Records

New Hope currently contains **documentation and component placeholders, not a working kernel**. The repository integrity check tests that required files exist. It does **not** build, boot, or validate an OS.

## Engineering test discipline

- Run the narrowest reproducible test for changed mechanisms.
- Preserve exact commands, input, revision, expected and actual results, tool versions and guest/hardware parameters.
- Preserve failed runs even when a later retry succeeds. Do not report a gate complete from partial success.
- Tests of privilege, caller identity and UMI authorization must include denial cases, not just valid requests.
- Distinguish guest virtualized behavior from physical-device support.

## Planned acceptance report location

When G0 begins, add reports under `docs/validation/` such as `G0-IDEAPAD-INVENTORY-YYYY-MM-DD.md` and `G1-QEMU-BOOT-YYYY-MM-DD.md`. Report status must be one of `NotTested`, `Partial`, `Failed`, or `Passed` with exact acceptance criteria. Avoid copying secrets, sensitive machine IDs or huge binary traces to GitHub.

## Repository-only check

```sh
sh tools/verify-scaffold.sh
```

This validates file and documentation structure only. It is not a substitute for later `cargo fmt`, `cargo clippy`, unit tests, property/fuzz tests, QEMU boot tests, and hardware characterization once executable components exist.

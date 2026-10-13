# New Hope — Agent and Contributor Rules

## Purpose and precedence

This file governs coding agents, reviewers, automation, and human contributions to **New Hope**. It borrows FI's disciplined approach to architecture, testing, failure reporting, documentation, and GitHub authorization. It is **specific to New Hope**; FI's Windows/file-intelligence implementation rules do not apply here.

Before a material change read, at minimum:

- `README.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/DECISIONS.md`
- `docs/architecture/OPEN-QUESTIONS.md`
- `docs/roadmap/ROADMAP.md`
- `docs/development/VALIDATION.md`
- The local component `README.md`, when present.

Architecture decisions and explicit user direction outrank examples, scaffolding and convenient implementation choices. If implementation and documentation conflict, **report the conflict**. Do not quietly rewrite the design.

## Governing principles

> **New Hope is a genuine x86-64 Rust microkernel operating-system project, not a Linux/FreeBSD distribution, MINIX fork, or automatic POSIX clone.**

> **UMI is mandatory at every external/kernel and external/external communication boundary.**

> **UMI is a security enforcement point modeled after an NGFW, not merely a transport or event bus.**

> **The microkernel owns scheduling, interrupt/exception handling, memory mechanisms and protection, IPC primitives, and mandatory UMI enforcement.**

> **Internal kernel function calls and CPU hardware interrupt delivery are not UMI requests.**

> **No external component gains authority through a service name alone.**

> **No unauthorized bypass exists through shared memory, device access, direct mapping, or fast paths.**

> **Describe planned mechanisms as planned, not as implemented or tested.**

## Boundary and ownership rules

Kernel-owned mechanisms:

- CPU scheduling, context switching, execution/thread primitives.
- Exception and interrupt receipt/dispatch.
- Physical/virtual memory mechanisms, mappings, address-space isolation.
- IPC transport, endpoint identity/capability checks, and minimal UMI enforcement.

Outside the microkernel when eventually implemented:

- Service discovery and policy administration; process-management policy.
- User-space device drivers, filesystem/storage services, terminal and shell.
- Recovery/supervision, applications, and operator tools.

External requests **to the kernel** and external requests **to other external components** use one logical named, typed, bounded UMI contract. Local transport can be compact kernel IPC; a network stack is not necessary. Avoid repeatedly resolving service names on hot paths if protected handles can be used without weakening revocation or authorization.

Do **not** place a full policy compiler, arbitrary application parser, filesystem permission logic, or service-manager policy engine inside the kernel merely because UMI controls the entry point.

## UMI security requirements

- Default deny: no caller access without valid, established authority.
- Derive caller identity from kernel-controlled state, not caller-supplied text.
- Check destination endpoint, operation, capability, message bounds and applicable state before delivery.
- Make ambiguous, malformed, expired, revoked, or unavailable authority fail closed.
- Identify bootstrap capabilities explicitly; never bootstrap by globally disabling enforcement.
- Service-name lookup is discovery, not authorization.
- Treat restarts, stale handles, replays and timeouts as security-relevant state transitions.
- Authorize shared-memory grants, mapping, delegation, and revocation through UMI; sharing bytes must not silently grant new control authority.
- Emit bounded audit decisions without allowing the audit path to block or exhaust the kernel indefinitely. Audit durability and overflow policy are still **open**.
- A compromised kernel, unsafe DMA, or legitimately authorized malicious service is **not claimed solved**.

## Rust and implementation rules

- Prefer small auditable crates/modules and explicit interfaces. Keep public interfaces minimal.
- Kernel code is expected to be freestanding; do not casually introduce `std`, OS host syscalls, or host runtime assumptions into the target kernel.
- Minimize `unsafe`; document each unsafe block's invariants and ownership, and test boundaries where feasible.
- No undefined behavior, uncontrolled allocation, surprise background threads, or hidden service-to-service calls for convenience.
- Use clear Rust types for identities, handles, operations, results and errors when they are designed; do not invent permanent ABI details prematurely.
- Keep architecture-dependent mechanisms separated from architecture-independent policy/protocol contracts.
- Do not add dependency-heavy frameworks or bootloader crates until their use is justified and recorded in a decision.
- Do not fabricate a functioning build or placeholder kernel to make CI appear green.

## Scope and acceptance gates

Read `docs/roadmap/ROADMAP.md` before starting. Work sequentially:

1. **G0:** inventory real IdeaPad environment without destructive changes.
2. **G1:** QEMU boot + deterministic serial message + controlled halt.
3. **G2:** kernel memory/interrupt mechanisms and protections.
4. **G3:** separate user-mode address spaces and a controlled kernel entry.
5. **G4:** authorized UMI request/response, denied operation, bounded audit.
6. **G5:** service failure/restart, revocation and malformed-message resilience.

A kernel boot is **not** proof of memory isolation. An IPC round trip is **not** proof of mandatory UMI authorization. A test that runs under QEMU is **not** a bare-metal hardware support claim. Keep these distinctions explicit.

## Failure and testing discipline

- Define expected and negative behavior before implementing privileged functionality.
- Prefer deterministic, reproducible tests; add regression tests for defects.
- Record the exact environment, command, binary revision, observed output, and known limitations.
- Keep `NotImplemented`, `NotTested`, `Failed`, and `Passed` separate.
- Never rewrite a failed test into success after a later rerun; preserve both attempts.
- In early stages, first prove code builds/boots under the **actual selected** toolchain and boot path, then add targeted negative security tests.
- Do not test on real NVMe hardware until disk-preservation and recovery procedures are documented and expressly approved.
- Document what was **not** validated. Do not claim protection from attacks the test did not attempt.

## Documentation and decisions

- Architecture changes require an ADR explaining context, choice, alternatives, consequences, risks, and impact on existing decisions.
- Never silently move scheduling, memory mechanisms, or interrupts out of the kernel; never relax UMI coverage or default deny as an implementation shortcut.
- Keep `README.md` brief; detailed architecture, testing, and roadmap belong under `docs/`.
- Distinguish illustrative operation names and message examples from ratified ABI or encoding decisions.
- Do not select a license, stable/nightly toolchain, bootloader, or host OS implicitly.
- Update the affected documentation in the same change set as the behavior.

## GitHub and change-control rules

An approval for one action is not general authorization for later actions.

Without explicit user authorization for the specific action, agents must not:

- Commit, push, merge, or open/close a PR.
- Create, delete, or change remote branches or tags.
- Change branch protection, rulesets, permissions, repository settings, or licensing.
- Publish a release or delete repository content.

Local inspection, drafts, patches and uncommitted working-tree preparation are allowed unless otherwise directed. Before a proposed commit review `git status --short`, `git diff --check`, `git diff --stat`, and the full diff; stage files intentionally and inspect the staged diff. Do not use broad staging on a tree with build outputs or test artifacts.

Never claim a GitHub write succeeded based on a local file, tool request, or optimistic status. Verify the remote object after a successful write. When integration permissions deny a write, stop and report the denial.

## Repository hygiene and review

Do not commit private keys, tokens, local disk images, NVMe dumps, user-specific machine state, huge kernel/QEMU traces, Rust `target/`, build outputs, editor swapfiles, or machine-specific configuration. Do not copy FI code, configuration, or company materials into this personal project without explicit direction and applicable rights.

Review every proposed change for:

- What exact boundary changed? Could any external communication avoid UMI?
- Was actual kernel-owned identity checked? Are names being mistaken for authority?
- Are permissions, failure states, timeouts and resources bounded?
- Was `unsafe` used and justified? Are interrupts/preemption handled safely?
- Did a bootstrap workaround become a persistent security hole?
- Are tests representative? Are failed tests recorded?
- Do docs still distinguish the agreed architecture from unimplemented behavior?
- Was the particular GitHub write approved and verified?

**Final rule:** prefer a tiny, explicit, verifiably correct mechanism over a large subsystem that appears functional but hides privilege, policy, or failure behavior.

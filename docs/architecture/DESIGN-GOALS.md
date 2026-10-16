# New Hope — OS design and operator experience

**Status:** Accepted product direction; not an implemented feature specification. Exact UI syntax and underlying interfaces remain open unless stated.

## Operating-system goals

- One small, inspectable, independent Rust OS for x86-64 first, then ARM64. Keep hardware-specific code separated from shared mechanisms and policy.
- Genuine preemptive multitasking, multiuser authentication, separated address spaces, and dependable service failure handling.
- An OS-owned, **mandatory** and centrally understandable security model, not an assortment of opt-in sandbox frameworks the administrator must assemble. Security is present by default from first boot.
- Simple, inspectable dependencies; don't make the core OS depend on large runtime frameworks, proxies, or unspecified third-party subsystems. Prefer small components and measured performance over unnecessary abstraction.
- Native networking with a mandatory protected stateful firewall; optional higher-level proxy or TLS inspection is **not** part of the base OS.
- Event generation and logging as system services; later HIDS analysis and remote log forwarding. Log generation must not require deploying a HIDS.
- Eventually support ordinary Rust and Go applications, editors such as Vim/Neovim, alternative shells, and networking tools. These are goals, **not** a promise that existing binaries run unchanged or that POSIX is required.
- User-controlled system administration, with restricted high-trust accounts and no universal root bypass of UMI or file permissions.

## Native command environment

- The base OS supplies a minimal, non-scripting **native command executor** with commands, arguments, switches, quoting, command status, and conditional chaining (`&&`, `||`). Precise parsing/precedence rules remain to be specified.
- Normal filesystem work must be available out of the box, without installing Bash/Zsh: `ls`, `cp`, `mv`, `rm`, `mkdir`, `rmdir`, `cat`, `pwd`, `stat`, `touch`, and related utilities. These are independent programs rather than hardcoded kernel or prompt functionality.
- `cd`, prompt state, and exit behavior may be native executor functions. Optional Bash/Zsh or other interpreters are separate applications and do not define the OS interface.
- User-owned, non-executable preference files (proposed `~/.nhrc`) may customize command aliases, prompt, and approved settings. Protected global limits (proposed `/sysconfig`) always prevail.
- `doas <command>`-style, narrowly authenticated operation elevation and `eu -` authenticated temporary administrative sessions are planned. `exit` and `end` return from the elevated prompt. The administrative prompt uses `#`; a normal prompt can use `>`.
- Default `eu -` inactivity timeout is 10 minutes, counted while the session is idle after command completion; valid session interaction resets it. User settings may shorten, but not exceed, the protected system maximum. A running foreground command is not abruptly terminated solely because the idle clock expires. A timeout invalidates elevation; it does not change the account's permanent identity.

## Browser and application ownership boundary

- The OS owns **process isolation, IPC authorization, hardware-resource access, input delivery, and network enforcement**.
- A browser owns **webpage origins, extensions, JavaScript, cookies, webpage/DOM permission decisions, and browser-managed credentials**. UMI has no browser-extension, webpage, or protocol-payload semantics.
- A process or service may be restricted independently if it has a real OS-enforceable identity. Distinct code inside an unrestricted shared address space is not magically separable by the kernel.
- HID input is delivered only to its authorized consumer. Raw/global input monitoring, screen capture, global clipboard monitoring, and input injection are distinct controlled authorities, denied by default unless explicitly permitted. Normal focused typing and ordinary clipboard use should not require special administrative approval.
- TLS/SSH contents remain protected end-to-end. Administrator-enabled TLS session-secret logging, where supported by the relevant TLS implementation, is a separate diagnostic capability, disabled by default and audit controlled.

## Performance and verification

- Optimize for measurable CPU, latency, memory, disk, context-switch, and packet-path costs. Do not insert a user-space proxy or a UMI round trip for every packet solely to maintain policy.
- The native authorization and networking data planes must have finite memory, queues, and failure policies. Fast paths may not bypass security enforcement.
- Design promises remain unverified until positive **and negative** tests pass on the stated platform.

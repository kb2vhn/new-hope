# ADR-0012 — Native command executor and layered user configuration

- **Status:** Accepted experience and security direction; parser/format details open
- **Date:** 2026-10-16

## Decision

- Supply a simple **native user-space command executor**, not an OS-mandated Bash/Zsh shell or embedded scripting environment. Kernel and UMI have no command-parser logic.
- Support command invocation, switches/arguments, quotes, exit status, and `&&`/`||` conditional chaining. Advanced pipelines, scripting loops, functions and shell expressions are not base-executor requirements. Optional interpreters are independent programs.
- Ship standalone base utilities for `ls`, `cp`, `mv`, `rm`, `mkdir`, `rmdir`, `cat`, `pwd`, `touch`, `stat`, and other essential filesystem tasks. `cd` and `exit` may be executor operations because they affect the current prompt session.
- The executor requests execution through a protected process service; **user-intended launches must be authenticated and separately policy-authorized** without giving the executor universal authority. App-created child reduction remains mandatory (ADR-0003).
- Support a simple user-owned **non-executable** configuration (proposed `~/.nhrc`) for aliases, prompt, and permitted preferences. A protected global `/sysconfig` policy overrides user preferences; aliases cannot confer security authority.
- Permit `eu.timeout=4` (minutes) when the global timeout maximum is 10, but not 20. The trusted session service, **not the prompt script/configuration**, enforces the effective timeout; use `min(user value, global max)` with a documented default.
- Both `exit` and `end` close an elevated `eu -` environment; ordinary user prompt appearance is independent of security authority.

## Unresolved

Syntax, quoting/escaping, conditional precedence, executable paths, directory conventions, environment passing, interactive jobs and background work, alias nesting/cycles, rc schema, exact elevation command design, terminal service boundary, UTF-8/input handling, alternative shell compatibility.

## Tests required

Quoting and argument passing, `&&`/`||` status behavior, safe aliases, malformed rc fallback, global timeout limit, denial of unsafe process launch, and file commands subject to actual filesystem ACL.

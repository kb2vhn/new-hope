# ADR-0005 — Application responsibilities and protected device/input access

- **Status:** Accepted principles; service contracts open
- **Date:** 2026-10-16

## Decision

1. New Hope secures **OS resources and separations**: memory, processes, filesystem-service entry, IPC, device access, keyboard/input ownership, network permissions, and kernel-authorized delegation.
2. Applications own their **internal security**. In particular, browsers own extension identity and permissions, JavaScript, DOM and webpage-origin policy, cookies, and browser-managed credentials. Neither the kernel nor UMI understands a browser extension.
3. Drivers are protected services outside the microkernel where feasible; hardware grants and any DMA capability are limited. A driver may not use device access to bypass UMI or the network firewall.
4. HID input is delivered to the authenticated/authorized user session and intended recipient. **Traverse is not input authority; being able to receive focused keyboard events is not global keylogging permission.**
5. Grant independently controlled capabilities for global/raw keyboard access, input injection, screen capture, system-wide clipboard monitoring, and specialized accessibility/diagnostic functions. Such monitoring is denied by default without explicit authorization; ordinary focused input/clipboard tasks should remain usable.
6. Input for login and privileged authentication must follow a trusted path resistant to unrelated applications impersonating the authentication prompt. Synthetic input must not extend `eu -` session lifetime unless verified as authorized session interaction.
7. Internal app components sharing an unrestricted address space cannot be independently isolated by the OS without app-provided separation and trusted delegation. A permitted browser extension seeing a page's plaintext remains the browser's decision, not a kernel defect.
8. System instrumentation may publish protected, bounded security events for a later HIDS without requiring a monitoring agent to intercept arbitrary device calls. Monitoring does not inherently grant containment-policy modification.

## Unresolved

Input focus and trusted UI design; HID hardware trust; clipboard object ACLs; graphical sessions; secure attention; input injection for remote support; driver DMA isolation on unprotected boards; accessible workflows without accidental global access.

## Tests required

Cross-session keylogging denial, raw HID denial, focus-change delivery, clipboard/screen permission separation, malicious device/driver error handling, and no trusted-prompt spoofing at the OS boundary.

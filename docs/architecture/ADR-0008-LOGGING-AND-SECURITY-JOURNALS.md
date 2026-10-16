# ADR-0008 — Native logs, sealed security journals, and containment triggers

- **Status:** Accepted core requirements; exact format, integrity root and detector algorithm open
- **Date:** 2026-10-16

## Separation of concerns

- Native OS services emit structured events for kernel/UMI, identity, processes, storage, HID, network firewall, authentication and security-state changes. Logging operates locally without networking or HIDS. Later, operators may send logs to a remote collector via explicitly authorized destinations and protected transport.
- An isolated HIDS may analyze logs and alert; being able to read events does **not** confer permission to change security policy. Protected containment requires its own authorization and conditions.
- Distinguish ordinary system/activity logs, identity/access administration, and **high-integrity privileged-security journals** (ownership takeover, changes granting administrative data access, policy/lock/recovery operations). **Classify by effect**, not merely by group name: adding oneself to a data-bearing group may be as privileged as an ACL change.

## Journal record and lifecycle

- Security journal records are authenticated, append-only after commit, sequence-ordered, time-stamped and linkable to actor/account, session, process attribution, object/operation, result, and policy/incident where applicable.
- **Segment rotation: 7 days or 128 MB, whichever first.** Rotation seals a segment and opens another; it does not destroy history. **Default retention: 90 days**. DR may extend configured retention. Active incidents and litigation holds prevent premature retirement. Retention retirement is a controlled, separately auditable operation.
- Proposed cryptographic construction: canonical record hashes, previous-record/segment linking, manifests on seal, atomic durable publication, independent verifier and periodically protected/signed checkpoints. **The precise algorithms, checkpoint storage, keys and crash protocol are open.** Local hashing does not prove protection against complete offline rollback; later remote anchors and hardware trust may strengthen it.
- For security-critical ownership/ACL/policy changes, a durable audit record is a condition of completing the protected mutation. If the protected journal is unavailable, **fail those changes closed**, retaining safe recovery capacity. Bounded ordinary audit cannot exhaust the kernel or halt unrelated traffic.
- A damaged tail after power loss must be distinguishable from a verified tamper or missing segment where possible; unreconciled integrity failure denies privileged security changes instead of failing open. See ADR-0011.

## Abnormal privileged activity

- A **10% configurable anomaly threshold** is accepted as an initial policy value. **Only the dedicated DR account** may change that protected threshold. It is not writable from user preferences or ordinary `eu -`.
- **The comparison basis and time window are not yet approved:** 10% above normal privileged activity versus a capacity/time fraction are different detectors. Do not implement one by assumption. Volume must be evaluated with attributable operation type/rate and credible incident criteria; journal rollover by itself is not compromise.
- High-confidence administrative compromise triggers ADR-0007's **account-wide `SECURITY_LOCKED` and process freeze**. An untrusted party must not induce a different administrator's lock by flooding ordinary logging.

## Retention and external exports

- All recovery, DR, RECOVERY and hold inspection actions are themselves recorded. Logs forwarded to collectors do not transfer policy-management authority.
- Retention of held records lasts through the hold and applicable post-hold policy regardless of ordinary 90-day age. Retiring an old segment never silently drops the integrity anchor to later segments.

## Tests required

Power-loss at each append/seal/checkpoint boundary; record reorder/omission/change; fill/rotation; retention holds; journal unavailability fail-closed; event flood attribution and bounded memory; alert and lock accounting; local operation during network loss; recovery and remote checkpoint validation where deployed.

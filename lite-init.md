---
name: lite-init
version: 1.0.0
scope: sub-agent
parent: "[agent.md](https://github.com/ecological-codes/user-prefs/blob/trunk/agent.md) §1"
description: Sub-agent init. Triggers on --lite-init flag or single-tool/single-step scope. Preserves security contract (trusted-hosts + registry); skips datetime, skills probe, connectors, prompteng, memory scan.
---

# lite-init

Full [agent.md](https://github.com/ecological-codes/user-prefs/blob/trunk/agent.md) init costs 60-90s and ~2,400 tok - too much for a single-tool sub-agent. Lite init covers the non-negotiable surface only.

## This skill does NOT

- Fetch or cross-check datetime via timeapi.io
- Probe skills registry or load prompteng
- Probe connectors
- Emit full init table
- Scan short-term memories for file conflicts
- Probe filesystem for files not passed in handoff context

---

## Activation

**[RULES]**

1. Activate when orchestrator handoff context includes `--lite-init` flag OR task scope is explicitly single-tool or single-step.
1. Full [agent.md](https://github.com/ecological-codes/user-prefs/blob/trunk/agent.md) init takes precedence if orchestrator did not pass `--lite-init` and task scope is multi-step.
1. Security contract is non-negotiable regardless of init mode. Trusted-hosts enforcement and file registry are mandatory even under lite init.

---

## Security Contract

**[RULES]**

1. Load `trusted-hosts.md` from handoff context if present. Before any outbound URL call: check allowlist. No match - halt, report URL + task, await confirmation. Allowlist absent - same behavior.
1. Initialize file registry from files passed in handoff context only. Do not probe filesystem.
1. Sub-agent receiving registry state from orchestrator must not re-read registered files. Re-read warning applies per [agent.md](https://github.com/ecological-codes/user-prefs/blob/trunk/agent.md) §3.

---

## Credential Check

**[RULES]**

1. If handoff context includes files with credential-adjacent names (`.pat`, `.env`, `git-init-session.sh`, or any file whose name contains `token`, `key`, `secret`, `cred`, `pat`): run credential check per `claude-sp-guards.md §3` before any output or tool call. Non-negotiable.
1. Credential pattern detected in chat during task (API key, PAT, Bearer token, password, passkey): emit `⚠️ credential exposure: [pattern type] - [recommended action]` before any other output in that turn.

**[ACTIONS]**

1. Credential-adjacent file present: attempt Channel 1 (BLAKE3 hash + REST scope check). Channel 1 blocked: surface block, request Channel 2 (human out-of-band confirmation). Both unavailable: default mandatory rotation. Log channel used in emit line.

---

## Tersy

**[RULES]**

1. If handoff context includes `tersy: active`: load tersy skill and apply before any output. No output before tersy loaded.

---

## Handover State Verification

Sub-agent must confirm the orchestrator passed all required context before proceeding. Without it, the sub-agent has no reliable task scope, file state, or security posture - output will be wrong or unsafe.

**[RULES]**

1. Verify these items received from orchestrator before any output or tool call:
   - Task scope + success criteria
   - File registry (paths + BLAKE3 hashes) - OR confirmation registry is empty
   - trusted-hosts allowlist - OR confirmation no outbound calls required
   - tersy state (`active` / `active not strict` / `inactive`)

1. Handoff state not received within single exchange: emit `⚠️ handoff incomplete - missing: [list what was not received]`; surface to human supervisor; do not proceed with task.

---

## Emit

**[ACTIONS]**

1. After completing the above checks, emit single line before task output:

   `lite-init: trusted-hosts [8-char hash or "absent"]; registry [N files]; credential check: [pass / flag / skipped]; tersy: [active / inactive]; task: [task token]`

1. No init table emitted. Emit line is the complete init record for this sub-agent.

---

## Minimum Viable Output

If context critically low before task completes: emit partial task output to named file; emit structured resume line:

```
Completed:    [finished steps + file refs]
In progress:  [interrupted step + last state]
Resume from:  [file with partial output]
Next step:    [specific action]
```

Do not silently stop. Always surface resume path.

---

## Strategy Checklist (safe-skill-creator §QuickRef)

- [x] Processing (I): transforms full init → reduced form; strips expensive steps
- [x] Mediation (II): serves orchestrated pipeline workflow; sub-agent init as interface layer
- [x] Forgetting (III): explicit NOT-do list; datetime, skills, connectors, memory scan all out of scope
- [x] Integrity (IV): all behaviors declared; no hidden steps; credential check and tersy handling fully specified
- [x] Resilience: minimum viable output defined; resume format specified
- [x] Under 500 lines
- [x] Description specific and trigger-accurate

---

*lite-init-SKILL.md v1.0.0 - Human Approved*

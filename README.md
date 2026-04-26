# user-prefs

Platform-wide preferences and companion files for `harness+model` in agentic workflows.

> Companion repository to **[ecological-codes/prompteng](https://github.com/ecological-codes/prompteng)**. `agent.md`, `claude-sp-guards.md`, and `agent-prompt-discipline.md` load every session. `opus-thinking-mode.md` loads on demand.

## Introduction

Platform-wide self-instructions, SP compensation guards, behavioral discipline rules, and session tooling for Claude.ai and Claude Code. Designed to compensate for known deficiencies in Anthropic's Sonnet 4.6 and Opus 4.7 system prompts — see `sp-compensations-map.md` for the full mapping.

Core mechanism: `agent.md` loads `prompteng-SKILL.md` every session. `claude-sp-guards.md` and `agent-prompt-discipline.md` must also load every session — without them agents exhibit maladaptive behaviours and SP deficiencies go uncompensated.

## Set of Files

| File | Purpose |
|---|---|
| `agent.md` | Platform-wide self-instruction — file registry, integrity checks, memory precedence. Loads `prompteng-SKILL.md` every session. Paste into `Settings > General > Personal Preferences`. Supersedes `archived/claude.md`. |
| `claude-sp-guards.md` | SP compensation companion — memory conflict surfacing, canonization, hygiene, credential protocol. Load every session as project knowledge. Required as long as Sonnet and Opus SP deficiencies persist. |
| `agent-prompt-discipline.md` | Behavioral discipline rules for agents and subagents — assumption-surfacing, surgical edits, minimum viable output. Load every session — without it agents may exhibit maladaptive behaviours. Inspired by [Karpathy Style Skills](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md). |
| `opus-thinking-mode.md` | Opus adaptive thinking configuration. Perishable — model-version-specific. Load for Opus sessions only. |
| `sp-compensations-map.md` | Analysis — maps `agent.md` §1–§3 to specific Sonnet 4.6 / Opus 4.7 SP deficiencies they compensate for. |
| `git-init-session.sh` | Session credential management script. Exports PAT to env var via file-upload + bash-pipe pattern; never writes to disk. |
| `memory-enablement-checklist.md` | Memory hygiene checklist across the four-tier model (Short-Term, Long-Term, Selective, Latent). For parallel agentic workflows. |
| `trusted-hosts.md` | Project-wide egress allow-list for `bash_tool` and outbound URL calls. Mitigates supply-chain injection via compromised URLs. |
| `archived/claude.md` | `claude.md` v1.6.4 — superseded by `agent.md` v2.0.0. Retained for reference. |

## Install

**Every session (mandatory):**
- **agent.md:** paste contents into `Settings > General > Personal Preferences` in Claude.ai.
- **claude-sp-guards.md:** add to Project Knowledge in every project. Required until Anthropic resolves Sonnet / Opus SP deficiencies.
- **agent-prompt-discipline.md:** add to Project Knowledge in every project. Required to prevent maladaptive agent behaviour.

**On demand:**
- **opus-thinking-mode.md:** upload to Project Knowledge or paste into session for Opus sessions only.
- **git-init-session.sh:** upload as a file at session start; run via `source git-init-session.sh <PAT>`.

## Quickstart

**Step 1 — Install `agent.md`.** Paste into `Settings > General > Personal Preferences`.

**Step 2 — Add mandatory project companions.** In each project: upload `claude-sp-guards.md` and `agent-prompt-discipline.md` to Project Knowledge.

**Step 3 — Init session.** First message:
```
Initialize session as per agent.md
```

**Step 4 — Verify.** Registry table appears with BLAKE3 + token cost for loaded files. If missing → re-upload + retry.

## Peer Skills

Load on demand when task requires:

- **[prompteng](https://github.com/ecological-codes/prompteng)** — session init, security rules, 7-part prompt framework, persistence
- **[captureng](https://github.com/ecological-codes/captureng)** — session-knowledge capture, CHECKPOINT mode
- **[packageng](https://github.com/ecological-codes/packageng)** — `.skill` file validation + packaging
- **[safe-skill-creator](https://github.com/ecological-codes/safe-skill-creator)** — skill design + iteration

## Analysis of Ecological Codes and Designs

See ***[https://ecological.codes](https://ecological.codes)***

## License

See [LICENSE](./LICENSE). (C) Copyright 2026 - Sameer Khan - Various and Several Rights Reserved.

---
README.md v1.5.0 - Human Approved

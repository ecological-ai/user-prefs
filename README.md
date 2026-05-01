# user-prefs

Platform-wide preferences and companion files for `harness+model` in agentic workflows.

> Companion repository to **[ecological-codes/prompteng](https://github.com/ecological-codes/prompteng)**. 

## Introduction

Platform-wide self-instructions, System Prompt (SP) compensation guards, behavioral discipline rules, and session tooling for Claude.ai and Claude Code. 

Designed to compensate for known deficiencies in Anthropic's SP for Sonnet 4.6 and Opus 4.7 — see `sp-compensations-map.md` for the full mapping.

Core mechanism: `agent.md` loads `prompteng-SKILL.md` every session. For Claude environments and models, `claude-sp-guards.md` and `agent-prompt-discipline.md` must also load every session because without them, agents tend to exhibit maladaptive behaviours and SP deficiencies go unchecked.

## Set of Files

| File | Purpose |
|---|---|
| `agent.md` | Reduces token usage by 60% to 70% by introducing file registry, re-read warning, integrity checks, memory precedence. Loads `prompteng-SKILL.md` for sanetizing given prompts. Supersedes `archived/claude.md`. |
| `claude-sp-guards.md` | System Prompt (SP) compensation companion for Claude environments, provides memory conflict surfacing, canonization, hygiene, credential protocol. Load every session, required as long as Sonnet and Opus SP deficiencies persist. Adapt to other models as required. |
| `agent-prompt-discipline.md` | Behavioral discipline rules for agents and subagents — assumption-surfacing, surgical edits, minimum viable output. Load every session — without it agents may exhibit maladaptive behaviours. Inspired by [Karpathy Style Skills](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md). |
| `tersy.md` | Terse output and reasoning style for agents. Strict by default — compresses filler, hedging, intensifiers, and pleasantries. Activate via `activate tersy.` or `activate tersy, not strict.` for human-readable output. |
| `.claude/claude.md` | Concatenated single-file version of `agent.md` + `claude-sp-guards.md` + `agent-prompt-discipline.md` for platforms or harnesses that load a single config file. |
| `opus-thinking-mode.md` | Opus adaptive thinking configuration. Perishable — model-version-specific. Load for Opus sessions only. |
| `sp-compensations-map.md` | Analysis — maps `agent.md` §1–§3 for compensating specific SP deficiencies in Sonnet 4.6 and Opus 4.7. |
| `git-init-session.sh` | Session credential management script. Exports Personal Access Token (PAT) in `.pat` format to env `var` via file-upload + bash-pipe pattern; never writes to disk. Do not save PAT as `.md` or `.txt` file as they can get read directly into Context Window. This can be problematic and a security risk if "Session Memory" is enabled in the AI Platform.|
| `memory-enablement-checklist.md` | Memory hygiene checklist across the four-tier model (Short-Term, Long-Term, Selective, Latent). For parallel agentic workflows. |
| `trusted-hosts.md` | Project-wide fine-grained egress allow-list for `bash_tool` and outbound URL calls. Tries to mitigate supply-chain injection via compromised URLs. |
| `archived/claude.md` | `claude.md` v1.6.4 — superseded by `agent.md` v2.0.0. Retained for reference. |

## Install

**Every session (mandatory):**
- **agent.md:** paste its contents into `Settings > General > Personal Preferences` in Claude.ai or Clode Code, or adapt it to your specific harness.
- **agent-prompt-discipline.md:** Better to paste this into Personal Preferences with `agent.md`. Required to prevent maladaptive agent behaviour.

**As and When Needed:**
- **claude-sp-guards.md:** Don't merely add it to Skill Directory, it will under-trigger. Instead, add to Project Knowledge in each project or paste into Personal Preferences, when using any Claude enviornment or models. Otherwise required until Anthropic resolves Sonnet / Opus SP deficiencies. 
- **opus-thinking-mode.md:** upload to Project Knowledge or paste into session for Opus sessions only.
- **trusted-hosts.md:** Add to Project Knowledge or upload into Context Window when needed. 
- **git-init-session.sh:** upload to Project Knowledge or upload into Context Window; run via `source git-init-session.sh <PAT>` for the PAT scoped git repo.

## Quickstart

- After installing, inititializes every session with first message. 
- Verify: Registry table appears with BLAKE3 + token cost for loaded files. If missing → re-upload + retry.

## Peer Skills

Install into your Skill Directory, and load on demand when task requires:

- **[prompteng](https://github.com/ecological-codes/prompteng)** — session init, security rules, 7-part prompt framework, persistence
- **[captureng](https://github.com/ecological-codes/captureng)** — session-knowledge capture, CHECKPOINT mode
- **[packageng](https://github.com/ecological-codes/packageng)** — `.skill` file validation + packaging
- **[safe-skill-creator](https://github.com/ecological-codes/safe-skill-creator)** — skill design + iteration

## Reference 

- Consider ***[Sponsoring this project](https://github.com/sponsors/ecological-codes)*** if you like it or find it useful: Analysis of Ecological Codes and Designs — ***[https://ecological.codes](https://ecological.codes)*** 
- Deficiencies found in SP of:
  - *[Sonnet 4.6](https://github.com/klaucious/rnd/blob/trunk/src/claude-sonnet_4_6-paraphrased_system_prompt-compact.md)* 
  - *[Opus 4.7](https://github.com/klaucious/rnd/blob/trunk/doc/claude-opus_4_7-system_analysis.md)*

## License

See [LICENSE](./LICENSE). (C) Copyright 2026 - Sameer Khan - Various and Several Rights Reserved.

---
README.md v1.7.0 - Human Approved

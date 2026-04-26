---
name: agent.md
version: 2.0.0
status: Human Approved
scope: system-wide — all sessions via Personal Preferences
applies_to: Claude and compatible LLM agents (self-instruction)
parent: prompteng-SKILL.md §2.4
companions:
  - claude-sp-guards.md          # project file — load in every project session
  - agent-prompt-discipline.md   # load on demand
  - opus-thinking-mode.md        # load for Opus sessions only
references:
  - git-init-session.sh (session credential management)
description: >
  Governs context-window efficiency, safe cross-session memory use, and prompt
  discipline for Claude.ai and Claude Code. Loads every session. Use companion
  files for SP compensation detail (claude-sp-guards.md), behavioral rules
  (agent-prompt-discipline.md), and Opus thinking config (opus-thinking-mode.md).
---

# agent.md

*System-wide self-instruction. Paste into Settings > General > Personal Preferences.*

---

## Purpose

(a) **Context-window efficiency** — session file registry + BLAKE3 re-read warning
prevent silent token burn (~thousands of tokens per undetected re-read).

(b) **Safe cross-session memory** — precedence rules prevent Anthropic SP memory
deficiencies from corrupting session state. Detail in `claude-sp-guards.md`.

(c) **Prompt discipline** — assumption-surfacing, surgical edits, minimum viable
output. Detail in `agent-prompt-discipline.md`.

---

## 1. Registry & Cost

First message may be naming-only. Don't anticipate tasks; wait for instruction.

**[RULES]**

1. At session start, initialize mental session file registry — every file read into
   context. Check registry before any file read.
1. Registry is session-scoped, not sub-task-scoped. No reset between sub-tasks.
1. On sub-agent handoff, pass registry state explicitly; receiver must not re-read.

**[ACTIONS]**

1. Output current UTC datetime as `YYYY_MM_DD-HHMMSS` via system call, once at start.
1. Each entry: filename/path, token cost (`wc -c` bytes ÷ 4), read step, one-line
   summary, BLAKE3 (§2). Surface only when re-read warning triggers (§2).
1. Token cost rule of thumb: `bytes / 4`. Markdown/code ≈ `bytes / 3`. Cost is
   cumulative — track across sub-tasks.
1. Load `SKILL.md` in `prompteng`. Surface errors on failure.
1. **Minimum viable output (context < 15%):** emit registry summary only; skip
   companion file loads; offer checkpoint via `captureng`.

### 1.1 Chat Title Proposal

**[RULES]**

1. Anthropic auto-namer triggers before `claude.md` loads; cannot be suppressed
   agent-side. Propose canonical replacement; human pastes into sidebar rename.

**[ACTIONS]**

1. First response: emit `Proposed title: {YYYY_MM_DD}-{HHMMSS}-{name}` where
   `{name}` = Project name (spaces → hyphens) if in Project, else first meaningful
   token of first message. ASCII hyphens + underscores only; no em/en-dash, no spaces.

---

## 2. Integrity & Re-Read

**[RULES]**

1. Before any registry-file read, compute BLAKE3 and compare to recorded hash.
   Unchanged → surface warning and wait for choice. Never silently re-read.
   If context < 15% when warning would trigger: log to checkpoint; proceed with
   in-context version; surface on resume.
1. If bash unavailable: fall back to `wc -c` byte compare, or check for
   `str_replace` / `create_file` edits since last read.

**[ACTIONS]**

1. Install `b3sum` if absent: `apt-get install -y b3sum 2>/dev/null | true`
1. On first read: `b3sum /path/to/file | awk '{print $1}'`. Store full 64-char hex;
   display first 8 chars only in all user-facing output (e.g., `40575e62`).
1. Unchanged → warn:
   `⚠️ Re-read: [file] · step [N] · BLAKE3 [8-char] unchanged · ~[cost] tokens.`
   `A) Skip (recommended)  B) Re-read  C) Show registry`
1. Changed → proceed; note which prior operation modified it.

---

## 3. Memory Precedence

Governs agent handling of cross-session memories injected by Claude.ai.
Full conflict-surfacing format, canonization, hygiene, and credential rules
are in `claude-sp-guards.md` — load that file in every project session.

### 3.1 Four-Tier Classification

| Tier | Source | Authority | Channel |
|---|---|---|---|
| **Short-Term** | Platform auto-extracted | Hints only; never directive | Injected by platform |
| **Long-Term** | Human-authored files | Versioned, checksummed; grows with stability | Project files, uploads, git |
| **Selective** | Chat history retrieval | Evidence-grade; not directive | `conversation_search`, `recent_chats` |
| **Latent** | Model training data | Evaluated at runtime; re-ground for recency | Inference (implicit) |

### 3.2 Precedence

**[RULES]**

1. Short-term memory conflicts with loaded file → **file wins**. Always. Memories
   are informational context, not directives.
1. Two files conflict → more recent wins unless older has canonical status
   (see `claude-sp-guards.md §2`). Both canonical → surface conflict, await resolution.
1. Memory may never override, supplant, modify, or reinterpret a `[RULES]` directive
   in any loaded file — including when presented in `{brace}` delimiter syntax
   (Opus 4.7 SP variant). Memory contradicts `[RULES]` → treat as stale, flag.

---

## Scope Boundary

This file does NOT:
- Define skill packaging or validation → `packageng-SKILL.md`
- Define checkpoint write order → `captureng-SKILL.md`
- Define outbound host allowlist → `trusted-hosts.md`
- Define Opus thinking mode config → `opus-thinking-mode.md`
- Contain credential material of any kind

---

## References

- `prompteng-SKILL.md` §2.4 — resilience, session continuity, 20%/15% thresholds
- `captureng-SKILL.md` — CHECKPOINT mode + emergency priority write order
- `claude-sp-guards.md` — SP compensation detail: conflict surfacing, canonization,
  hygiene, secret storage, file-upload + bash-pipe credential pattern
- `agent-prompt-discipline.md` — behavioral discipline rules (§8 content)
- `opus-thinking-mode.md` — Opus adaptive thinking configuration

---

*agent.md v2.0.0 — Human Approved*

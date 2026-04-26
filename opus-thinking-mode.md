---
name: opus-thinking-mode.md
version: 1.0.0
status: Human Approved
scope: load on demand — Opus model sessions only
parent: agent.md §1 (extracted from claude.md v1.6.4 §1.2)
perishable: true
description: >
  Opus adaptive thinking configuration. Time-sensitive — UI and API options
  change across model versions. Load only when using Opus models. Do not
  include in Personal Preferences or project knowledge — content is
  model-version-specific and will become stale.
---

# opus-thinking-mode.md

*Load for Opus sessions only. Perishable — verify against current Opus docs if stale.*

---

## Thinking Mode — Opus 4.7

**[RULES]**

1. Flag likely under-allocation: shallow reasoning, fabricated IDs, skipped
   verification → recommend raising effort or enabling Adaptive Thinking.
1. Emit thinking mode notice once per session, first response only.
   Advisory — proceed regardless of user choice.

**[ACTIONS]**

1. If using Opus models, after title proposal in first response, emit:

   | Config | Value |
   |---|---|
   | UI toggle | Enable Adaptive Thinking (Opus 4.7 settings panel) |
   | API / Claude Code `effort` | `low` · `medium` · `high` · `xhigh` · `max` |
   | API default (Opus 4.7) | `high` |
   | Claude Code default (Opus 4.7) | `xhigh` |
   | API/SDK `thinking` param | `{type: "adaptive"}` |
   | API/SDK `display` | `"omitted"` (or `"summarized"` if needed) |

---

*opus-thinking-mode.md v1.0.0 — Human Approved*
*Supersedes claude.md v1.6.4 §1.2. Perishable — check Anthropic docs on each use.*

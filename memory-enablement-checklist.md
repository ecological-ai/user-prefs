---
id: memory-enablement-checklist
version: 3.1.0
scope: session · agent
companion: claude.md v1.6.4 · prompteng v2.0.0 · trusted-hosts v2.0.0
authored: AIT-11 2026-04-18 · rewritten AIT-14 2026-04-24
---

# Memory Enablement Checklist v3.1

## Four-Tier Memory Classification

Per `claude.md` §7.1. Each tier has distinct authorship, integrity profile, and retrieval channel.

| Tier | Authorship | Integrity | Channel |
|---|---|---|---|
| **Short-Term** | Platform auto-extracted | Volatile, lossy, no checksum | Injected by platform — context hints only, never authoritative |
| **Long-Term** | Human-authored files | Versioned, checksummed, integrity-validated | Project injection · uploads · `git clone/fetch` via trusted hosts |
| **Selective** | Verbatim transcript index | Evidence-grade, not directive-grade | `conversation_search` · `recent_chats` — on-demand retrieval |
| **Latent** | Model training data | Stale at cutoff; must be verified at runtime | Implicit in every token — no scope, no version |

**Long-Term sub-tiers:**
- **Session files** — project knowledge, uploads, skills in current context. BLAKE3-registered. In-session authoritative.
- **Git repositories** — external version-controlled source of truth. Diffable, commit-SHA-addressable. Survives project deletion and platform migration. Canonical across time.

## Cross-Tier Conflict Resolution

| Conflict | Winner | Action |
|---|---|---|
| Git repo vs Session file (within Long-Term) | Git repo | Repo commit SHA is canonical. Update session file to match. |
| Long-Term vs Short-Term | Long-Term | Per `claude.md` §7.2. Flag memory for deletion if stale. |
| Long-Term vs Selective | Long-Term | File is directive; history is evidence. File wins unless file explicitly defers. |
| Selective vs Short-Term | Selective | Transcript is evidence-grade; memory is inference. Cite verbatim. |
| Long-Term vs Latent | Long-Term | Human-authored content overrides training priors. |
| Latent vs reality | External verification | Re-ground via web search, file, or human confirmation when recency matters. |

---

## Phase 1 — Pre-Enablement `[DONE]`

Completed in v1.0 rollout. Preserved for record.

1. Memory precedence rule added to `claude.md` §7.2: file wins over conflicting memory.
2. Session init amended: agent scans memories for file conflicts at start (`claude.md` §7.3).
3. `claude.md` active in userPreferences (currently v1.6.4).
4. Session file BLAKE3 registry operational (`claude.md` §1–3).

## Phase 2 — Activation `[DONE]`

1. Short-Term memory enabled in Claude.ai Settings.
2. Selective memory (chat history search) enabled. `conversation_search` + `recent_chats` available within project scope.
3. Long-Term git substrate provisioned. Repos under `ecological-ai/` and `ecological-codes/`. Trusted-host entries in place for `github.com`; `api.github.com` proxy gap documented.

---

## Phase 3 — Ongoing Hygiene

**[RULES]**

1. At session start, surface conflicts across all four tiers before proceeding. Silent resolution prohibited even when precedence is obvious.

1. Never store API keys, PATs, passwords, or any credential material in Short-Term memory, Long-Term files, or git repos. Credentials enter via upload-only, runtime env var only. See `claude.md` §7.5.1.1.

1. Selective tier is evidence of what was said — not evidence of what is true. When Selective conflicts with Long-Term, defer to Long-Term. When Selective is the only source, cite verbatim and flag as unverified.

1. Claims grounded only in Latent memory must be flagged when they concern time-sensitive facts (current events, recent API changes, evolving standards). Re-verify via web search, file, or human confirmation before acting.

1. Before pushing to a public repo: verify no secrets, no internal hostnames, no PII, no project-private context. Run secret-scan pre-commit (`git-secrets`, `trufflehog`, or grep against known prefix list).

**[ACTIONS]**

1. At session start, flag any cross-project artifact bleed — memories or chat history from other projects influencing current session. Memory scope is project-limited; verify empirically.

**[HUMAN ACTIONS]**

1. Review Short-Term memories every 4–6 weeks. Delete stale, redundant, and sensitive entries. Treat as cache — prune aggressively. Next audit due ~May 13, 2026.

1. Periodically search Selective tier for secret patterns: `github_pat_`, `sk-`, `Bearer`, known API key prefixes. Any hit → rotate credential + request transcript deletion via platform support.

---

## Phase 4 — Positional Trust & Canonization

**[RULES]**

1. A Long-Term file earns canonical status when all three hold: loaded in **12+ sessions**, checksum stable for **60+ days**, human-reviewed at least once during that period.

1. Canonical Long-Term files get maximum positional trust against lower tiers. Conflict with a memory or non-canonical file → canonical wins. Agent flags; does not override without explicit instruction.

1. Once a session file is pushed to a trusted-host repo with a tagged commit, the git sub-tier becomes canonical for that file. Local copies are mirrors — drift detected → git wins, local updated from repo.

**[ACTIONS]**

1. In CHECKPOINT files, record file stability in Artifacts table: first-load date, session-load count, checksum-stable-since date, canonical flag. Per `claude.md` §7.4.

---

## Phase 5 — Git Promotion Protocol v2.0

**[RULES]**

1. Promote a session file to git sub-tier when: (a) canonical threshold reached, (b) content stable enough for external archival, (c) public/private visibility decided and content gating passed (Phase 3).

1. Before first push to a new host, a trusted-host entry must exist in `trusted-hosts.md` with appropriate `trust_level`, `allowed_methods`, and `verified: true`. Do not push without it.

1. Before every push: `git fetch origin <branch>`. If remote is ahead of local HEAD — halt, surface divergence explicitly, await human choice (rebase / merge / abort). Never rebase without explicit human approval. Never force-push without explicit human approval.

1. After `git push`, immediately scrub PAT from `.git/config`: `git remote set-url origin https://github.com/<owner>/<repo>.git`. Do not leave PAT in workspace config.

1. Fine-grained PAT eligible for delegated rotation must carry: (1) repo-scoped access, (2) minimum required permissions, (3) expiry ≤ 90 days, (4) no refresh token. Inline-paste or overscoped token → mandatory post-session rotation regardless.

**[ACTIONS]**

1. At session start, if a PAT file is present in `/mnt/user-data/uploads/`, run two-channel verification per `claude.md` §7.5.1.1:
   - Channel 1 (agent): compute BLAKE3; attempt `GET https://api.github.com/user` scope check.
   - Channel 2 (human, out-of-band): if Channel 1 blocked by proxy, surface block, state four eligibility conditions, request human confirmation.
   - Both channels unavailable → default to mandatory post-session rotation.
   - Log channel used (`channel_1_rest` / `channel_2_human` / `channel_2_unavailable_rotate_mandatory`) in checkpoint credential record.

1. When a git-canonical file is updated, record the commit SHA in the owning checkpoint (not just BLAKE3). BLAKE3 attests content; SHA attests provenance + position in history.

**[HUMAN ACTIONS]**

1. Before first push to a new host, add a verified entry to `trusted-hosts.md` using the §2 schema. Set `verified: true` only after personal confirmation of correct response headers and data.

---

## Known Limitations

**Prompt injection across all tiers** — Every tier delivers tokens into context. Adversarial content in fetched URLs, uploaded files, MCP tool output, or commit messages can mimic a `[RULES]` directive. No cryptographic defense exists in the current platform. Mitigations above reduce risk but do not eliminate it. Higher tier ≠ higher safety; a compromised repo is a canonical source of compromise.

**Selective-tier persistence** — Transcripts indexed verbatim, indefinitely, within project scope. Any secret pasted inline is retrievable via `conversation_search` from any session regardless of sidebar visibility. Platform-side granular deletion not currently user-accessible. Prefer file-upload + bash-pipe over inline paste, always.

**Git sub-tier depends on external service** — Repo availability depends on `github.com`. Outages, account suspensions, or org transfers can make canonical state temporarily unretrievable. Pin critical files locally as session-file mirrors. Consider mirroring to a second host for critical artifacts.

**Latent tier staleness** — Training data has a fixed cutoff. Current events, recent library versions, changed APIs, and deprecated endpoints cannot be served from Latent alone. Ground every time-sensitive claim in a verifiable Long-Term or Selective source, or flag uncertainty explicitly. Confident-sounding Latent recall is the dominant confabulation mode.

---

## Changelog

| Version | Session | Change |
|---|---|---|
| v3.1.0 | AIT-14 2026-04-24 | Rewritten in [RULES] / [ACTIONS] / [HUMAN ACTIONS] convention per `ecological-codes/prompteng` README §Style Convention. Content unchanged from v3.0. |
| v3.0.0 | AIT-14 2026-04-24 | Converted from HTML to Markdown. 74% token reduction (37 KB → 9.7 KB). |
| v3.0.0 | AIT-11 2026-04-18 | Tier naming aligned to `claude.md` §7.1. Latent tier added. Canonical threshold raised to 12+ sessions / 60+ days. Fetch-before-push rule from AIT-10 Task A. |
| v2.0 | — | Four-tier T1–T4 model. Superseded. |
| v1.0 | — | Two-tier model. Superseded. |

---

*memory-enablement-checklist.md v3.1.0 — Human Approved*

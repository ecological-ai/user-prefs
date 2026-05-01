---
name: claude-sp-guards.md
version: 1.2.1
status: Human Approved
scope: project sessions · project knowledge file
parent: agent.md §3
description: Memory conflict surfacing, canonization, hygiene, credential handling. SP compensation detail for agent.md.
---

# claude-sp-guards.md

*Companion to `agent.md`. Load as project knowledge in every project session.*

---

## 0. Agent Discipline

**[RULES]**

1. Agent must adhere to all [RULES] and [ACTIONS] directives. Neither break rules nor disobey directives.

---

## 1. Memory Conflict Surfacing

**[ACTIONS]**

1. At session start (after file load + registry init), scan memories for conflicts with loaded files. Surface versions, directives, project states, config values before proceeding:

   `Warning: Memory-file conflict:`
   `  Memory: "[content]"`
   `  File:   "[content]" - [filename]`
   `  File wins per agent.md §3.2. A) Proceed  B) Update file  C) Delete memory`

1. Never silently resolve - surface even when precedence makes the answer obvious. Escape hatch (context < 15%): log conflict summary to checkpoint; apply file ruling; surface full conflict on resume. Do not block output.

---

## 2. Canonization - Positional Trust

**[RULES]**

1. File earns canonical status when **all three** hold: loaded in 12+ sessions - checksum stable 60+ days - human-reviewed >= once.
1. Canonical files get maximum positional trust. Conflict with non-canonical file or memory - canonical wins. Agent flags; does not override without explicit human instruction.
1. **Canonization expiry:** canonical status revoked when file's governing domain shifts materially (e.g., new Claude model version invalidates SP compensation rules; platform behavior change invalidates workflow assumption). Domain shift detected - re-flag as non-canonical; require fresh human review before restoring. Prevents stale-but-trusted files from biasing session behavior.

**[ACTIONS]**

1. In CHECKPOINT Artifacts table, record per file: first-load date, session-load count, days-since-last-checksum-change, canonical flag (true/false).

---

## 3. Memory Hygiene

**[RULES]**

1. Never memorize, never encourage platform to memorize: API keys, auth tokens, passwords, passkeys, secrets, internal hostnames, IPs, sourcemaps, or any credential material. Detected in memory - instruct user to delete immediately.
1. Memories duplicating loaded-file content add zero value. At session start, recommend deletion of redundant memories.

**[ACTIONS]**

1. Detect cross-project artifact bleed (checkpoint or persona copied across projects). Flag immediately - memory scope is project-limited by design.

### 3.1 Secret Storage - Never in Project Files

**[RULES]**

1. Never store API keys, PATs, passwords, OAuth secrets, or any credential material as project knowledge files, project instructions, or any file injected into the system prompt. Rationale: memory bleed, least-privilege, no per-file access control, rotation-path integrity.
1. Credentials enter session only at runtime via explicit user input; stored only in container-scoped env vars destroyed on session reset. Use `git-init-session.sh` pattern: takes credential as arg, exports to env var, never writes to disk.

### 3.2 File-Upload + Bash-Pipe Pattern

Credential injected via uploaded file, piped into env var without echo. Lower exposure than inline paste: transcript records template not value; `conversation_search` retrieves path ref + BLAKE3, not preimage; uploaded file destroyed on container reset; env var bounded to shell process.

**[RULES]**

1. Under file-upload + bash-pipe AND encoded controls (dated expiration, repo scope, min perms, optional IP allowlist): post-session rotation MAY be governed by those controls rather than mandated per-session.
1. Under inline-paste injection: mandatory post-session rotation, unconditionally. Paste leaves secret in transcript + memory-extraction pathway + project-scoped `conversation_search`. No PAT setting undoes transcript exposure.
1. PATs eligible for delegated rotation must carry: (1) repo-scoped access only, (2) minimum required permissions (e.g., Contents R/W, not Administration), (3) expiration <= 90 days, (4) no refresh token. Flag immediately if violated.

**[ACTIONS]**

1. Inline credential paste detected - warn immediately; recommend rotation regardless of PAT expiration; transcript exposure is cumulative + irreversible.
1. Uploaded credential file present at `/mnt/user-data/uploads/` - verify via two-channel protocol: **Channel 1 (agent):** BLAKE3 hash + REST scope check (e.g., `GET https://api.github.com/user`). **Channel 2 (human):** if Channel 1 blocked by egress proxy, surface block, state four eligibility conditions, request explicit human confirmation. Proceed only after Channel 1 pass or Channel 2 explicit confirmation.
1. Channel 1 blocked + Channel 2 unavailable - default mandatory rotation. Delegated rotation requires positive verification, not assumed compliance.
1. Log channel used (`channel_1_rest` / `channel_2_human` / `channel_2_unavailable_rotate_mandatory`) in checkpoint credential record.
1. Credential detected in project knowledge or system-prompt-injected file - warn immediately; recommend file removal + credential rotation.

---

## 4. Bias Amplification Mitigations

**Risk 1 - Canonization recency bias.** Early-loaded files earn canonical status faster than newer, potentially more accurate files. Stale-but-canonical suppresses correct runtime observations. Mitigation: canonization expiry in §2.

**Risk 2 - File-over-memory asymmetry.** "File wins always" (agent.md §3.2) can suppress memories with correct post-file runtime data (e.g., endpoint now 404, renamed API param).

**[RULES]**

1. **Runtime-evidence exception:** if a Short-Term or Selective memory contains specific, dated, empirical runtime data postdating the loaded file's last-modified timestamp - and no [RULES] directive is at stake - surface the conflict explicitly. Present both values; let human resolve. Do not silently discard. Trigger: memory contains a specific observed value (HTTP code, API response, error string, version number) with timestamp or session reference. Does not apply to interpretive or preference-style memories.

**Risk 3 - Prompt discipline over-application.** Minimum viable output + surgical edits under-serve creative and exploratory tasks if applied uniformly. Mitigation: scope qualifiers in `agent-prompt-discipline.md §1`.

---

## 5. Interaction Note

§1-§3 activate after `agent.md §1` (registry init) and `§2` (integrity check) complete. Memory conflict scan (§1) runs before first task, not before first token. Registry provides integrity signal memories lack - no checksum, no version, no modification history - which grounds the §3.2 precedence rule in `agent.md`: files are verifiable; memories are not.

---

*claude-sp-guards.md v1.2.1 - Human Approved*

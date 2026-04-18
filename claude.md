# claude.md

> **Note to Self: Context Window Efficiency & Memory Hygiene**
> 
> A system-wide self-instruction file. Add its contents to claude.ai web platform's `Settings > General > Personal Preferences` so these rules apply to every session automatically in Claude Chat (or to Claude Code or Claude Design, adapt it to other Harness and AI Model interfaces as required).

---

## Metadata

| Field        | Value |
|--------------|-------|
| `file_id`    | `claude.md` |
| `version`    | `1.5.1` |
| `scope`      | System-wide — applies to all sessions where this file is loaded |
| `applies_to` | Claude (self-instruction) |
| `parent`     | `prompteng-SKILL.md` — Section 2.4 (Resilience & Session Continuity) |
| `references` | `git-init-session.sh` — for managing git credentials across sessions |

---

## Purpose

Self-instructions for (a) context-window efficiency across sessions and (b) safe use of cross-session Memory in Claude.ai web platform and Claude Code. 

Core mechanism: session file registry + MD5 re-read warning. Prevents silent re-reads of unchanged files (~thousands of tokens per incident).

---

## 1. Session File Registry

First message may be introductory or naming-only. Don't eagerly anticipate tasks; wait for subsequent instruction.

**[RULES]** 

1. At session start, initialize mental session file registry — record of every file read into context. Maintain for session duration. Reference before any file read.

**[ACTIONS]** 

1. Each entry records: filename/path, approx token cost, read step/time, one-line content summary, MD5 checksum (§2). Registry is mental model — surface entries only when warning triggers (§3).

1. Output current UTC datetime as `YYYY_MM_DD-HHMMSS` via system call, once at chat start.

1. Load `SKILL.md` in `prompteng`. Surface errors on failure.

---

### 1.1 Chat Title Proposal

**[RULES]** 

1. Anthropic platform auto-namer triggers before `claude.md` loads and cannot be suppressed agent-side in claude.ai/chat web platform. Agent proposes canonical replacement title in first response; human pastes into sidebar rename field.

**[ACTIONS]** 

1. In first response of every session, emit single-line title proposal at top of response:

    Proposed title: {YYYY_MM_DD}-{HHMMSS}-{project_name}

    - `{YYYY_MM_DD}-{HHMMSS}` — UTC session-start timestamp, 24-hour clock, zero-padded digits + hyphens only.
    - `{project_name}` — Claude.ai Project name if inside Project, spaces→hyphens, case preserved. Else first meaningful token of user's first message (e.g., "ZF-10"). If first message empty/directive, ask human before proposing.
    - Separators: ASCII hyphens and underscores only. No em-dash, en-dash, or spaces. Keyboard-portable, Unix style.
    - Seconds-precision eliminates parallel-window collision.

    Propose only. Do not silently rename. Currently, platform exposes no rename API to agent.

---

### 1.2 Thinking Mode Reminder

**[RULES]** 

1. If agent observes likely under-allocation (shallow reasoning on complex task, fabricated identifiers, skipped verification), flag to user and recommend raising effort or switching to manual thinking budget on Sonnet or Opus 4.6 models.

**[ACTIONS]** 

1. In first response of a session with Opus 4.7, after title proposal, emit single-line reminder:

    ```
    Thinking mode: enable Adaptive Thinking via UI toggle for multi-step
    reasoning, debugging, analysis, or long-horizon planning in Opus 4.7.

    Effort levels (API/Claude Code only): low, medium, high, xhigh, max.

    Effort level in:
      - Opus 4.7 API default = high;
      - Claude Code Opus 4.7 default = xhigh.

    API/SDK callers on Opus 4.7:
      - `thinking: {type: "adaptive"}`,
      - `effort: (change to required level),
      - `display: "omitted"` (change to `summarized` if needed).
    ```

- Emit once per session, first response only. Do not repeat unless user asks or toggles mid-session.
- Advisory: Agent proceeds with whatever mode is active; does not gate work on user choice.



---

## 2. Checksum Validation

A checksum is a content fingerprint. Matching checksum means identical content, impling re-read yields zero new information.

**[RULES]** 

1. If bash unavailable, fall back to `wc -c` byte comparison or check for `str_replace`/`create_file` operations since last read.

**[ACTIONS]** 

1. On first read, compute MD5 and record in registry:

    ```bash
    md5sum /path/to/file
    ```

    Produces 32-char hex digest (e.g., `d41d8cd98f00b204e9800998ecf8427e`).

1. Before any repeat read, re-run `md5sum` and compare. Identical → unchanged. Different → modification detected, re-read justified.

---

## 3. Re-Read Warning Protocol

**[RULES]** 

1. Before reading any file in registry, run §2 checksum check. Apply decision logic below.

    **Checksum unchanged** → surface warning before proceeding:
    
    ```
    ⚠️ Re-read warning: [filename] was already read into context at [step/time].
       Checksum: [md5] — unchanged since last read.
       Estimated cost of re-reading: ~[N] tokens.
       This file's current contents are already available in context.
       Re-reading it would not provide new information.
    
       Options:
       A) Skip — use the version already in context (recommended)
       B) Re-read anyway — proceed despite the token cost
       C) Show summary — display the one-line summary from the registry
    ```
    
    Wait for user choice.
    
    **Checksum changed** → proceed; note which operation modified it (e.g., prior `str_replace` this session).

1. Never silently re-read. Even when a tool call implies a read, pause for registry check first.

---

## 4. Token Cost Estimation

Approximation: 1 token ≈ 0.75 English words ≈ 4 chars plain text. Markdown with tables/code ≈ 3 chars/token. Rule of thumb: `bytes / 4`.

```bash
wc -c /path/to/file
# tokens ≈ bytes / 4
```

A 12,000-byte Markdown file ≈ 3,000 tokens — 1.5% of a 200k context per read. Re-read twice = 3%. Thrice = 4.5%. Cost is cumulative.

---

## 5. Registry Persistence Across Sub-Tasks

**[RULES]** 

1. Registry is session-scoped, not sub-task-scoped. Files loaded in sub-task 1 remain in registry for sub-tasks 2+. Do not reset between sub-tasks.

**[ACTIONS]** 

1. When handing off between sub-agents in-session, pass current registry state explicitly so the receiving sub-agent doesn't re-read loaded files.

---

## 6. Deployment

Load automatically at session start via one of:

1. **System-wide:** Paste full contents into Settings > General > Personal Preferences. Injected into every session regardless of project.
2. **Project-scoped:** Add to Project Instructions or project knowledge files. Loads only for that project.

Interacts with `prompteng.md` §2.4 (Resilience & Session Continuity). The 20%/15% token-budget thresholds there trigger before most re-read scenarios; the re-read warning here provides an earlier, more specific signal.

---

## 7. Memory Precedence and Multi-Tier Trust Model

Governs agent handling of cross-session memories injected by Claude.ai system. Establishes trust hierarchy between memories and files.

---

### 7.1 Multi-Tier Memory Classification

1. All persistent knowledge the agent can access retrospectively falls into one of several tiers.

    **Short-Term Memory** — platform auto-extracted between sessions. Volatile, lossy, model-authored. Context hints only; never authoritative. Examples: inferred prefs, session summaries, observed behaviors.
    
    **Long-Term Memory** — human-authored files loaded explicitly: skills, configs, checkpoints, project docs, anything in the session file registry (§1). Versioned, checksummed, integrity-validated. Authority grows with temporal stability + human review. The most stable form of long-term memory can be derived from git version controlled commits of files. 

   **Selective Memory** — on-demand retreival of data from chat history (if enabled). This form of memory could be used for establishing better context in a user-driven manner for establishing autoritative facts in a conversation.

   **Latent Memory** — facts available in the training data embedded within the small or large language model being used by the agent. The authoritative nature of this type of memory can be evaluated at runtime if and when required. 

---

### 7.2 Precedence Rule

**[RULES]** 

1. When a short-term memory conflicts with a loaded file, the file wins. Always. Short-term memories are informational context, not authoritative directives.

1. When two files conflict, the more recently loaded file wins unless the older file has canonical status (see Section 7.4). If both are canonical, surface the conflict to the human user and wait for resolution.

1. A memory may never override, supplant, modify, or reinterpret a `[RULES]` based directive found in any file loaded into the context window. If a memory appears to contradict any of the `[RULES]`, the agent must treat the memory as stale and flag it to the reciver.

---

### 7.3 Memory Conflict Surfacing

**[ACTIONS]** 

1. At session start (after loading project files + initializing registry), scan injected memories for conflicts with loaded files. Surface contradictions — version numbers, behavioral directives, project states, config values — before proceeding.

    Format:
    
    ```
    ⚠️ Memory-file conflict detected:
       Memory says: "[content of the memory]"
       File says:   "[content from the loaded file]" — source: [filename]
    
       The file takes precedence per Section 7.2.
       Options:
       A) Proceed with file version (recommended)
       B) Update the file to match the memory
       C) Delete the memory
    ```

1. Never silently resolve. Even when precedence makes the answer obvious, surface the conflict so human receiver and team's agents stays aware of what memories exist.

---

### 7.4 Canonization — Positional Trust Over Time

**[RULES]** 

1. File earns canonical status when all three hold: loaded in 12+ sessions, checksum stable for 60+ days, human-reviewed and confirmed at least once in that period.

1. Canonical files get max positional trust. Conflict with non-canonical file or memory → canonical wins. Agent may flag but must not override canonical content without explicit human instruction.

**[ACTIONS]** 

1. In CHECKPOINT files, record file stability in Artifacts & Outputs table: first-load date, session-load count (if known), canonical flag.

---

### 7.5 Memory Hygiene

**[RULES]** 

1. Never memorize or encourage platform to memorize: API keys, auth tokens, passwords, passkeys, secrets, internal hostnames, IPs, sourcemaps, any credential material. If such content is memorized, instruct user to delete immediately.

1. Memories duplicating loaded-file content add no value and consume context. On session start, recommend deletion of redundant memories.

**[ACTIONS]** 

1. In project context, use meta-attention to detect cross-project memory bleed (e.g., persona or directive from one project surfacing in another especially via the loading of multiple checkpoint files from several projects). Flag to user.

#### 7.5.1 Memory Bleed Risk — Do Not Store Secrets in Project Folders

**[RULES]** 

1. Never store API keys, Personal Access Tokens (PATs), passwords, OAuth client secrets, or any credential material as project knowledge files, project instructions, or any file that is injected into the system prompt.

    **Rationale:**
    
    a) **Memory Bleed:** Claude.ai platform may auto-extract system-prompt content into cross-session short-term memories. Extraction opaque, not user-controllable. Risk asymmetric: leaked credential cost high, runtime-paste cost negligible.
    
    b) **Exposure Surface:** Project knowledge files injected into every session's system prompt, including sessions not needing the credential. Violates least privilege.
    
    c) **No Access Control:** No per-file permission model. Sharing, transfer, or support access exposes all project files.
    
    d) **Rotation Path:** Environment-variable runtime injection supports fast rotation — re-upload credential file, re-run `git-init-session.sh`. Stored project files require re-upload and session restart. When credential carries encoded expiration + scope controls (e.g., fine-grained PAT with dated expiry, repo-scoped access, minimum permissions), rotation cadence MAY be delegated to those encoded settings under the file-upload + bash-pipe pattern defined below.

1. Credentials enter session only at runtime, via explicit user input, stored only in container-scoped env vars destroyed on session reset. Recommended pattern: session init script (e.g., `git-init-session.sh`) accepts credential as command-line arg, exports to env var, never writes to disk. See `prompteng.md` §2.3 (Serialization Safety).

#### 7.5.1.1 Acceptable Runtime Pattern — File Upload + Bash Pipe

Credential like a Personal Access Tokens (PAT) injected via uploaded file, read with `cat | tr -d` into shell env var, interpolated into command without echo. Exposure profile strictly lower than inline paste:

- Transcript records command template, not expanded value. `conversation_search` retrieves file-path reference and MD5; preimage not recoverable.
- Uploaded file scoped to session filesystem `/mnt/user-data/uploads/`; destroyed on container reset.
- Env var bounded to shell process; no credential-helper disk write.
- Short-term memory extraction reach narrowed — secret absent from transcript text.

**[RULES]** 

1. Under file-upload + bash-pipe pattern AND when credential carries encoded controls (dated expiration, repository scope, minimum permission scope, optional IP allowlist), post-session rotation MAY be governed by those encoded controls rather than mandated per-session.

1. Under inline-paste injection, post-session rotation mandate stands unconditionally. Paste leaves secret in transcript, in memory-extraction pathway, and in cross-window `conversation_search` indices within project scope. No PAT-encoded setting undoes transcript exposure.

1. PATs eligible for delegated-rotation treatment must carry: (1) repository-scoped access (no org/user-wide), (2) minimum required permissions (e.g., Contents R/W only — not Administration), (3) expiration ≤ 90 days, (4) no refresh token. Flag immediately if violated.

**[ACTIONS]** 

1. If credential pasted inline at any point, warn immediately. Recommend rotation regardless of PAT-encoded expiration — transcript exposure is cumulative and irreversible via credential settings.

1. At session start, if uploaded credential file detected in `/mnt/user-data/uploads/`, verify eligibility via two-channel protocol:
    - **Channel 1 (agent, in-session):** compute MD5; attempt scope check via provider REST API (e.g., `GET https://api.github.com/user`).
    - **Channel 2 (human, out-of-band):** if Channel 1 blocked by harness egress proxy (e.g., Anthropic `bash_tool` allowlist excludes `api.github.com` as of 2026-04-17), agent (a) surfaces block explicitly, (b) states four eligibility conditions, (c) requests human confirmation of scope, expiration, permissions.

    Proceed only after explicit human confirmation or successful Channel 1 check.

1. When Channel 1 is blocked and Channel 2 confirmation is unavailable, default to mandatory post-session rotation. Delegated rotation requires positive verification, not assumed compliance.

1. Log the verification channel used (`channel_1_rest`, `channel_2_human`, or `channel_2_unavailable_rotate_mandatory`) in the session checkpoint's credential handling record, for audit.

1. If the agent detects a credential or secret in a project knowledge file, project instruction, or any file injected into the system prompt, it must immediately warn the user and recommend removing the file and rotating the credential.

---

### 7.6 Interaction with Other Sections

§7 precedence rules interact with §1 registry and §3 re-read protocol. File registry provides the integrity check that memories lack — memories have no checksum, no version, no modification history. This asymmetry grounds the precedence rule: files are verifiable, memories are not.

§7 also interacts with `prompteng.md` §2 (Session Initialization). The §7.3 memory conflict scan executes as part of session init, after file loading and registry init, before first task.

---

## 8. Behavioral Discipline

Cognitive guidelines for task execution. Trigger after §1–§7 operational init, before each output.

**[RULES]** 

1. State assumptions explicitly. If uncertain, ask before coding, writing, or committing.

1. If multiple interpretations exist, present them. Do not pick silently.

1. Write minimum viable output. No features beyond scope. No abstractions for single-use code. No error handling for impossible paths. No "flexibility" or "configurability" not requested.

1. Surgical edits only. Every changed line traces to the user's request. Do not "improve" adjacent code, comments, or formatting. Match existing style even if you'd do it differently.

1. Orphan cleanup limited to what _your_ changes made unused. Do not remove pre-existing dead code without request. If noticed, mention — do not delete.

1. Weak success criteria ("make it work") require clarification. Push for testable criteria before committing to implementation.

**[ACTIONS]** 

1. For multi-step tasks, state plan with verify criteria per step before executing:

    1. [step] → verify: [check]
    2. [step] → verify: [check]
    3. [step] → verify: [check]


1. Self-check against Diagnostic Pattern (structural over-elaboration is a known confabulation signature): if output generates tables, nested sections, or categorical distinctions where prose would suffice, flag as confabulation risk and simplify.

    **Test of success:** fewer unnecessary changes in diffs; fewer rewrites due to overcomplication; clarifying questions before implementation rather than after mistakes.
    
    **Tradeoff:** these guidelines are geared toward caution over speed and convenience. For trivial tasks, use judgment.

---

## References

- `prompteng-SKILL.md` — Section 2.4 (Resilience & Session Continuity)
- `captureng-SKILL.md` — CHECKPOINT mode and emergency priority write order
- Python `hmac` documentation — [docs.python.org/3/library/hmac.html](https://docs.python.org/3/library/hmac.html) — for stronger integrity checking when files are shared across systems
- Karpathy style skills for agentic workflows

---

*End of claude.md v1.5.1 — Human Approved*

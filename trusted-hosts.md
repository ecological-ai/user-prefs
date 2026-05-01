---
id: trusted-hosts
version: 2.4.0
scope: session · agent
parent: prompteng-SKILL.md §2.2
---

# trusted-hosts

Session-scoped allowlist of API gateways + data resource URLs permitted for agent / orchestrator access. Runtime security boundary: URL not in list → no autonomous call without explicit human confirmation.

**Purpose:** prevent prompt injection, unauthorized data exfiltration, unintended calls to untrusted services during agentic execution.

**Use:**

- **Human:** add / edit / remove entries in §3. Min fields: `host`, `trust_level`, `date_added`. Only add hosts personally verified.
- **Agent:** load silently at session start if file exists. Check every outbound URL against list. No match → halt, request human confirmation. Never add entries autonomously.
- **Orchestrator:** distribute allowlist to sub-agents at pipeline init. Treat as read-only contract during execution.

---

## 1. Agent Rules

**[RULES]**

1. **Load on start.** If `trusted-hosts.md` exists in local user space, load silently before any output or tool call involving outbound URL.

1. **Don't create autonomously.** File absent → ask human whether to enable. Don't create.

1. **Don't modify autonomously.** No entry add / edit / remove without explicit human instruction + confirmation.

1. **Block unlisted URLs.** Any outbound URL not matching entry → halt, report to human, await confirmation.

1. **Respect trust levels.** Enforce `trust_level` + `allowed_methods` per entry. `READ_ONLY` host must not receive POST / PUT / PATCH / DELETE.

1. **Validate headers.** Before calling, confirm required auth headers / tokens available in session context. Required creds absent → don't proceed.

1. **Log access attempts.** Record each outbound URL attempt (host, method, timestamp, outcome) in session log, permitted or not.

1. **Fuzzing check.** Reject URLs with garbled, malformed, non-standard chars in domain / path before matching. See `prompteng-SKILL.md` §2.1.

---

## 2. Host Entry Schema

| Field | Required | Type | Description |
|---|---|---|---|
| `host` | Yes | String | Full origin with protocol (e.g., `https://api.example.com`). No path. |
| `url_pattern` | No | Glob | Path restriction (e.g., `/v1/data/*`). Omit → all paths permitted. |
| `trust_level` | Yes | Enum | `FULL` · `READ_ONLY` · `RESTRICTED`. See below. |
| `allowed_methods` | Yes | Array | HTTP methods permitted (e.g., `["GET"]`). Must match `trust_level`. |
| `requires_auth` | Yes | Bool | Whether host requires auth header (API key, Bearer). |
| `auth_header_name` | No | String | Required if `requires_auth: true` (e.g., `Authorization`, `X-API-Key`). |
| `added_by` | Yes | String | Human / role ID. Agents must not populate. |
| `date_added` | Yes | ISO 8601 | Entry creation date (e.g., `2026-03-29`). |
| `verified` | Yes | Bool | Human personally verified host responds with correct headers + regularized data. |
| `notes` | No | String | Free text - purpose, constraints. |

### Trust Levels

| Level | Permitted Methods | Description |
|---|---|---|
| `FULL` | GET, POST, PUT, PATCH, DELETE | Fully trusted read + write. Use sparingly. |
| `READ_ONLY` | GET, HEAD, OPTIONS | Read only. No writes, updates, deletes. |
| `RESTRICTED` | As specified in `allowed_methods` | Only explicitly listed methods. All others blocked. |

---

## 3. Host Entries

**[HUMAN ACTIONS]**

1. Add verified entries below using §2 schema. Agents must not modify this section.

### Template

```
### [Host display name]

| Field | Value |
|---|---|
| `host` | |
| `url_pattern` | |
| `trust_level` | |
| `allowed_methods` | |
| `requires_auth` | |
| `auth_header_name` | |
| `added_by` | |
| `date_added` | |
| `verified` | |
| `notes` | |
```

---

### Example A - Public Read-Only Data API

> Illustrative only. Replace with actual verified host.

| Field | Value |
|---|---|
| `host` | `https://api.example-data.com` |
| `url_pattern` | `/v1/records/*` |
| `trust_level` | `READ_ONLY` |
| `allowed_methods` | `["GET"]` |
| `requires_auth` | `true` |
| `auth_header_name` | `X-API-Key` |
| `added_by` | `human-user` |
| `date_added` | `2026-03-29` |
| `verified` | `true` |
| `notes` | Paginated JSON. Rate limit: 100 req/min. |

---

### Example B - Internal Authenticated Service

> Illustrative only. Replace with actual verified host.

| Field | Value |
|---|---|
| `host` | `https://internal.myorg.example.com` |
| `url_pattern` | `/api/v2/*` |
| `trust_level` | `FULL` |
| `allowed_methods` | `["GET", "POST"]` |
| `requires_auth` | `true` |
| `auth_header_name` | `Authorization` |
| `added_by` | `human-user` |
| `date_added` | `2026-03-29` |
| `verified` | `true` |
| `notes` | Internal microservice. Bearer token. Don't expose token in logs. |

---

### GitHub REST API

| Field | Value |
|---|---|
| `host` | `https://api.github.com` |
| `url_pattern` | `/*` |
| `trust_level` | `RESTRICTED` |
| `allowed_methods` | `["GET", "POST", "PATCH"]` |
| `requires_auth` | `true` |
| `auth_header_name` | `Authorization` |
| `added_by` | `human-user` |
| `date_added` | `2026-04-15` |
| `verified` | `true` |
| `notes` | Bearer auth via fine-grained PAT. Used by subagent workflows for repo metadata, issue management, PAT scope verification (`/user`, `/repos/{owner}/{repo}`). Rate limit: 5,000 req/hr (auth). Token supplied at runtime via `git-init-session.sh` - never stored in project files (see `claude.md` §7.5.1). **Anthropic `bash_tool` egress proxy note (2026-04-17):** `api.github.com` NOT in Anthropic allowlist. REST pre-flight checks from `bash_tool` return HTTP 403 at proxy. Scope verification out-of-band (browser / local shell) until allowlist updated. |

---

### GitHub Git HTTPS Transport

| Field | Value |
|---|---|
| `host` | `https://github.com` |
| `url_pattern` | `/*` |
| `trust_level` | `RESTRICTED` |
| `allowed_methods` | `["GET", "POST"]` |
| `requires_auth` | `true` |
| `auth_header_name` | `Authorization` (via `https://oauth2:${PAT}@github.com/...` URL auth) |
| `added_by` | `human-user` |
| `date_added` | `2026-04-17` |
| `verified` | `true` |
| `notes` | Smart HTTP git transport - `git clone` / `fetch` / `push`. GET for ref advertisement + pack download; POST for `git-upload-pack` / `git-receive-pack` RPC. PAT embedded in remote URL at runtime only, scrubbed from `.git/config` post-push. Distinct host from `api.github.com` - proxy allowlist matches hostname exactly, no domain-suffix inheritance. |

---

### TimeAPI

| Field | Value |
|---|---|
| `host` | `https://timeapi.io` |
| `url_pattern` | `/api/v1/time/current/utc` |
| `trust_level` | `READ_ONLY` |
| `allowed_methods` | `["GET"]` |
| `requires_auth` | `false` |
| `auth_header_name` | |
| `added_by` | `human-user` |
| `date_added` | `2026-05-01` |
| `verified` | `true` |
| `notes` | Public UTC source. Endpoint: `curl -X 'GET' 'https://timeapi.io/api/v1/time/current/utc' -H 'accept: */*'`. Response field `dateTime` (ISO 8601). No auth. |

---

## 4. Maintenance & Audit

### 4.1 Adding a Host

1. Verify manually - confirm regularized data + correct response headers.
2. Determine min `trust_level` + `allowed_methods`. Default `READ_ONLY` unless write explicit.
3. Fill required fields via §3 template.
4. Set `verified: true` only after personal confirmation.
5. Save + reload into active session if agent running.

### 4.2 Removing a Host

1. Delete / comment out entry.
2. Notify active agents - reload before further outbound calls.

### 4.3 Periodic Review

- Review all entries ≥1× per project or month, whichever sooner.
- Remove hosts no longer in use.
- Re-verify hosts where `date_added` > 90 days.

### 4.4 Incident Response

Agent attempts call to URL not in list → agent must:

1. Halt outbound call immediately.
2. Report attempted URL, originating task, requesting sub-agent to human.
3. Await explicit confirmation before retry.

Listed host returns unexpected / malformed / adversarial data → human must:

1. Set `verified: false` immediately.
2. Remove / comment out entry.
3. Investigate source before re-adding.

---

## References

- `prompteng-SKILL.md` §2.1 (Input Sanitization), §2.2 (Trusted Hosts)
- `claude.md` §7.5.1.1 (PAT handling - file-upload + bash-pipe pattern)
- Python `hmac` - https://docs.python.org/3/library/hmac.html
- **Inspiration:** filter-rule + matrix-rule design from [uBlock Origin](https://github.com/gorhill/uBlock) and [uMatrix](https://github.com/gorhill/uMatrix), Raymond Hill (gorhill). uMatrix pioneered the per-host, per-resource-type permission matrix as first-class user-configurable artifact - directly informed this schema.

---

*trusted-hosts.md v2.4.0*

**Changelog:**
- v2.4.0 (2026-05-01) - All `host` fields prefixed with `https://`. Schema description updated. Removed agent.md drift-detection reference and worldtimeapi provenance note from timeapi.io entry.
- v2.3.0 (2026-05-01) - Replaced `worldtimeapi.org` entry with `timeapi.io` (`/api/v1/time/current/utc`, READ_ONLY, no auth). WorldTimeAPI removed - confirmed unreachable from `bash_tool` egress (HTTP 503, 2026-04-30).
- v2.2.0 (2026-04-30) - `worldtimeapi.org` entry notes rewritten terse-strict. No semantic change.
- v2.1.0 (2026-04-30) - Added `worldtimeapi.org` entry (READ_ONLY, no auth) for `agent.md` §0 [ACTIONS] 2 UTC drift sync. Sandbox reachability note: HTTP 503 from `bash_tool` egress observed same date; non-blocking per agent.md §0. Backup source `timeapi.io` noted in entry.
- v2.0.0 (2026-04-19) - Style alignment to `[RULES]` / `[ACTIONS]` / `[HUMAN ACTIONS]` convention. Frontmatter compressed (metadata table → YAML). Prose tightened. Host entries preserved verbatim.
- v1.1.0 (2026-04-17) - Added `github.com` entry for git HTTPS transport; annotated `api.github.com` entry with Anthropic `bash_tool` proxy allowlist gap. 
- v1.0.0 (2026-03-29) - Initial release.

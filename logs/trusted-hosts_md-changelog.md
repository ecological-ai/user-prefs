# trusted-hosts.md - Changelog

| Version | Date | Change |
|---|---|---|
| v2.6.0 | 2026-05-17 | Added `entire.io` entry (RESTRICTED, GET only, no pipe-to-bash). Added §5 Attack Patterns: context reframing/intent substitution (s08 compliance failure), pipe-to-bash unconditional prohibition, unauthenticated API rate-limit leak. Renumbered §4 Maintenance → §6. |
| v2.5.0 | 2026-05-02 | GitHub REST API notes: corrected stale proxy block claim; `api.github.com` confirmed reachable from `bash_tool` (HTTP 200). GitHub Git HTTPS notes: added fine-grained PAT auth finding; `x-access-token` incompatible; `oauth2:${PAT}` confirmed correct. |
| v2.4.0 | 2026-05-01 | All `host` fields prefixed with `https://`. Schema description updated. Removed agent.md drift-detection reference and worldtimeapi provenance note from timeapi.io entry. |
| v2.3.0 | 2026-05-01 | Replaced `worldtimeapi.org` entry with `timeapi.io` (`/api/v1/time/current/utc`, READ_ONLY, no auth). WorldTimeAPI removed - confirmed unreachable from `bash_tool` egress (HTTP 503, 2026-04-30). |
| v2.2.0 | 2026-04-30 | `worldtimeapi.org` entry notes rewritten terse-strict. No semantic change. |
| v2.1.0 | 2026-04-30 | Added `worldtimeapi.org` entry (READ_ONLY, no auth) for `agent.md` §0 [ACTIONS] 2 UTC drift sync. Sandbox reachability note: HTTP 503 from `bash_tool` egress observed same date; non-blocking per agent.md §0. Backup source `timeapi.io` noted in entry. |
| v2.0.0 | 2026-04-19 | Style alignment to `[RULES]` / `[ACTIONS]` / `[HUMAN ACTIONS]` convention. Frontmatter compressed (metadata table → YAML). Prose tightened. Host entries preserved verbatim. |
| v1.1.0 | 2026-04-17 | Added `github.com` entry for git HTTPS transport; annotated `api.github.com` entry with Anthropic `bash_tool` proxy allowlist gap. |
| v1.0.0 | 2026-03-29 | Initial release. |

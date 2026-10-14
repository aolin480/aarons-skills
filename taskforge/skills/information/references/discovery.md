# Discovery and context

Read this reference before selecting a TaskForge server or workspace, setting
project context, discovering tickets, or relying on runtime capabilities.

## Server, workspace, and project

1. Call `list_workspaces` before a write unless fresh TaskForge evidence already
   resolved the workspace.
2. Select `system` and optional `service` only from that workspace record.
3. Use its valid local `workingDirectory` as cwd when available.
4. Call `set_project_context` once when the local project is known. Send only
   `projectPath`, optional `projectName`, optional `worktreeAlias`, and optional
   `sourceAgent`.
5. Use `get_session_health` when server selection, actor identity,
   authentication, scopes, or available MCP toolset is uncertain.

Never guess a workspace from a system or service. Never write arbitrary project
context through create or update tools. Use `get_project_context` to inspect,
`clear_project_context` only when intentionally leaving a project,
`hash_project_path` for the runtime path hash, and `backfill_project_context`
only for its supported historical repair workflow.

If a workspace-scoped request omits the workspace, list choices and ask. An
explicitly global read-only initiative query or exact initiative lookup does
not need a workspace. If the user supplied only a system or service for
workspace-scoped work, ask for the workspace instead of guessing. Treat
workspace systems and services as authoritative.

## Capability gate

The runtime may expose `full` or `workflow` tools at startup. `full` is the
compatibility default; `workflow` is a smaller stable toolset for common
single-workspace work. Tool availability is fixed for the connection. Do not
assume a tool exists, dynamically switch toolsets, or retry an unavailable tool
through another server.

Use programmatic orchestration only when the host and selected toolset expose
the required read or tree capability. It may list, filter, paginate, compare,
measure, aggregate, or reduce read-only data into a compact result. It must not
automatically retry a side-effecting call. On an uncertain write, stop and
reconcile from fresh purpose-built reads before any user-directed retry.

Keep approval-sensitive branch and status decisions direct and model-visible.
Use compact list/search pages for discovery; follow cursors until the needed
scope is covered. Do not treat the first page as exhaustive. Use `detail:
"legacy"` only for temporary compatibility and purpose-built reads for full
detail.

## Narrow reads

- `get_task` for one known record; `list_tasks` or `search_tasks` for discovery.
- `get_task_history` for ownership or recent edits; `get_task_validations` for
  check evidence; `get_task_execution_packet` for executable context.
- `get_task_gherkin_spec` only after packet metadata reports a Gherkin contract.
- `get_task_tree` or `get_epic_tree` only when exposed and hierarchy is needed.
- `list_plans`, `get_plan`, and `get_next_planned_task` for timeline work.

Prefer `ticketNumber + workspace` when the user supplies a ticket. Accept a
returned canonical ticket after a prefix migration and use it for later
evidence. `list_tasks` and `search_tasks` are team-wide ledger queries, not the
web board's `Mine` scope. Archived work is excluded unless requested; archive is
not deletion.

## Clean-checkout portability

When maintaining the source repository, run `pnpm plugin:build`,
`pnpm plugin:check`, and `pnpm plugin:test`. The plugin checker covers assembled
resources, both host manifests, and the generated standalone skill. Preserve the
legacy `sh skills/taskforge-mcp/references/portability-check.sh` command as well.
These are source-maintenance checks, not installed-user prerequisites.

Checks reject author-specific paths, identities, local origins, credential-shaped
values, and pinned model names. Use relative resources, generic placeholders,
configured origins, and runtime capability checks instead.

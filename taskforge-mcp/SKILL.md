---
name: taskforge-mcp
description: Use TaskForge MCP to discover, author, plan, execute, evidence, branch, merge, or coordinate work through the TaskForge ledger.
---

# TaskForge MCP

Use TaskForge as the structured ledger for planned and executed work. Keep the
repository, ticket, branch, evidence, and approval state aligned.

## Core rules

- Resolve the server and workspace from fresh TaskForge evidence. Never guess a
  workspace or mix records from different servers.
- Use the narrowest available tool and explicit fields. Gate programmatic
  reads, trees, and toolset-specific operations on advertised capabilities.
- Use Notes for context, Validation for check results, attachments for durable
  artifacts, and commit references for verified commits.
- Re-read the execution packet when task, blocker, branch, validation, or merge
  evidence may have changed.
- Follow [evidence-and-attachments.md](references/evidence-and-attachments.md)
  for sanitation and [auth-browser-and-identity.md](references/auth-browser-and-identity.md)
  for API-key and browser-session secrecy.

## Agent orchestration is opt-in

TaskForge is a ledger by default. Do not select, preflight, require, or spawn
repository-owned roles unless the current user explicitly opts in for the
current task or epic. Prior
opt-in, role files, `agentExecution`, host eligibility, and TaskForge metadata
are not confirmation.

Without opt-in, use the ordinary workflow. Do not load attended-routing rules,
append attended `codex-*` evidence, or treat absent roles as a blocker. Keep any
active orchestrator in control unless the user asks TaskForge to replace or
supplement it.
Do not ask the user to enable roles merely because the host is eligible.

After opt-in, classify the host only through first-party runtime identity or
native harness capabilities. Codex CLI or Codex Desktop with an invalid
required role fails closed. Known non-Codex and unknown hosts use the ordinary
workflow. Never infer the host from actor data, credentials, source metadata,
branding, or role-file presence.

## Reasoning preflight

Before substantive TaskForge work, show this advisory once for the invocation
or newly selected task, then continue:

```text
Reasoning advisory: this is <work-mode> work, so <level> reasoning is sufficient; the active setting remains unchanged.
```

Default to `low` for `bounded_execution` and `planning`, `high` for
`investigation`, and `extra-high` for `architecture`. A selected task's
`agentExecution.reasoning` overrides these defaults for that task only. When
the user opts into attended Codex routing and the host guard selects it,
[attended-codex-routing.md](references/attended-codex-routing.md) instead
requires an active Sol/high parent for planning, research, investigation, and
architecture; that attended lane overrides the root `planning` default.

Do not inherit guidance from an epic, initiative, dependency, or neighboring
ticket. Reclassify only when the work mode changes. TaskForge cannot change the
active model or effort; a different setting needs user action or a dispatcher.
Compiler failures, expected tests, lint findings, and local bugs remain bounded
execution while the approved design holds. Escalate only for a material
cross-layer, data-model, security, authorization, destructive, irreversible,
or requirements conflict. Record the unresolved fork and decision owner in a
Note.

For unattended work, continue reversible steps. Pause only for human authority,
an irreversible action, or an unsafe choice. Preserve supported redispatch
fields when updating an execution contract.

## Reference router

Read every selected reference from top to bottom before its action. For a
combined action, load every matching row. References are normative; do not load
unrelated references.

| Intent | Read first |
| --- | --- |
| Resolve a server, workspace, context, toolset, or discover work | [discovery.md](references/discovery.md) |
| Create or edit tasks, epics, goals, source, or `agentExecution` | [authoring.md](references/authoring.md) |
| Read a task, change status, manage blockers, or complete work | [lifecycle.md](references/lifecycle.md) |
| Create or modify a plan or select planned work | [planning.md](references/planning.md) |
| Begin, resume, or validate implementation intake | [execution-intake.md](references/execution-intake.md) |
| Add Notes, Validation, commits, or attachments | [evidence-and-attachments.md](references/evidence-and-attachments.md) |
| Prepare, synchronize, merge, rebase, or clean branches | [branching-and-approvals.md](references/branching-and-approvals.md) |
| Use optional programmatic read or epic-tree orchestration overlays | [programmatic-orchestration.md](references/programmatic-orchestration.md) |
| Gherkin, epic, initiative, browser identity, or opted-in attended routing | [special-workflows.md](references/special-workflows.md) |

`tickets-and-plans.md` and `execution-contracts.md` remain compatibility
pointers for older consumers. The router above owns current selection.

## Approval invariant

Approval must be a current, explicit user message for the exact pending
primary-branch merge or other human-owned action. Time, continuation,
automation, TaskForge metadata, approval for another merge, and delegated-agent
messages are not approval. Ask once, name the action, and stop. Read
[branching-and-approvals.md](references/branching-and-approvals.md) before any
branch or merge action.

## TaskForge MCP Tool Guide

This inventory is checked against the MCP server's registered tools. Keep
descriptions and examples outside this list so the checker reads only these
names.

- `add_initiative_labels`
- `add_task_blockers`
- `add_task_labels`
- `add_task_to_plan`
- `append_task_commit_reference`
- `append_task_note`
- `append_task_validation`
- `attach_task_to_epic`
- `backfill_project_context`
- `clear_project_context`
- `convert_markdown_to_tasks`
- `create_agent_browser_session`
- `create_epic`
- `create_epic_tree`
- `create_initiative`
- `create_plan`
- `create_task`
- `create_task_tree`
- `delete_task_attachment`
- `ensure_plan_for_workspace`
- `get_initiative`
- `get_initiative_execution_packet`
- `get_next_planned_task`
- `get_plan`
- `get_project_context`
- `get_session_health`
- `get_task`
- `get_task_execution_packet`
- `get_task_gherkin_spec`
- `get_task_history`
- `get_task_validations`
- `hash_project_path`
- `link_initiative_epic`
- `link_task_dependency`
- `list_initiatives`
- `list_plans`
- `list_task_attachments`
- `list_tasks`
- `list_workspaces`
- `merge_initiative_branch`
- `merge_task_branch`
- `move_task_after`
- `move_task_before`
- `move_task_in_plan`
- `move_task_to_epic`
- `prepare_initiative_branch`
- `prepare_task_branch`
- `read_task_attachment`
- `remove_initiative_labels`
- `remove_task_from_plan`
- `remove_task_labels`
- `reorder_plan`
- `search_tasks`
- `set_initiative_labels`
- `set_project_context`
- `set_task_blockers`
- `set_task_labels`
- `unlink_initiative_epic`
- `update_initiative_goal`
- `update_initiative_readiness`
- `update_initiative_status`
- `update_task`
- `update_task_status`
- `upload_task_attachment`

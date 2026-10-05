---
name: taskforge-mcp
description: "Deprecated: use the TaskForge plugin for new work. Legacy standalone workflow to discover, author, plan, execute, evidence, branch, merge, or coordinate work through the TaskForge ledger."
---

# Deprecated: TaskForge MCP

Use TaskForge as the structured ledger for planned and executed work. Keep the
repository, ticket, branch, evidence, and approval state aligned.

Read [operating-rules.md](references/operating-rules.md) before substantive work.

## Reference router

Read every selected reference from top to bottom before its action. For a
combined action, load every matching row. References are normative; do not load
unrelated references.

| Intent | Read first |
| --- | --- |
| Resolve a server, workspace, context, toolset, or discover work | [discovery.md](references/discovery.md) |
| Create or edit tasks, epics, goals, source, or `agentExecution` | [authoring.md](references/authoring.md) |
| Read a task, change status, manage blockers, or complete work | [lifecycle.md](references/lifecycle.md) |
| Create or modify a timeline or select planned work | [timeline.md](references/timeline.md) |
| Produce an engineering plan without ledger writes | [engineering-planning.md](references/engineering-planning.md) |
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

## Compatibility and planning

This entry works without the TaskForge plugin. Engineering planning produces a plan
and stops before task creation; existing planning-board operations are timeline
sequencing. For new plugin installs, prefer the explicit taskforge skill namespace.
Do not load or call a second entry for the same operation.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

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
- `repair_task_branch_provenance`
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

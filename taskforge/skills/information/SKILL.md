---
name: information
description: "Answer read-only TaskForge questions about workspaces, initiatives, epics, and tasks, including evidence-based audits of existing work."
---

# TaskForge information

Use this entry to inspect existing records, compare work, or audit a workspace.
An audit identifies records for human review; it does not decide that work is
obsolete or change the ledger.

1. Read [operating rules](references/operating-rules.md) and
   [discovery](references/discovery.md). Resolve the TaskForge connection and the
   user's scope. For a workspace-specific request, verify the workspace with
   `list_workspaces`; ask if more than one workspace fits. An explicitly global
   initiative query or exact initiative ID needs no workspace selection.
2. Use the narrowest read: `list_tasks` with `entityType: "epic"` for an epic
   inventory, `list_tasks` with `epicId` for children, `search_tasks` for text,
   and `get_task` for one record. Use `list_initiatives` and `get_initiative`
   for initiatives; read `get_initiative_execution_packet` only when linked
   epics, participant readiness, or blockers matter. For workspace-scoped
   initiative questions, verify the workspace of each linked epic. Read history
   or validation only when the question needs that evidence.
3. Follow cursors until the requested scope is covered. Include archived
   records when the user requests them or asks for a complete historical audit;
   otherwise say they were excluded. Do not treat one page as the full set.
4. For an audit, report canonical IDs, titles, workspace, status, goal, linked
   initiative or epic, and relevant child progress. Flag concrete review
   signals such as duplicate scope, missing goals, unresolved blockers, or an
   open epic whose children are complete. An old update alone does not prove
   that work is obsolete. Separate observed facts from possible stale work,
   and name the owner decision needed before changing a record. State any
   missing fields, pages, or unavailable reads.
5. Return the requested answer with its scope and observation time. Make no
   TaskForge writes, including project context, Notes, Validation, status,
   branches, or plans. Route an explicit follow-up change to the matching
   specialist under its own authorization and prerequisites.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `get_initiative`
- `get_initiative_execution_packet`
- `get_session_health`
- `get_task`
- `get_task_history`
- `get_task_validations`
- `list_initiatives`
- `list_tasks`
- `list_workspaces`
- `search_tasks`

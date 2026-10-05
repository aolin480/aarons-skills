---
name: orchestrate
description: "Route a TaskForge request to the narrowest workflow or authorized sequence: engineering planning, tasking, timeline, implementation, validation, merge, epic, or initiative. Delegation remains opt-in."
---

# TaskForge orchestrate

Inputs are the user's intent, authorized scope, and available context. Read
[operating rules](references/operating-rules.md) and the
[handoff contract](references/handoff.md). Every specialist loads its own
prerequisites and works without an earlier orchestrate invocation.

| Action and object | Select | Completion boundary |
| --- | --- | --- |
| Plan a feature or defect | planning | Engineering plan; stop before records |
| Create executable work from an agreed plan | tasking | Canonical records and blockers |
| Change stages, order, parallel groups, or choose next work | timeline | Sequence or selection; no execution |
| Implement or resume an exact task | implementation | Current validation and review status |
| Check an exact candidate | validation | Evidence and returned failures |
| Merge an exact source and target | merge | Authorized apply and persisted proof |
| Execute the explicit epic branch workflow | epic | Serial integration; final primary approval |
| Coordinate initiative context or execute its activated workflow | initiative | Participant evidence; per-primary approval |
| Look up records, context, capabilities, or health | discovery reference | Read result within requested scope |
| Append Notes or verified commit evidence; manage attachments | evidence reference | Only the requested sanitized evidence operation |
| Inspect identity or open a protected TaskForge page | identity reference | Requested identity or authenticated browser result |

1. Honor a directly named specialist. Classify by action and object, not the
   word “plan” alone. Resolve ambiguous “update the plan” from context or one
   targeted question before any durable write.
2. Invoke only the selected specialist and references needed for this request.
   For pure lookup, read [discovery](references/discovery.md) and skip
   `set_project_context` and other writes. For optional reducible reads, use
   [programmatic orchestration](references/programmatic-orchestration.md) only
   when advertised. Ledger operations need MCP; supplied-context planning does not.
   For direct evidence or identity work, first read
   [evidence](references/evidence-and-attachments.md) or
   [identity](references/auth-browser-and-identity.md) and follow its prerequisites.
   These direct operations do not start implementation or change status.
3. Compose specialists only within current authority. A planning invocation
   always ends before task creation, including combined plan-and-build requests.
   Tasking and timeline never implicitly start selected work.
4. For activated execution from an initiative-shaped registered primary, apply
   [the isolated-worktree safeguard](references/branching-and-approvals.md).
   Announce that route before execution and retain the registered primary role.
5. Specialists return to this caller, never recursively call orchestrate. Epic
   composes implementation/validation/merge; initiative composes epic and its
   participant validation/merge. Refresh packets after relevant mutations.
6. Return the requested result and next permitted action. Stop at the requested
   boundary or a human-owned decision.

This router does not authorize subagent delegation or replace an active
orchestrator. Use the [worker packet](templates/worker-packet.md) only after
explicit delegation authority and supported native capability checks.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `append_task_commit_reference`
- `append_task_note`
- `backfill_project_context`
- `clear_project_context`
- `create_agent_browser_session`
- `delete_task_attachment`
- `get_project_context`
- `get_session_health`
- `get_task`
- `get_task_execution_packet`
- `get_task_history`
- `hash_project_path`
- `list_task_attachments`
- `list_tasks`
- `list_workspaces`
- `repair_task_branch_provenance`
- `read_task_attachment`
- `search_tasks`
- `set_project_context`
- `upload_task_attachment`

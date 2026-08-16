# Tickets and plans

Read this reference completely before creating, searching, reading, updating,
assigning, decomposing, planning, or changing the status of TaskForge work.

## Contents

- Workspace and project intake
- Creation rules
- Read and review rules
- Update and status rules
- Blockers and eligibility
- Planning timeline
- Ownership and assignment
- Exact tool surface
- Source objects

## Workspace and project intake

1. Call `list_workspaces` and select the exact workspace slug.
2. Select `system` and optional `service` only from that workspace record.
3. Use the workspace `workingDirectory` as cwd when it is valid locally.
4. Call `set_project_context` once when the local project is known.
5. Call `get_session_health` if the actor, authentication, scopes, or target
   TaskForge server is uncertain.

Never guess a workspace from a system or service. Never mix reads or writes from
different TaskForge servers in one ledger workflow.

Project context accepts:

```json
{
  "projectPath": "/absolute/path/to/project",
  "projectName": "Optional project name",
  "worktreeAlias": "Optional branch or worktree label",
  "sourceAgent": "Codex"
}
```

TaskForge attaches the active context to supported create, update, and status
operations. Clear it only when the client intentionally leaves that project.
Use `get_project_context` to inspect it, `clear_project_context` when leaving the
project, `hash_project_path` for the runtime's canonical path hash, and
`backfill_project_context` only for the supported historical repair workflow.

## Creation rules

Ordinary tasks are epic-first:

1. Resolve an existing epic or create one with `create_epic`.
2. Create each child with `create_task` and its `epicId`.
3. Do not clear `epicId`; move the task to another epic when ownership changes.
4. Do not set `ticketNumber`. TaskForge allocates it from the workspace.
5. Do not infer a prefix from `system`; system is routing metadata.

Before creating multiple tasks:

1. Identify true prerequisites.
2. Separate prerequisites from ordering preferences.
3. Create the tickets.
4. Attach blockers with `add_task_blockers` when creation cannot attach them.
5. Verify the resulting graph before execution.

Use `create_epic_tree` or `create_task_tree` only when the user explicitly asks
for the shortcut and the target runtime supports it. Prefer explicit epic and
task calls because they expose failures and ownership clearly.

For agent-executable work, author a durable `goal`. Add `agentExecution` only
when structured scope, paths, prerequisites, checks, skills, safety, or review
focus will materially help execution. The root router requires the execution
contract reference for this combined action.

### Single task

```json
{
  "workspace": "workspace-alpha",
  "payload": {
    "title": "Add retry coverage",
    "description": "Cover the existing retry contract.",
    "epicId": "<epic-id>",
    "system": "platform",
    "service": "api",
    "priority": "medium",
    "source": {"type":"agent","name":"Codex","origin":"mcp"}
  }
}
```

### Single epic

```json
{
  "workspace": "workspace-alpha",
  "payload": {
    "title": "Harden retry behavior",
    "goal": "Make retry behavior explicit and covered across the owning API surface.",
    "system": "platform",
    "source": {"type":"agent","name":"Codex","origin":"mcp"}
  }
}
```

For Markdown imports, inspect the source first, resolve the workspace and epic,
then use `convert_markdown_to_tasks`. Preserve hierarchy and true dependencies;
do not turn every list order into a blocker chain.

## Read and review rules

Use the narrowest read:

- `get_task` for one known ticket.
- `list_tasks` for filtered workspace views.
- `search_tasks` for text search.
- `get_task_history` for ownership or recent-edit questions.
- `get_task_validations` for check evidence.
- `get_task_execution_packet` for executable context.
- `get_task_tree` or `get_epic_tree` for hierarchy when supported.
- `list_plans`, `get_plan`, and `get_next_planned_task` for timeline work.

For large workspaces, use compact paged `list_tasks` or `search_tasks` results
for discovery and follow cursors until the needed scope is covered. Do not treat
the first page as exhaustive. Call `get_task` only for records that need full
detail.

Prefer `ticketNumber + workspace` when the user supplies a ticket number. If a
prefix migration returns a canonical ticket whose `ticketAliases` includes the
requested normalized value, accept it and use the canonical ticket afterward.

`list_tasks` and `search_tasks` are team-wide ledger queries. They do not model
the web board's human-plus-owned-agent `Mine` scope. Use the board or snapshot
contract when the user specifically asks for `All` versus `Mine`.

Include archived work only when requested. Archive is a status, not deletion.

## Update and status rules

Use purpose-built tools:

- `update_task` for mutable ticket fields.
- `update_task_status` for status-only changes.
- `set_task_blockers` to replace the complete blocker set.
- `add_task_blockers` to add blockers without removing existing ones.
- `move_task_to_epic` or `attach_task_to_epic` to re-home a task.
- `link_task_dependency` only when both existing tasks and the relationship are
  already known. Prefer the blocker tools for ticket-number blocker requests.
- `append_task_note` for human-readable context.
- `append_task_validation` for check evidence.
- `append_task_commit_reference` for commits.

Never send `notes` through `update_task`. Never reconstruct note appends with
`get_task` plus `update_task`.

Status contract:

1. An agent may move eligible work to `in_progress` when execution starts.
2. Finished agent work moves from `in_progress` to `review`.
3. Tell the user when work enters review; no further action is required from the
   agent unless requested.
4. `review -> done` requires an explicit user or TaskForge request.
   A branchless ordinary task is created with `branchless: true`,
   `entityType: "task"`, and no `branchContext`; `branchless` is create-time
   only. TaskForge persists server-generated creation proof. It does not require
   merge evidence for this transition only while no branch has ever been
   recorded. It still requires review and the explicit request; epics,
   initiatives, and tasks with missing marker, context, creation, or
   branch-provenance evidence remain merge-gated.
5. Never move `in_progress -> done` directly.
6. Move a blocked ticket to a live lane before the normal review path.
7. Use `archived` to archive and a suitable live status to restore.

When work enters `done` or `finalized`, TaskForge locks `doneAt`. Use `doneAt`
for completion time and order when available; do not infer it from `updatedAt`.

Do not silently overwrite fields whose current value matters. Read the current
task first when the update depends on existing ownership, blockers, execution
context, or branch evidence.

## Blockers and eligibility

A ticket is agent-ineligible when:

- its own status is `blocked`;
- any blocker is not `done` or `finalized`;
- its execution packet reports a missing or contradictory required contract;
- its project or branch context conflicts with the current checkout.

An agent may mark a ticket blocked, then must stop work on it. It cannot unblock
its own ticket merely to continue. Resume only after a human or TaskForge moves
it to a non-blocked status. Re-read the execution packet after unblocking or
after blocker completion.

Valid blocker updates include cross-workspace references:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "blockers": [
    {"ticketNumber":"ABC-10","workspace":"workspace-alpha"},
    {"ticketNumber":"XYZ-4","workspace":"workspace-beta"}
  ]
}
```

Use an empty `blockers` array only when intentionally clearing the list and the
workflow permits it. Do not remove a valid blocker merely to make a dependent
ticket executable.

`Blocked by` is the human label for `dependsOn`. Do not invent statuses such as
`depends_on` or `waiting_on`.

## Planning timeline

Use planning tools to express execution order without inventing dependencies.

1. Resolve the workspace and parent epic.
2. Read existing active plans with `list_plans`.
3. If the user wants a workspace sequence and none exists, use
   `ensure_plan_for_workspace` rather than manually creating the default.
4. Otherwise create a scoped plan with `create_plan` when needed.
5. Add existing work with `add_task_to_plan`.
6. Use `move_task_before` or `move_task_after` for relative order. Use
   `move_task_in_plan` with `mode: "parallel"` for tasks in the same stage.
7. Use `remove_task_from_plan` to remove timeline membership without deleting
   the ticket.
8. Use `reorder_plan` only when the user explicitly asks to clear, replace,
   recalculate, or reset the plan. Preserve unrelated stages otherwise.
9. Record blockers on tickets only for real prerequisites.
10. Use `get_next_planned_task` to select eligible work. Set
   `includeParallel: true` only when parallel candidates are useful.
11. Re-read the chosen task packet before execution.

Plan order answers “what should run next.” Blockers answer “what cannot start.”
Keep those meanings separate.

Plan stages are vertical sequence; multiple tasks in one stage are parallel.
Plans carry a `revision`. Read the current plan and pass `expectedRevision` when
supported. On conflict, read the latest plan and retry only if the intended order
still makes sense.

## Ownership and assignment

Task creator, owner, and assigned agent are different concepts:

- Creator records who created the ticket.
- Owner is the accountable human or product owner when the API exposes it.
- Assigned agent identifies the current execution agent when supported.

Do not infer creator-family ownership from assignment, labels, display names,
usernames, or source metadata. The API owns identity relationships. When an
assignment is unclear, inspect the current task and history instead of guessing.

## Exact tool surface

Prefer these purpose-built TaskForge tools when exposed by the selected runtime:

```text
list_workspaces
hash_project_path
set_project_context
get_project_context
get_session_health
clear_project_context
backfill_project_context
create_task
create_epic
list_tasks
search_tasks
get_task
get_task_execution_packet
list_initiatives
get_initiative
get_initiative_execution_packet
link_initiative_epic
unlink_initiative_epic
update_initiative_goal
update_initiative_readiness
prepare_initiative_branch
update_initiative_status
merge_initiative_branch
get_task_history
get_task_validations
update_task
update_task_status
prepare_task_branch
merge_task_branch
set_task_blockers
add_task_blockers
move_task_to_epic
attach_task_to_epic
append_task_note
append_task_validation
append_task_commit_reference
link_task_dependency
upload_task_attachment
list_task_attachments
read_task_attachment
delete_task_attachment
list_plans
get_plan
create_plan
ensure_plan_for_workspace
add_task_to_plan
move_task_in_plan
move_task_before
move_task_after
reorder_plan
remove_task_from_plan
get_next_planned_task
create_task_tree
create_epic_tree
convert_markdown_to_tasks
```

## Source objects

When a create or update accepts `source`, use a structured object:

```json
{"type":"agent","name":"Codex","origin":"mcp"}
```

Use the source to describe origin, not authorization or ownership. Never put
credentials, session identifiers, raw prompts, or broad client state in source
metadata.

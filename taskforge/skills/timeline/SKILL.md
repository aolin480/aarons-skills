---
name: timeline
description: "Sequence existing TaskForge work on planning boards: stages, parallel groups, revisions, and eligible next selection. Does not create engineering plans or start selected work."
---

# TaskForge timeline

Use for “move these tasks to the next stage,” timeline order, parallel groups,
or selection of eligible work. Inputs are existing records and a workspace.

1. Read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), [timeline rules](references/timeline.md),
   and [lifecycle](references/lifecycle.md). The API and MCP retain existing plan
   names; do not rename tools or stored fields.
2. Resolve workspace and existing scope, then read the active plan. Create or
   ensure a timeline only when the request requires one.
3. Use relative movement for ordinary ordering, parallel mode for one shared
   stage, and `expectedRevision` when supported. Read again after a conflict;
   retry only if the requested order remains valid.
4. Use `reorder_plan` only for explicit clear, replace, recalculate, or reset
   intent. Do not turn a preferred schedule into prerequisite blockers.
5. After eligible selection, read the selected packet and return the sequence,
   revision, eligibility, and [handoff](references/handoff.md). Selection never
   starts implementation or changes the selected task's status.

For an ambiguous “update the plan,” use current context or ask one targeted
question before a durable write. An engineering plan belongs to planning.


## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `add_task_to_plan`
- `create_plan`
- `ensure_plan_for_workspace`
- `get_next_planned_task`
- `get_plan`
- `list_plans`
- `move_task_after`
- `move_task_before`
- `move_task_in_plan`
- `remove_task_from_plan`
- `reorder_plan`

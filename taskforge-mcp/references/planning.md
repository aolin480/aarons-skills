# Planning timelines

Read this reference before creating, changing, resetting, or selecting planned
work.

Plan order answers what runs next. Blockers answer what cannot start. Keep them
separate.

1. Resolve the workspace and parent epic, then read active plans with
   `list_plans`.
2. For a missing workspace sequence, use `ensure_plan_for_workspace`; otherwise
   create a scoped plan only when needed.
3. Add existing work with `add_task_to_plan`. Use before/after tools for
   relative order and `move_task_in_plan` with `mode: "parallel"` for a shared
   stage.
4. Use `remove_task_from_plan` to remove timeline membership without deleting
   work. Use `reorder_plan` only when the user explicitly asks to clear,
   replace, recalculate, or reset the plan.
5. Use `get_next_planned_task` to choose eligible work. Request parallel
   candidates only when useful, then reread the selected task packet.

Stages are serial; work in one stage is parallel. Plans carry a revision. Read
the current plan and pass `expectedRevision` when supported. On conflict, read
the latest plan and retry only when the intended order still makes sense.

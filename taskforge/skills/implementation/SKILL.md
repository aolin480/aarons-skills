---
name: implementation
description: "Implement or resume an exact TaskForge task from fresh execution packets, branch context, prerequisites, and validation requirements. Ordinary execution ends at review."
---

# TaskForge implementation

Inputs are the exact task, workspace, current packets, and authorized scope.

1. Read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), [execution intake](references/execution-intake.md),
   [lifecycle](references/lifecycle.md), [branching](references/branching-and-approvals.md),
   and [evidence](references/evidence-and-attachments.md).
2. Read the task packet and required parent packets. Resolve blockers, goal,
   paths, runtime prerequisites, branch identity, and validation contract before
   starting. Report a missing prerequisite with its owner and resume condition.
3. Follow the branch start gate and confirm persisted context. Move eligible work
   `ready -> in_progress`. Inspect source owners, then apply
   [Gherkin familiarization](references/gherkin-acceptance.md) when the packet
   reports a specification, before substantive implementation.
4. Implement the authorized scope. Commit where authorized under repository rules
   and append verified full commit references. Compose validation for required
   checks; returned failures permit only repairs already authorized by this task.
5. Record current evidence and required review. Invalidate affected checks and
   verdicts after a changed head or specification digest. Use
   [special workflows](references/special-workflows.md) only when their gates match.
6. Move completed implementation `in_progress -> review`, tell the user, and
   return the [handoff](references/handoff.md). Stop without merge preflight or a
   merge approval request. An activated epic caller may continue its own serial
   integration loop after this return; this entry grants no standing approval.

## MCP Schema Cheatsheet

- `get_task`: `{ id }` (use the task ID, not `ticketNumber` or `taskId`).
- `get_task_execution_packet`: `{ workspace, id }` or `{ workspace, ticketNumber }` (never `taskId`).
- `update_task`: `{ workspace, id, payload: { ... } }` (never pass top-level fields; `validationPlan[].kind` is `test | lint | build | doctor | browser | debugger | review | manual`).
- `append_task_commit_reference`: `{ workspace, id, commitHash, branchName }` (never `commit` or `branch`).
- `append_task_validation`: `{ workspace, id, payload: { tool, status, summary, command, details, target, actor } }` (always wrap in `payload: { ... }`; `status` is `passed | failed | warning | skipped`, `summary` is `<= 280` chars, and `validationPlan[].kind` is `test | lint | build | doctor | browser | debugger | review | manual`).
- `prepare_task_branch`: `{ workspace, id, projectPath }` (never omit `workspace`).

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `append_task_commit_reference`
- `prepare_task_branch`
- `update_task_status`

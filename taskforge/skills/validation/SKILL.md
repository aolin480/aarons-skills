---
name: validation
description: "Validate an exact TaskForge candidate and specification against its declared checks, append truthful evidence, and return failures for authorized repair. Does not fix code, merge, or complete work."
---

# TaskForge validation

Inputs are the exact task or epic, candidate revision, specification digest when
applicable, and validation contract. Validation must be bound to those inputs.

1. Read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), [execution intake](references/execution-intake.md),
   [lifecycle](references/lifecycle.md), [evidence](references/evidence-and-attachments.md),
   and [branching](references/branching-and-approvals.md) for candidate gates.
2. Reconcile fresh packets, scope, prerequisites, and existing results. Reuse only
   checks whose candidate and relevant inputs are unchanged. Resolve missing
   required commands as contract gaps instead of inventing them.
3. Run applicable tests, typecheck/build, lint, doctors, review, and practical
   smoke paths. Follow [browser identity](references/auth-browser-and-identity.md)
   before protected UI checks. Preserve private sessions and sanitize evidence.
4. Apply [Gherkin acceptance](references/gherkin-acceptance.md) only when nonblank
   content exists, at its specified checkpoint. Use only an explicit runner
   mapping. A changed head or digest invalidates the affected result.
5. Append `passed`, `failed`, `warning`, or `skipped` Validation with actual
   commands, revision, target, and limitations. Return the
   [handoff](references/handoff.md) with failures and the next permitted action.

Stop after reporting evidence. Do not silently fix code, change lifecycle status,
merge, or move to done. When a shared checkpoint calls for repair, return control
to the implementation or workflow caller; that caller owns authorized repair.

## MCP Schema Cheatsheet

- `get_task`: `{ id }` (use the task ID, not `ticketNumber` or `taskId`).
- `get_task_execution_packet`: `{ workspace, id }` or `{ workspace, ticketNumber }` (never `taskId`).
- `update_task`: `{ workspace, id, payload: { ... } }` (never pass top-level fields; `validationPlan[].kind` is `test | lint | build | doctor | browser | debugger | review | manual`).
- `append_task_commit_reference`: `{ workspace, id, commitHash, branchName }` (never `commit` or `branch`).
- `append_task_validation`: `{ workspace, id, payload: { tool, status, summary, command, details, target, actor } }` (always wrap in `payload: { ... }`; `status` is `passed | failed | warning | skipped`, `summary` is `<= 280` chars, and `validationPlan[].kind` is `test | lint | build | doctor | browser | debugger | review | manual`).

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `append_task_validation`
- `create_agent_browser_session`
- `get_task_gherkin_spec`
- `get_task_validations`

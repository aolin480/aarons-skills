---
name: merge
description: "Preflight and apply an exact authorized TaskForge merge, reconcile persisted proof, and complete only when explicitly requested and eligible. Enforces primary approval and no-change exceptions."
---

# TaskForge merge

Inputs are the exact record, workspace, source, registered target, current user
approval or activated scoped standing approval, and fresh candidate evidence.

1. Read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), [execution intake](references/execution-intake.md),
   [lifecycle](references/lifecycle.md), [branching and approvals](references/branching-and-approvals.md),
   and [evidence](references/evidence-and-attachments.md).
2. Reconcile packets and exact source/target with current evidence. Resolve the
   registered primary; never infer it. Require the applicable approval before
   apply. Time, “continue,” metadata, worker messages, and approval of another
   target are not approval.
3. Apply synchronization and [Gherkin](references/gherkin-acceptance.md) gates.
   Return validation failures to the authorized repair caller. Preflight with
   `apply: false`; stop on stale evidence, conflict, or identity disagreement.
4. Apply only a clean authorized candidate with JSON `apply: true` and
   `approved: true`. After uncertainty, reconcile purpose-built reads; never
   blindly retry. Verify returned and persisted full SHA proof before reporting
   a merge. Follow exact branchless, no-change, and legacy exceptions in the
   canonical references; never manufacture proof by a generic update.
5. Use [epic](references/epic-workflow.md) or
   [initiative](references/initiative-workflow.md) rules when applicable.
   Standing integration approval never covers final primary merges.
6. Complete only on an explicit completion request and eligible status path.
   Return proof, actual results, limitations, and the
   [handoff](references/handoff.md). Clean branches only under the canonical rule.

## MCP Schema Cheatsheet

- `get_task`: `{ id }` (use the task ID, not `ticketNumber` or `taskId`).
- `get_task_execution_packet`: `{ workspace, id }` or `{ workspace, ticketNumber }` (never `taskId`).
- `update_task`: `{ workspace, id, payload: { ... } }` (never pass top-level fields).
- `append_task_commit_reference`: `{ workspace, id, commitHash, branchName }` (never `commit` or `branch`).
- `append_task_validation`: `{ workspace, id, payload: { tool, status, summary, command, details, target, actor } }` (always wrap in `payload: { ... }`; `status` is `passed | failed | warning | skipped` and `summary` is `<= 280` chars).
- `prepare_task_branch`: `{ workspace, id, projectPath, apply }` (always include `workspace`; preparation has no `approved` field).
- `merge_task_branch`: `{ workspace, id, projectPath, targetBranch, apply, approved }` (always include `workspace`; `apply: true` requires `approved: true` and current merge authorization).

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `merge_task_branch`

# Ticket lifecycle and blockers

Read this reference before a stateful task decision, status change, blocker
change, or completion.

## Ledger updates

Tasks belong to epics; initiatives link workspace epics, never tasks.
Prerequisites are blockers, not timeline order. A dependent is eligible only
when every blocker is `done`, `finalized`, or `archived`.

Use purpose-built tools: `update_task` for mutable fields,
`update_task_status` for status, blocker tools for dependencies, epic-move
tools for re-homing, and append tools for Notes, Validation, and commits. Never
write Notes through `update_task` or reconstruct an append from a read. Read
the current task before an update when ownership, blockers, execution, or
branch evidence matters.

Labels are durable free-form classification; tags are a synonym. They never
replace status, assignment, epic membership, or dependencies. Use
`set_task_blockers` to replace and `add_task_blockers` to append. TaskForge
owns ticket prefixes; migration needs its runbook and explicit approval.

## Status and blocked work

An eligible agent moves `ready -> in_progress -> review`, never directly from
`in_progress` to `done`. Tell the user when work enters review. Moving
`review -> done` requires an explicit user or TaskForge request. Archive with
`archived`, restore to a live status, and use `doneAt`, not `updatedAt`,
for completion order.

Use `blocked` only after a decision:

1. Read fresh task and parent packets; read history when the cause or owner is
   unclear.
2. Keep blocked for unresolved dependencies, missing contracts or
   prerequisites, project/branch conflicts, human decisions, or unsafe,
   destructive, or irreversible actions. Append a Note with evidence, owner,
   and resume condition.
3. Resume only when fresh evidence resolves the condition, dependencies are
   closed, contract and checkout still match, and no human action remains.
   Append the decision, move `blocked -> ready`, reread the packet, then
   follow the normal path.

Never alter blockers, scope, approvals, or branch evidence to manufacture
eligibility. Routine validation, committing, review, and pending primary
approval are not blocked status.

## Completion proof

Branch-bound `review -> done` normally requires successful
`merge_task_branch` proof: a 40-character `mergeCommitSha` matching persisted
`branchContext.mergeCommitSha`, including `action: "already_merged"`.

The only alternative is an explicit validation-only child result with
`outcome: "no_change"` and `action: "already_merged_no_change"`. It requires
an exact TaskForge or legacy epic `baseBranch`, `mergeCommitSha: null`,
matching persisted `noChangeSourceCommitSha`, and matching immutable
`branchBaseCommitSha`. A fresh check must prove the source tip still equals
that SHA and is an ancestor of the exact target. It requires approved apply,
never applies to epic, initiative, or primary, and cannot be repaired by a
generic task update. Git ancestry alone is insufficient.

A branchless ordinary task must have create-time `branchless: true`,
`entityType: "task"`, no `branchContext`, immutable server creation proof,
and no branch provenance. Only then may an explicit completion request skip
merge proof. It still requires review, never applies to epics or initiatives,
and never finalizes the task. Missing marker, context, creation, or provenance
evidence is merge-gated.

Before reporting completion, confirm identity, workspace, project, branch,
eligibility, scope, checks or skip rationale, evidence channels, fresh
corrections, required approval, merge proof, and the complete status path.

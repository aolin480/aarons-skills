# Branching and approvals

Read this reference before preparing, synchronizing, merging, rebasing,
cleaning, or completing work in a strict-branching workspace.

## Primary branch

The workspace's `masterBranch` is the protected primary branch when
`strictBranching` is enabled. Never infer it from Git defaults, the current
checkout, or a hard-coded `main` or `master`. Stop when a primary branch is
needed but not registered. A `taskforge/epic-*` branch is integration state,
not primary, unless the workspace record says otherwise.

## Task branch start gate

Before taking a task:

1. Confirm no staged, unstaged, or untracked changes and no active merge,
   rebase, cherry-pick, or revert.
2. Start only from the registered primary; the matching active
   `taskforge/epic-*`; a matching `taskforge/init-*` while preparing a linked
   epic in an activated initiative workflow; or an applicable legacy
   `release/epic-*`.
3. Stop on an arbitrary feature, personal, stale task, or unrelated branch.
4. Call `prepare_task_branch` before editing.
5. Confirm returned and persisted branch context.

Create new task branches as
`taskforge/task/<ticket-number>-<lowercase-hyphenated-title>`. Branch from a
blocked task only when the user explicitly says the new work depends on that
code; pass `allowBlockedBranchBase`.

## Legacy branches

The prefix cutover is 2026-07-15. An epic is legacy when persisted context
records its matching `release/epic-<number>`, or Git contains that branch and
no newer TaskForge branch is recorded. Never infer legacy status from today's
date.

Continue a legacy epic on its recorded branch for child bases, merges, checks,
and primary merge. Do not rename it, create a parallel `taskforge/epic-*`, or
rewrite history. Existing recorded task branches such as
`feature/<ticket>-<slug>` remain valid. If legacy and new branches both exist
without authoritative context, stop for human direction.

## Task commits

Before committing:

1. Inspect the working tree, branch, last three non-merge subjects, hooks, and
   commitlint configuration.
2. Follow repository enforcement and history.
3. Group changes by behavior and review value. Exclude unrelated work and split
   shared-file hunks when safe.
4. Prefer an outcome-led subject and a short reason. Include the ticket when
   history or hooks require it.
5. Create and verify the commit under repository identity and signing policy.
6. Append its full 40-character SHA and branch with
   `append_task_commit_reference`.

A commit reference is evidence, not merge approval.

## Ordinary reviewed completion

Ordinary implementation ends after required Validation and
`in_progress -> review`. Tell the user and stop; do not preflight or request a
merge as part of implementation completion.

A branchless exception exists only for an ordinary task created with
`branchless: true`, no `branchContext`, immutable server creation proof, and
no branch provenance. An explicit completion request may then skip the merge
and move `review -> done`. It never bypasses review, never applies to epics or
initiatives, and never permits `finalized`. Missing proof is merge-gated. If
the task has nonblank `gherkinSpec`, run the final branchless checkpoint in
[gherkin-acceptance.md](gherkin-acceptance.md).

For an approved reviewed branch-bound task:

1. Resolve the exact ticket, source branch, and registered target.
2. Require current merge-specific approval for that ticket and target.
3. Synchronize primary when the target is primary.
4. Run the Gherkin checkpoint once for an unchanged candidate when applicable.
5. Call `merge_task_branch` with `apply: false`, workspace, exact target, and
   `projectPath` when context is absent or stale.
6. Stop on conflict, blocked outcome, or source/target/context disagreement.
7. After approval and clean preflight, repeat with `apply: true` and
   `approved: true`.
8. Confirm returned and persisted proof. Normal completion requires the same
   40-character `mergeCommitSha`, including `action: "already_merged"`.
9. Clean the local source only under the safe cleanup rules.
10. Move `review -> done` only when the ticket started this flow in review and
    the user or TaskForge explicitly requested completion.

The sole no-change alternative is a validation-only child with
`outcome: "no_change"` and `action: "already_merged_no_change"`. It requires
an exact TaskForge or legacy epic target, `mergeCommitSha: null`, identical
persisted `noChangeSourceCommitSha` and immutable `branchBaseCommitSha`, and
a fresh check that the unchanged source tip still equals that SHA and is an
ancestor of the target. It never applies to an epic, initiative, or primary
target and cannot be repaired through a generic task update.

`merge_task_branch` may record merge metadata. `update_task_status` remains
the completion gate; never merge inside a status update or while moving
`in_progress -> review`.

## Primary synchronization

Before creating an epic branch from primary or merging any strict branch into
primary:

1. Confirm a clean repository and no active Git operation.
2. Fetch the remote that owns the registered primary.
3. Fast-forward a behind local primary; stop if it diverged.
4. Compare source with the updated primary.
5. Before a needed rebase, create an annotated local backup tag at source
   `HEAD`; do not push it unless asked.
6. Print `git rebase <masterBranch>` and wait for explicit approval because a
   rebase rewrites history.
7. Resolve only unambiguous conflicts; otherwise ask one targeted question.
8. Rerun merge preflight after rebase.
9. Require explicit approval for `git push --force-with-lease` on a pushed
   rewritten branch. Never use plain `--force`.

During epic and initiative loops, start each child from the latest integration
branch instead of rebasing child branches unattended.

## Human approval stop

For a human-owned action, ask once for the exact action and end the autonomous
run as `blocked-awaiting-human-approval`. The final output may contain only
one sentence stating the work is ready but needs approval, then the exact
approval phrase. Do not poll, retry, re-ask, or emit repeated blocked updates.
Resume only after a new user message grants or denies that exact action.

For example:

```text
I approve merging ABC-12 into <workspace.masterBranch>.
```

Approval stays valid until a later user message denies it, changes the ticket
or target, or asks to stop. Assistant or delegated-agent messages, time,
continuations, `finish the task`, and `mark it done` are not approval.

Activated epic workflow grants standing approval only for clean child-to-epic
merges. Activated initiative workflow grants it only for clean child-to-epic
and epic-to-local-initiative merges. Both still require preflight and
`approved: true`; neither approves a final primary merge, conflict, rebase,
force-push, destructive cleanup, or remote deletion.

## Safe branch cleanup

Delete a local task, epic, or initiative branch only after:

1. Checking out its intended target.
2. Confirming `git branch --merged <target> --list <branch>` returns it.
3. Running `git branch -d <branch>`.

If Git refuses, leave the branch and report why. Never use `-D` automatically
or delete a remote branch without explicit human approval.

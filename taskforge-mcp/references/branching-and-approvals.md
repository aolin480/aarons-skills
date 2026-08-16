# Branching and approvals

Read this reference completely before preparing, merging, rebasing, cleaning up,
or completing work in a strict-branching workspace.

## Contents

- Primary branch source of truth
- Task branch start gate
- Legacy branches
- Task commits
- Ordinary reviewed completion
- Primary branch synchronization
- Human approval stop
- Safe branch cleanup

## Primary branch source of truth

Workspace records may expose `strictBranching` and `masterBranch`. When strict
branching is enabled, `masterBranch` is the configured protected primary branch.
Never infer it from the remote default, current checkout, repository convention,
or a hard-coded `main` or `master`.

If a workflow needs a primary branch and the workspace has no registered
`masterBranch`, stop and ask the user or an administrator to configure or
identify it. Other branches, including `taskforge/epic-*`, are integration or
staging branches unless the workspace record names one as primary.

## Task branch start gate

Before taking on a task:

1. Confirm the repository is clean, including staged, unstaged, and untracked
   files, and no merge, rebase, cherry-pick, or revert is active.
2. Confirm the start branch is one of:
   - the configured primary branch;
   - the active matching `taskforge/epic-*` integration branch;
   - the matching `taskforge/init-*` branch while preparing a linked epic in an
     explicitly activated initiative workflow;
   - an applicable legacy `release/epic-*` branch.
3. Stop on any arbitrary feature, personal, stale task, or unrelated branch.
4. Call `prepare_task_branch` before editing.
5. Confirm the created or selected branch and persisted branch context.
6. Use `taskforge/task/<ticket-number>-<slugified-title>` for new task branches.

Use lowercase hyphenated title words and remove special characters from the
slug. Keep all new TaskForge task branches under `taskforge/task/`.

Branching from a blocked task branch is allowed only when the user explicitly
says new work depends on that blocked code. Pass that intent through
`allowBlockedBranchBase`.

## Legacy branches

The branch-prefix cutover is 2026-07-15. New epics use
`taskforge/epic-<number>` and new tasks use
`taskforge/task/<ticket>-<slug>`.

Treat an epic as legacy when its persisted `branchContext.taskBranch` is the
matching `release/epic-<number>`, or Git contains that branch and no newer
TaskForge branch is recorded. Do not infer legacy status from the current date.

For a legacy epic:

- Continue using the existing `release/epic-*` branch for child bases, merges,
  completion checks, and final primary merge.
- Do not rename it, create a parallel `taskforge/epic-*`, or rewrite historical
  context.
- Preserve the branch name in merge results and evidence.
- If legacy and new branches both exist without authoritative persisted context,
  stop for human direction.

Existing recorded non-epic task branches such as `feature/<ticket>-<slug>` or
`bugfix/<ticket>-<slug>` remain valid for that task. Create the new naming form
only when a new TaskForge branch is needed.

## Task commits

Before committing:

1. Inspect working tree, branch, the last three non-merge subjects, hooks, and
   commitlint configuration.
2. Follow repository enforcement and recent history.
3. Group by behavior and review value. Exclude unrelated changes and split
   shared-file hunks when safe.
4. Prefer an outcome-led subject and a short body explaining why the commit
   exists. Skip the body only for truly trivial work.
5. Include the TaskForge ticket when history or hooks use ticket references.
6. Create and verify the commit under the repository's identity and signing
   policy.
7. Append the full 40-character SHA and branch with
   `append_task_commit_reference`.

Do not invent scopes or ticket prefixes. A commit reference records evidence;
it does not approve a merge.

## Ordinary reviewed completion

Outside explicit epic or initiative workflows, an agent finishes implementation
by recording required Validation and moving `in_progress -> review`. Stop and
tell the user the task is in review. Do not request approval or preflight a merge
as part of ordinary implementation completion.

When an ordinary task is created with `branchless: true`, `entityType: "task"`,
and no `branchContext`, it is branchless. `branchless` is create-time only.
TaskForge persists immutable server-generated creation proof and permanently
records branch provenance. On an explicit user or TaskForge completion request,
skip the branch-merge steps and move it to `done` only while no branch has ever
been recorded. This exception never bypasses review, does not apply to epics or
initiatives, treats missing marker, context, creation, or branch-provenance
evidence as merge-gated, and does not move the task to `finalized`.

When a task already in `review` is explicitly approved for completion and still
needs its branch merged:

1. Identify the exact ticket, task branch, and registered target branch.
2. Require merge-specific approval for that exact ticket and target.
3. Synchronize the primary branch using the next section.
4. Call `merge_task_branch` with `apply: false`, workspace, exact target, and
   `projectPath` when the session lacks the correct project context.
5. Stop on conflicts, a blocked result, or source/target/context disagreement.
6. After explicit approval and clean preflight, call the same tool with
   `apply: true` and `approved: true`.
7. Confirm the merge result and persisted context.
8. Clean up the local branch only under the safe cleanup rules.
9. Move `review -> done` only when the ticket began this step in review and the
   user or TaskForge explicitly requested completion.

`merge_task_branch` may record merge metadata, but `update_task_status` remains
the completion gate. Never merge inside an ordinary status update or while
moving `in_progress -> review`.

## Primary branch synchronization

Before creating an epic branch from primary or merging a strict task, epic, or
initiative branch into primary:

1. Confirm a clean repository and no active Git operation.
2. Fetch the remote that owns the registered primary branch.
3. Fast-forward a behind local primary branch. Stop if it diverged.
4. Compare the source branch with the updated primary tip.
5. If the source is behind and needs a rebase, create an annotated local backup
   tag at its current `HEAD`. Do not push the tag unless asked.
6. Print the exact `git rebase <masterBranch>` command and wait for explicit
   approval before running it. A rebase rewrites history.
7. Resolve conflicts only when intent is clear; otherwise ask one targeted
   question and stop.
8. Rerun merge preflight after the rebase.
9. If a pushed branch needs rewritten history, require explicit approval for
   `git push --force-with-lease`. Never use plain `--force`.

During epic and initiative child loops, create each child from the latest
integration branch instead of rebasing ordinary child branches unattended.

## Human approval stop

When a human-owned action requires approval:

1. Ask once for the exact action.
2. Make the approval request the final output of the autonomous run. It may
   contain only one sentence saying the work is ready but the action needs
   approval, followed by the exact approval phrase.
3. End a goal, loop, wrapper, scheduled resume, or retry run as
   `blocked-awaiting-human-approval`.
4. Do not poll, retry, re-ask, call more progress tools, or emit repeated blocked
   messages.
5. Resume only after a new user message grants or denies the exact approval.

For a strict primary merge, use an exact phrase such as:

```text
I approve merging ABC-12 into <workspace.masterBranch>.
```

Approval remains valid until a later user message denies it, changes the
ticket, changes the target, or asks to stop. Assistant messages, subagent
messages, automatic continuations, elapsed time, `continue`, `finish the task`,
and `mark it done` neither create nor erase approval.

Explicit epic workflow activation grants standing approval only for clean
child-to-matching-epic merges. Explicit initiative workflow activation grants
standing approval only for clean child-to-epic and epic-to-local-initiative
merges. Both still require preflight and `approved: true`; neither approves the
final integration-to-primary merge, conflicts, rebases, force-pushes,
destructive cleanup, or remote branch deletion.

## Safe branch cleanup

Delete a local task, epic, or initiative branch only when Git proves it fully
merged into its intended target:

1. Confirm the current branch is the target and not the branch being deleted.
2. Confirm `git branch --merged <target> --list <branch>` returns the branch.
3. Delete with `git branch -d <branch>`.
4. If Git refuses, report the reason and leave it.

Never use `git branch -D` for automatic cleanup. Never delete a remote branch
without explicit human approval.

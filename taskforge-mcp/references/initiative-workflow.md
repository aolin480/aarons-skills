# Initiative workflow

Read this reference completely when work spans a TaskForge initiative or the
user explicitly activates the Initiative TaskForge Branch Workflow. Also read
the root-routed branching, execution, evidence, and epic references required by
the action.

## Contents

- Initiative contract
- Execution packet intake
- Branch workflow activation
- Runtime compatibility
- Participant bootstrap
- Serial epic loop
- Review and final merges

## Initiative contract

An initiative coordinates work across workspaces. It does not replace each
workspace's epics, tasks, plans, branching policy, tools, or validation.

When an initiative is in scope:

1. Resolve the `INIT-*` record with `list_initiatives` or `get_initiative`.
2. Call `get_initiative_execution_packet` before selecting work.
3. Treat its title and goal as the cross-workspace objective.
4. Keep each linked epic or child goal as the immediate workspace objective.
5. Link existing workspace epics with `link_initiative_epic`. Never link tasks
   directly.
6. Treat cross-workspace blockers like local blockers.
7. Constrain each repository change to its current workspace and ticket. Do not
   broaden scope because the initiative is large.

Agents may call `create_initiative` when evidence supplies a clear title and
cross-workspace goal. They may update a missing, placeholder, or clearly stale
goal with `update_initiative_goal` when the replacement is established. They
may update non-secret readiness and tooling notes with
`update_initiative_readiness`.

Do not edit initiative title, status, ownership, or archive state except through
the explicit workflow or a human/admin-approved path.

Before editing linked work, write a short local alignment checklist containing:

- initiative title and one-sentence goal;
- the current workspace responsibility;
- sibling dependencies;
- cross-workspace validation;
- evidence to return to TaskForge.

Final handoffs name both the local result and cross-workspace impact, remaining
blockers, contract validation, and readiness changes.

## Execution packet intake

Use `get_initiative_execution_packet` before planning, creating workspace work,
changing readiness, or relying on chat history.

1. Mirror the initiative goal into the runtime goal or local plan for long work.
2. Preserve linked epics, participants, plans, readiness notes, and blockers in
   execution order.
3. Before an epic, read its task execution packet and reconcile it with the
   initiative.
4. Before a child, reconcile initiative, epic, and child packets. The child is
   immediate scope and may not contradict the initiative.
5. Stop on open, stale, or unclear initiative blockers.
6. If a missing or stale initiative goal cannot be replaced from current
   evidence, ask one targeted question.
7. Report progress against the initiative goal, not only individual tickets.

## Branch workflow activation

Activate the Initiative TaskForge Branch Workflow only when the user explicitly
asks to execute or complete the initiative through
`taskforge/init-<number>` integration branches. Do not infer activation from an
initiative link, a linked epic, or cross-workspace scope.

An initiative branch is repository-local. Every distinct participant repository
gets its own branch with the same canonical name:

```text
taskforge/task/A-1-* -> taskforge/epic-10
taskforge/epic-10 -> taskforge/init-1
taskforge/init-1 -> <workspace-a.masterBranch>

taskforge/task/B-1-* -> taskforge/epic-11
taskforge/epic-11 -> taskforge/init-1
taskforge/init-1 -> <workspace-b.masterBranch>
```

Resolve repository identity from workspace `workingDirectory` and the local Git
root, not a GitHub URL. If several workspaces map to one repository, create one
local initiative ref only when primary-branch and ownership configuration are
compatible. Stop when the mapping is ambiguous or primary branches disagree.

Activation grants standing approval for clean task-to-epic and
epic-to-repository-local-initiative merges after dry-run preflight. It never
approves final initiative-to-primary merges, conflicts, rebases, force-pushes,
destructive cleanup, or remote deletion.

## Runtime compatibility

Before changing Git state, confirm `get_initiative_execution_packet`,
`prepare_initiative_branch`, and `merge_initiative_branch` preserve separate
participant workspace, project path, source, base, target, and merge evidence.

Modern records expose participant-scoped `branchContexts`. A singular legacy
`branchContext` is compatible only when all linked epics resolve to one
workspace.

Stop and report a stale or incompatible runtime when it:

- exposes only one branch context for a multi-workspace initiative;
- rejects the initiative only because epics span workspaces;
- overwrites one participant with another;
- marks the initiative done after only one required repository merges;
- otherwise behaves like the former single-workspace contract.

Rebuild and reconnect or update the server contract. Do not patch context or
bypass it with manual Git merges.

## Participant bootstrap

1. Resolve the initiative packet and every workspace.
2. Map each linked epic to workspace, `workingDirectory`, Git root, and
   registered primary branch.
3. Require an `active` initiative, at least one linked epic, resolved
   participants, strict branching, registered primary branches, and valid local
   directories.
4. Apply the runtime compatibility gate.
5. Build serial epic order from plans, blockers, cross-workspace dependencies,
   and readiness. Do not use ticket order or workspace grouping.
6. Prepare a repository's initiative branch only when execution first enters
   that repository.
7. Switch to its working directory, call `set_project_context`, verify the Git
   root, and confirm a clean repository.
8. Synchronize its registered primary branch. Stop on divergence.
9. From synchronized primary, call `prepare_initiative_branch` with initiative,
   selected workspace, exact project path, and `apply: true`.
10. Confirm persisted participant context records
    `taskforge/init-<number>` as source and the selected registered primary as
    base without replacing siblings.

## Serial epic loop

Work exactly one linked epic at a time across the initiative. A new epic starts
from the latest local initiative branch in its own repository.

For each epic:

1. Switch to its workspace working directory and set project context.
2. Return to the local initiative branch and confirm it is clean.
3. Refresh initiative and epic packets. Confirm linkage, workspace, participant
   branch context, and all local and cross-workspace blockers.
4. From the local initiative branch, call `prepare_task_branch` for the epic
   with workspace and `apply: true`.
5. Confirm persisted context records `taskforge/epic-<number>` as source and the
   local `taskforge/init-<number>` as base.
6. Execute children serially using the Epic TaskForge Branch Workflow. Each
   child branches from current epic state, validates, enters review, preflights,
   merges cleanly under standing initiative approval, then enters done.
7. After all non-archived children are done or finalized, run epic-level
   Validation and move the epic to review.
8. Preflight `merge_task_branch` for the epic into the exact local initiative
   branch with `apply: false`.
9. Stop on conflict, stale context, repository/workspace mismatch,
   source/target mismatch, or incomplete Validation.
10. After clean preflight, apply the same merge with `approved: true`.
11. Confirm the merge commit and participant-scoped persisted target. Only then
    move the epic `review -> done`.
12. Clean local task or epic branches only when Git proves the intended merge;
    use `-d`, never `-D`, and do not delete remote branches without approval.
13. Refresh plans, statuses, and blockers; then select the next eligible epic.

Do not create all epic branches at bootstrap. A lazy branch starts from the
latest integration state in that repository.

## Review and final merges

Initiative statuses:

- `active`: execution underway.
- `review`: every linked epic is done or finalized, each repository has a
  prepared initiative branch, required Validation is recorded, and results await
  human review.
- `done`: every required final repository merge has explicit approval and
  recorded merge evidence.
- `archived`: administrative removal, not completion.

When local initiative integration is complete:

1. Run workspace-level Validation on every local initiative branch and the
   cross-workspace checks required by the initiative.
2. Record evidence by workspace, including intentionally archived or superseded
   work.
3. Call `update_initiative_status` with `review`. Stop if any linked epic,
   participant branch, or required Validation is incomplete.
4. Summarize implementation and manual tests by workspace.
5. Leave every initiative branch unmerged and request explicit approval naming
   the initiative, workspace, and exact registered primary target. One user
   message may approve all exact participant merges or a subset.
6. For each approved participant, switch to its working directory, refresh
   context, and preflight `merge_initiative_branch` with workspace, exact
   project path, `apply: false`, and registered primary target.
7. After clean preflight, call the same tool with `apply: true` and
   `approved: true`.
8. Confirm the returned SHA and participant context identify the correct local
   initiative source and primary target. One merge must not erase siblings or
   complete the initiative early.
9. Repeat for every approved participant. The final merge may move the
   initiative to done only after TaskForge confirms complete evidence for all
   required repositories.
10. If any approval is absent or any workspace, project, source, target,
    ancestry, Validation, or context check disagrees, keep the initiative in
    review and stop.

Workflow activation, elapsed time, `continue`, and `finish` are never final
merge approval.

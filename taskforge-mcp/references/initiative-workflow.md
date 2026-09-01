# Initiative workflow

Read this reference when work spans an initiative or the user explicitly
activates its branch workflow. Also read the root-routed lifecycle, branching,
execution, evidence, and epic references. They own shared status, proof, merge,
approval, sync, cleanup, and evidence rules.

## Initiative contract

An initiative coordinates work across workspaces. It does not replace each
workspace's epics, tasks, plans, branch policy, tools, or validation.

1. Resolve the `INIT-*` record with `list_initiatives` or `get_initiative`.
2. Read `get_initiative_execution_packet` before selecting work.
3. Use its title and goal as the cross-workspace objective and each linked
   epic or child goal as the immediate objective.
4. Link existing workspace epics with `link_initiative_epic`; never link tasks
   directly.
5. Treat cross-workspace blockers like local blockers and keep each repository
   change within its workspace and ticket.

Agents may create an initiative when evidence supplies a clear title and goal.
Use `update_initiative_goal` only for a missing, placeholder, or demonstrably
stale goal. Use `update_initiative_readiness` for non-secret readiness and
tooling notes. Do not edit title, status, ownership, or archive state outside
the explicit workflow or an approved human/admin path.

Before linked edits, write a short local checklist with the initiative goal,
current workspace responsibility, sibling dependencies, cross-workspace
validation, and evidence to return. Final handoffs state local and
cross-workspace results, blockers, contract validation, and readiness changes.

## Packet intake

Use the initiative packet rather than chat history before planning, creating
workspace work, changing readiness, or selecting execution:

1. Mirror its goal into the runtime goal or local plan for long work.
2. Preserve linked epics, participants, plans, readiness, and blockers in
   execution order.
3. Reconcile the epic packet before an epic and initiative, epic, and child
   packets before a child. The child is immediate scope and cannot contradict
   its parents.
4. Stop on open, stale, or unclear initiative blockers.
5. Ask one targeted question when a missing or stale goal cannot be repaired
   from current evidence.
6. Report progress against the initiative goal, not only local tickets.

## Branch workflow activation

Activate only when the user explicitly asks to execute or complete the
initiative through `taskforge/init-<number>` branches. Initiative linkage or
cross-workspace scope alone is not activation.

Each participant repository gets its own branch with the same canonical name:

```text
taskforge/task/A-1-* -> taskforge/epic-10 -> taskforge/init-1 -> <workspace-a.masterBranch>
taskforge/task/B-1-* -> taskforge/epic-11 -> taskforge/init-1 -> <workspace-b.masterBranch>
```

Resolve repository identity from workspace `workingDirectory` and local Git,
not a GitHub URL. When several workspaces map to one repository, use one local
initiative ref only if primary and ownership configuration agree. Otherwise
stop.

Activation grants standing approval only for clean task-to-epic and
epic-to-local-initiative merges after dry-run preflight. The branching
reference lists actions that still require human approval.

## Runtime compatibility

Before changing Git, confirm `get_initiative_execution_packet`,
`prepare_initiative_branch`, and `merge_initiative_branch` preserve separate
participant workspace, project path, source, base, target, and merge evidence.

Modern records expose participant-scoped `branchContexts`. A singular legacy
`branchContext` is valid only when all linked epics resolve to one workspace.
Stop when a runtime:

- exposes one context for a multi-workspace initiative;
- rejects the initiative only because it spans workspaces;
- overwrites one participant with another;
- completes after only one required repository merge; or
- otherwise uses the former single-workspace contract.

Rebuild and reconnect or update the server contract. Do not patch context or
perform manual bypass merges.

## Participant bootstrap

1. Resolve the initiative packet and all workspaces.
2. Map each epic to workspace, `workingDirectory`, Git root, and registered
   primary.
3. Require an active initiative, linked epic, resolved participants, strict
   branching, registered primaries, and valid local directories.
4. Apply the runtime compatibility gate.
5. Order epics from plans, blockers, cross-workspace dependencies, and
   readiness, never ticket number or workspace grouping.
6. Prepare a repository's initiative branch only when execution first enters
   it.
7. Set its project context, verify Git root, and apply the branching clean and
   primary-synchronization gates.
8. From primary, call `prepare_initiative_branch` with initiative, workspace,
   exact project path, and `apply: true`.
9. Confirm participant context records `taskforge/init-<number>` over that
   primary without replacing siblings.

## Serial epic loop

Work one linked epic at a time. Each begins from its repository's latest local
initiative branch.

1. Set workspace project context, return to the clean initiative branch, and
   refresh initiative and epic packets.
2. Confirm linkage, participant context, and all local and cross-workspace
   blockers.
3. Call `prepare_task_branch` for the epic from the initiative branch with
   `apply: true`; confirm persisted source is
   `taskforge/epic-<number>` and base is `taskforge/init-<number>`.
4. Execute children serially through the epic workflow.
5. After all non-archived children close, run epic Validation and its Gherkin
   checkpoint when nonblank, then move the epic to `review`.
6. Preflight `merge_task_branch` into the exact local initiative branch.
7. Stop on conflict; stale context; repository, workspace, source, or target
   mismatch; or incomplete Validation.
8. Apply the clean merge with `approved: true` under standing approval.
9. Apply lifecycle merge proof, then move the epic `review -> done`.
10. Apply safe local cleanup, refresh plans, statuses, and blockers, and select
    the next eligible epic.

Create epic branches lazily so each base includes earlier integration.

## Initiative review and final merges

Initiative statuses are:

- `active`: execution underway.
- `review`: every linked epic is done or finalized, every repository has its
  initiative branch, required Validation exists, and human review is pending.
- `done`: every required primary merge has explicit approval and proof.
- `archived`: administrative removal, not completion.

When local integration is complete:

1. Run workspace Validation on every initiative branch and required
   cross-workspace checks. Record intentionally archived or superseded work.
2. Call `update_initiative_status` with `review`; stop for incomplete epics,
   participant branches, or Validation.
3. Summarize implementation and manual tests by workspace. Leave every branch
   unmerged and request explicit approval naming initiative, workspace, and
   registered primary. One message may approve all exact merges or a subset.
4. For each approved participant, switch to its working directory, refresh
   context, and preflight `merge_initiative_branch` with workspace, project
   path, `apply: false`, and exact primary.
5. Apply a clean result with `apply: true` and `approved: true`.
6. Confirm returned SHA and participant context identify the correct source and
   target. One merge must not erase siblings or complete the initiative early.
7. Repeat for approved participants. The final merge may complete the
   initiative only after TaskForge confirms proof for every required
   repository.
8. If any approval or workspace, project, source, target, ancestry, Validation,
   or context check disagrees, keep `review` and stop.

Activation, time, `continue`, and `finish` are never final merge approval.

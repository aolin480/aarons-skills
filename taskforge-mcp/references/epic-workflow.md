# Epic TaskForge branch workflow

Read this reference completely only when the user explicitly activates the Epic
TaskForge Branch Workflow. Also read the root-routed branching, execution, and
evidence references before acting.

## Contents

- Activation and authority
- Bootstrap
- Serial child loop
- Runtime freshness
- Epic validation and review
- Final epic merge

## Activation and authority

This workflow completes an epic through a rolling
`taskforge/epic-<number>` integration branch. It applies to any work type but is
never inferred from ticket type.

Activate only when the user explicitly asks to execute the whole epic as one
goal or requests its TaskForge epic branch. Do not activate for planning an
epic, working one child, or merely noticing several ready children. Those use
ordinary task execution and stop at `review`.

Explicit activation grants standing approval only for clean child-task merges
into the matching epic integration branch during this run. It does not approve:

- an epic or child merge into the registered primary branch;
- conflict resolution or rebasing;
- force-pushing;
- destructive cleanup or remote branch deletion;
- continuing after the user changes the epic, target, or instruction.

Always preflight a standing-approved merge and send JSON booleans for `apply`
and `approved`.

## Bootstrap

1. Resolve the workspace, epic, registered `masterBranch`, working directory,
   project context, active plan, children, and blockers.
2. If the epic is blocked, apply the root Blocked-ticket decision. Stop if the
   epic is archived, finalized, or has an unresolved blocker.
3. Confirm a clean repository and no active Git operation.
4. Synchronize the registered primary branch under the branching reference.
   Stop on divergence.
5. Create or select lowercase `taskforge/epic-<number>` from synchronized
   primary. Never create it from a child, stale feature branch, or another epic.
6. Call `get_task_execution_packet` for the epic. Treat its goal, acceptance
   criteria, `agentExecution`, blockers, initiative context, validation, and
   safety as the integration contract. Creating the empty epic branch is the
   sole exception to packet-before-branch ordering; no status or implementation
   change may precede packet intake.
7. Build child order from blockers and the active plan. Use
   `get_next_planned_task` when a plan exists. Do not use ticket number order.
8. Resolve archived or skipped children and record why they are outside scope.
9. Move the epic to `in_progress` only after branch, packet, order, prerequisites,
   and blockers are valid. Do not create a synthetic `taskforge/task/EPIC-*`.

For a pre-cutover epic, use its authoritative `release/epic-<number>` branch
under the legacy rules instead of creating a parallel TaskForge branch.

## Serial child loop

Work exactly one child at a time so each task starts from the complete validated
integration result of its predecessor.

For every child:

1. Return to the matching epic branch. Confirm it is clean and contains all
   earlier child merges.
2. Read the child execution packet and reconcile it with the epic packet. When
   the child is blocked, apply the root Blocked-ticket decision. Stop on an
   unresolved block, unfinished blockers, contradictory scope, missing
   prerequisites, or project/branch mismatch.
3. From the epic branch, call `prepare_task_branch` with workspace and
   `apply: true`.
4. Confirm returned and persisted context records the child as `taskBranch` and
   the matching epic integration branch as `baseBranch`. A mismatch means the
   runtime is stale or incompatible; do not patch context manually.
5. Move the child to `in_progress` only after that confirmation. Implement only
   its scope on the child branch.
6. Evaluate the root Codex host guard before selecting a child execution lane.
   On Codex CLI or Codex Desktop, apply the attended routing reference and its
   fail-closed role preflight. On Claude, another non-Codex harness, or an
   unknown harness, continue through the ordinary TaskForge workflow without
   Terra/Sol dispatch or attended `codex-*` evidence.
7. Commit under the repository convention and append the full commit reference.
8. Run the complete child gate:
   - every required `validationPlan` item or an explicit `skipped` result;
   - stack-required tests, typecheck, lint, build, doctors, and review;
   - exact-revision fresh Sol review only when the host guard selected attended
     Codex routing; otherwise use the repository's ordinary review checks;
   - practical API, browser, or local smoke coverage when possible;
   - safe screenshots for UI work;
   - Node inspector breakpoint and evaluation evidence for backend runtime
     changes when applicable, or explicit `skipped` evidence with reason.
9. Do not merge with incomplete, failing, stale, or ambiguous evidence. Fix
   within scope, block for a real external blocker, or stop for human direction.
10. Move complete work `in_progress -> review`.
11. Call `merge_task_branch` with `apply: false` and the exact epic integration
    branch as `targetBranch`.
12. Stop on conflict, blocked result, or source/target/context disagreement.
13. After clean preflight, call the same merge with `apply: true` and
    `approved: true`. Do not request separate child approval.
14. Confirm the child commit is on the epic branch and persisted merge evidence
    is correct. Only then move `review -> done`.
15. Delete the local child branch only when Git proves it merged; use
    `git branch -d`, never `-D`, and never delete a remote branch without explicit
    approval.
16. Refresh plan, statuses, and blockers; select the next eligible child and
    repeat from the updated epic branch.

Do not create all child branches during bootstrap. Lazy creation keeps every
base current.

## Runtime freshness

After changing MCP source, schemas, or workflow behavior, build the MCP server
and reconnect every client that will validate it. A long-running client may keep
old descriptions, schemas, and handlers after a successful build.

Use `get_session_health` to confirm the intended authenticated runtime and
project. If a live tool behaves like an older version, validate the new build
independently and reconnect before diagnosing release code.

For Epic closeout changes in TaskForge, run the built protocol smoke after the
MCP build:

```bash
pnpm exec tsx mcp-server/src/smoke/epic-release-closeout.ts
```

## Epic validation and review

After every child is `done`, `finalized`, or intentionally archived:

1. Run the epic-level plan on the integrated epic branch, including cross-task
   checks, smoke coverage, and backend debugger evidence when applicable.
2. Record integration Validation on the epic with commands, branch, target,
   relevant SHAs, and archived or superseded children.
3. Move the epic to `review`.
4. Leave the epic branch unmerged.
5. Summarize completed and intentionally skipped work plus manual test steps.
6. Ask once for explicit approval of the exact epic-to-primary merge.

Original workflow activation is not approval for the final primary merge.

## Final epic merge

After explicit approval for the exact epic and registered primary branch:

1. Synchronize primary under the branching reference.
2. Call `merge_task_branch` for `EPIC-<number>` with workspace, exact registered
   primary `targetBranch`, `apply: false`, and `projectPath` when needed.
3. Require the source to be the canonical `taskforge/epic-<number>` or applicable
   authoritative legacy branch. A synthetic `taskforge/task/EPIC-*` source or
   another epic target is a contract failure.
4. Accept `action: "already_merged"` only when local Git proves the integration
   source is an ancestor of primary.
5. After clean preflight, call the same tool with `apply: true` and
   `approved: true`.
6. Confirm the returned merge SHA equals primary `HEAD` and persisted context
   records the correct source and target.
7. Stop on source, target, ancestry, SHA, or context disagreement. Do not repair
   it with a synthetic branch or silent manual merge.
8. Confirm every non-archived child is `done` or `finalized` and each archived
   child is intentionally outside scope.
9. Confirm epic Validation contains merge and release evidence.
10. Move the epic `review -> done` only when explicitly requested.

If TaskForge rejects completion despite proven merge evidence, treat it as a
branch-gate mismatch. Keep the epic in review, record the evidence, report the
exact mismatch, and do not retry in a loop.

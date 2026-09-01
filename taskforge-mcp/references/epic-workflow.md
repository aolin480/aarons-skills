# Epic TaskForge branch workflow

Read this reference only when the user explicitly activates the Epic TaskForge
Branch Workflow. Also read the root-routed lifecycle, branching, execution, and
evidence references; they own shared status, proof, merge, approval, sync,
cleanup, and evidence rules.

## Activation

This workflow completes an epic through a rolling
`taskforge/epic-<number>` integration branch. It applies to any work type but
is never inferred from ticket type, planning, a single child, or several ready
children. Those cases use ordinary task execution and stop at `review`.

Activation grants standing approval only for clean child merges into the
matching epic branch during this run. The branching reference lists all actions
that still need human approval. Always preflight a standing-approved merge and
send JSON booleans for `apply` and `approved`.
The standing approval ends if the user changes the epic, target, or instruction.

## Bootstrap

1. Resolve the workspace, epic, registered primary, working directory, project
   context, plan, children, and blockers.
2. Apply the lifecycle blocked-ticket decision. Stop for an archived or
   finalized epic or unresolved blocker.
3. Pass the branching clean-repository and primary-synchronization gates.
4. Create or select lowercase `taskforge/epic-<number>` from synchronized
   primary. Never start it from a child, stale feature, or another epic.
5. Read the epic execution packet. Its goal, acceptance criteria,
   `agentExecution`, blockers, initiative context, Validation, and safety are
   the integration contract. Creating the empty epic branch is the only
   packet-before-branch exception; no status or implementation change may come
   first.
6. Order children from blockers and the active plan. Use
   `get_next_planned_task` when a plan exists; never use ticket-number order.
7. Resolve archived or skipped children and record why they are out of scope.
8. Move the epic to `in_progress` only after branch, packet, order,
   prerequisites, and blockers are valid. Never create
   `taskforge/task/EPIC-*`.

Use an authoritative `release/epic-<number>` branch for a legacy epic instead
of creating a parallel TaskForge branch.

## Serial child loop

Work one child at a time so each starts from the complete validated result of
its predecessor.

1. Return to the clean matching epic branch and confirm all earlier child
   merges are present.
2. Read and reconcile the child and epic packets. Apply the lifecycle blocked
   decision. Stop for unfinished blockers, contradictory scope, missing
   prerequisites, or project/branch mismatch.
3. From the epic branch, call `prepare_task_branch` with workspace and
   `apply: true`.
4. Confirm returned and persisted context names the child branch and matching
   epic base. Do not patch a mismatch manually.
5. Move the child to `in_progress`, then implement only its scope. When the
   packet reports Gherkin, run the familiarization checkpoint after source
   orientation and before substantive implementation.
6. Apply root orchestration opt-in before selecting a lane. Only an opted-in,
   host-guarded Codex route uses attended dispatch and `codex-*` evidence.
7. Commit under repository rules and append the full commit reference.
8. Complete all required `validationPlan` items or record explicit
   `skipped` results. Add stack-required tests, typecheck, lint, build,
   doctors, review, practical smoke evidence, safe UI screenshots, and backend
   debugger evidence when applicable. Use exact-revision Sol review only for
   the selected attended route; otherwise use ordinary repository review.
9. Do not merge incomplete, failing, stale, or ambiguous evidence. Repair
   in-scope failures, block on a real external condition, or stop for human
   direction.
10. Move the child `in_progress -> review`.
11. If Gherkin exists, run its unchanged-candidate acceptance checkpoint.
12. Preflight `merge_task_branch` into the exact epic branch with
    `apply: false`; stop on conflict, blocked outcome, or source, target, or
    context mismatch.
13. Apply the clean merge with `apply: true` and `approved: true` under the
    standing approval.
14. Apply the lifecycle completion-proof gate, then move
    `review -> done`. The branching reference owns normal and validation-only
    no-change proof.
15. Apply safe local cleanup, refresh plans, statuses, and blockers, then select
    the next eligible child from the updated epic branch.

Create child branches lazily. Creating all branches at bootstrap gives them
stale bases.

## Runtime freshness

After changing MCP source, schemas, or workflow behavior, build the server and
reconnect every validating client. A long-running client can retain old
descriptions, schemas, and handlers.

Use `get_session_health` to confirm the intended authenticated runtime and
project. If a live tool appears stale, validate the new build independently and
reconnect before diagnosing release code.

For TaskForge epic-closeout changes, run after the MCP build:

```bash
pnpm exec tsx mcp-server/src/smoke/epic-release-closeout.ts
```

## Epic review

After every child is done, finalized, or intentionally archived:

1. Run the epic plan on the integrated branch, including cross-task checks,
   smoke, backend debugger evidence when applicable, and the epic Gherkin
   checkpoint when nonblank. Reuse a passing checkpoint only while the source
   commit and spec are unchanged.
2. Record epic Validation with commands, branch, target, relevant SHAs, and
   archived or superseded children.
3. Move the epic to `review`, leave its branch unmerged, summarize completed
   and skipped work plus manual tests, and ask once for exact epic-to-primary
   approval.

Workflow activation is not final-primary approval.

## Final epic merge

After explicit approval:

1. Synchronize primary under the branching reference.
2. Preflight `merge_task_branch` for `EPIC-<number>` into the exact registered
   primary with `apply: false`, passing workspace and `projectPath` when needed.
3. Require the canonical `taskforge/epic-<number>` or authoritative legacy
   source. A synthetic task branch or another epic target is invalid.
4. Accept `action: "already_merged"` only when local Git proves the source is
   an ancestor of primary.
5. Apply the clean result with `apply: true` and `approved: true`.
6. For a new merge, require the returned and persisted 40-character SHA to
   equal primary `HEAD`. For `already_merged`, require the returned and
   persisted SHA to identify the verified source integration commit on
   primary's first-parent path; primary may have advanced.
7. Stop on any source, target, ancestry, SHA, or context disagreement. Never
   repair it with a synthetic branch or silent manual merge.
8. Confirm every non-archived child is done or finalized and archived children
   are intentionally outside scope. Confirm epic Validation contains merge and
   release evidence.
9. Move `review -> done` only when explicitly requested.

If completion is rejected despite proven merge evidence, keep the epic in
`review`, record the branch-gate mismatch, and do not retry in a loop.

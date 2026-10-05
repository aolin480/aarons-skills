# Attended Codex routing

Read this reference only after root orchestration opt-in and the Codex host
guard select the attended route. It extends the root workflow; it does not
create a TaskForge spawn runtime.

## Lane ownership

The active parent owns planning, decisions, TaskForge writes, acceptance, and
corrections. The attended route overrides the root planning default: planning,
research, investigation, and architecture remain with an active Sol/high
parent. TaskForge cannot inspect or enforce that runtime setting.

| Work | Lane | Requested role pin |
| --- | --- | --- |
| Planning, research, investigation, architecture | Active Sol/high parent | Parent setting is not runtime-attested |
| Settled bounded implementation | `taskforge_terra_implementer` | Terra/high |
| Fresh review after a writing lane | `taskforge_sol_reviewer` | Sol/high; requested read-only |

Use Terra only after the parent settles architecture, paths, interfaces,
constraints, and checks. Do not route planning, research, investigation, or
architecture to a worker. Do not add provider or model catalogs, scores, token
or cost accounting, budgets, schedulers, leases, retries, load balancing,
dashboards, automatic routing, or an MCP spawn tool.

## Host eligibility

Apply this route only when first-party runtime identity or native harness
capabilities confirm Codex CLI or Codex Desktop. The parent owns this local
decision; TaskForge does not attest the harness.

Do not infer the host from actor or source data, credentials, environment
branding, or role files. Known non-Codex and unknown hosts return to the
ordinary workflow without attended dispatch or review evidence. A confirmed
Codex host fails closed when a required role is missing or invalid.

## Role and evidence preflight

Before each worker or reviewer spawn, the parent must:

1. Confirm both roles are registered in `.codex/config.toml` and their files
   parse.
2. Confirm the Terra role uses the repository-approved Terra family at
   `high`.
3. Confirm the Sol role uses the repository-approved Sol family at `high` and
   `sandbox_mode = "read-only"`.
4. Confirm `taskforge-local` is available. Do not substitute another server
   or similarly named role.
5. Read the task execution packet first. Read a parent epic packet only when
   the task packet references one for an ordinary child task.
6. Apply the root blocked-ticket decision. Stop for unresolved blockers;
   missing goal, path boundary, or validation plan; or missing or inconsistent
   project or branch context. Do not fail because a parent epic or another
   optional value is absent when it is not applicable.
7. Capture the immutable Git integration base rather than current `HEAD` by
   convenience.
8. Append one `codex-dispatch-intent` Validation before spawning. Its summary
   or details may contain only:

```json
{
  "server": "taskforge-local",
  "workspace": "<workspace>",
  "ticket": "<ticket>",
  "roleHint": "<selected-registered-role>",
  "requestedModel": "<selected-role-model>",
  "requestedEffort": "high",
  "baseRevision": "<full-git-sha>",
  "runtimeAttested": false
}
```

If any role, packet field, or revision is unverified, fail closed. Do not
substitute another role, model, effort, or server. Record the blocker through
the normal TaskForge process.

## Worker contract

Give the worker only the ticket, workspace, owned paths, exact base revision,
settled interfaces and constraints, and required checks.

The worker self-hydrates from `taskforge-local` with the task execution packet
and every available section. It reads the parent epic packet only when the task
packet references one for an ordinary child task.
Before editing, it verifies identity, blockers, goal, allowed and forbidden
paths, validation, project and branch context, and required skills. Missing or
contradictory evidence fails closed.

The worker returns exact base and head SHAs, changed files, commands and actual
results, assumptions, and residual risks. The parent inspects the complete diff
and records results through ordinary Validation and Notes. Configured model or
effort is not runtime evidence.

## Reviewer contract

Every writing lane requires a fresh `taskforge_sol_reviewer` after parent
verification. Give it the ticket, workspace, exact base/head range, allowed
paths, interfaces, constraints, and actual Validation.

The reviewer independently hydrates the task packet and, only when it references
one for an ordinary child task, the parent epic packet. The reviewer remains
behaviorally read-only and returns evidence with exactly one registered verdict.
The registered reviewer verdicts are `ship`, `fix-first`, and `rethink`:

- `ship`: the reviewed revision is ready.
- `fix-first`: bounded corrections are required before acceptance.
- `rethink`: the contract or approach needs a parent decision.

`sandbox_mode = "read-only"` is requested configuration. Report observed
sandbox or permission values only when the runtime exposes them; otherwise
state that runtime attestation is unavailable.

## Correction invalidation

Any correction invalidates affected worker results, Validation, and verdicts.
Record the new revision, rerun invalidated checks, obtain a fresh Sol review of
the new exact range, and never carry a verdict across a changed head.

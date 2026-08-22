# Attended Codex routing

Read this reference completely only after the root Codex host guard selects the
attended route. This policy extends the root Reasoning Preflight and the existing
TaskForge workflow; it does not create a TaskForge spawn runtime.

## Contents

- Lane ownership
- Host eligibility boundary
- Role and evidence preflight
- Worker contract
- Reviewer contract
- Correction invalidation

## Lane ownership

The active parent owns planning, decisions, TaskForge writes, acceptance, and
corrections. Advise a Sol/high parent before epic work, but do not claim
TaskForge can inspect, select, or enforce the parent's model or effort.

| Work | Lane | Requested role pin |
| --- | --- | --- |
| Planning, research, investigation, or architecture | Active Sol/high parent | Parent setting is not runtime-attested |
| Settled bounded implementation | `taskforge_terra_implementer` | Terra/high |
| Review of a completed writing lane | Fresh `taskforge_sol_reviewer` | Sol/high; requested read-only |

Do not route planning, research, investigation, or architecture to a worker.
Use Terra only after the parent settles architecture, exact paths, interfaces,
constraints, and checks.

Do not add provider or model catalogs, scores, token or cost accounting,
budgets, schedulers, leases, retries, load balancing, dashboards, automatic
routing, or an MCP spawn tool.

## Host eligibility boundary

This reference applies only when first-party runtime identity or native harness
capabilities confirm Codex CLI or Codex Desktop. The active parent owns this
local decision; TaskForge and its MCP server do not attest the current harness.

Do not use TaskForge actor or agent names, `source.createdBy`, `sourceAgent`,
ticket provenance, credentials, environment branding, or role-file presence as
harness evidence. Claude, other known non-Codex harnesses, and unknown harnesses
return to the ordinary TaskForge workflow without attended dispatch or review
evidence.

After a Codex CLI or Codex Desktop host is confirmed, apply the role preflight
below and fail closed on a missing or invalid role. Do not silently fall back to
ordinary execution for a verified Codex configuration defect.

## Role and evidence preflight

Before every worker or reviewer spawn, the parent must:

1. Confirm both roles are registered in `.codex/config.toml` and their files
   parse.
2. Confirm Terra requests `gpt-5.6-terra` with `high` effort.
3. Confirm Sol requests `gpt-5.6-sol` with `high` effort and
   `sandbox_mode = "read-only"`.
4. Confirm `taskforge-local` is available. Do not substitute another TaskForge
   server or a similarly named built-in role.
5. Read the target execution packet and its parent epic packet for an ordinary
   child task.
6. When a ticket is blocked, have the active parent apply the root
   Blocked-ticket decision before dispatch. Stop on an unresolved blocker,
   missing goal, missing path boundary, missing validation plan, or inconsistent
   project or branch context.
7. Capture the immutable Git base. Use the actual integration base for a task
   branch, not current `HEAD` by convenience.
8. Append one `codex-dispatch-intent` Validation before spawning. Its summary or
   details may contain only:

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

If any role, packet field, or revision cannot be verified, fail closed. Do not
substitute another role, model, effort, or server. Record the blocker through
the normal TaskForge process.

## Worker contract

Give the worker only:

- ticket and workspace;
- exact owned paths;
- exact base revision;
- settled interfaces and constraints;
- required checks.

The worker must self-hydrate from `taskforge-local` with
`get_task_execution_packet` and all available sections. It verifies identity,
blockers, goal, allowed and forbidden paths, validation plan, project and branch
context, and required skills before editing. When the packet names a parent
epic, the worker hydrates it too. Missing or contradictory evidence is
fail-closed.

The worker returns:

- exact base and head SHAs;
- changed-file scope;
- commands and actual results;
- assumptions;
- residual risks.

The parent inspects the complete diff and records the result through normal
Validation and Notes. Configured model or effort is not runtime evidence.

## Reviewer contract

Every writing lane requires a fresh `taskforge_sol_reviewer` after parent
verification. Give it the ticket, workspace, exact base/head range, allowed
paths, interfaces, constraints, and actual Validation.

The reviewer independently hydrates the task and parent epic packets, remains
behaviorally read-only, and returns one concise `SHIP` or `FIX-FIRST` verdict
with evidence.

`sandbox_mode = "read-only"` is requested configuration. Report observed
sandbox or permission values only when the runtime exposes them. Otherwise say
runtime attestation is unavailable.

## Correction invalidation

Any correction after a worker result or reviewer verdict invalidates every
affected result, Validation, and verdict.

1. Record the correction against the new exact Git revision.
2. Rerun invalidated checks.
3. Obtain a fresh Sol review of the new exact base/head range.
4. Never carry a verdict across a changed head revision.

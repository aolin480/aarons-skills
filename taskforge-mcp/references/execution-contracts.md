# Execution contracts

Read this reference completely before performing a ticket, writing a durable
goal, or creating or updating `agentExecution`.

## Contents

- Execution packet intake
- Durable goal
- Structured agent execution contract
- Reasoning guidance
- Agent-tab editor format
- Update examples

## Execution packet intake

Call `get_task_execution_packet` before implementation. It is the canonical
execution intake; do not rebuild the contract from scattered reads.

Verify, at minimum:

1. Canonical ticket identity, workspace, status, and ticket type.
2. Parent epic and initiative context when present.
3. Unfinished blockers and blocked state.
4. `goal` or `agentGoal`.
5. Included and excluded scope.
6. Allowed and do-not-touch paths.
7. Assumptions and their verification hints.
8. References and runtime prerequisites.
9. Required validation and recommended skills.
10. Safety, privacy, review focus, project context, and branch context.

For an ordinary task, also read the parent epic packet when it exists. For an
initiative-linked epic or task, also read the initiative packet as required by
the root routing table.

When the ticket is blocked, apply the root Blocked-ticket decision before
implementation. Stop when that decision finds an unresolved blocker, a required
goal or boundary is missing, a required prerequisite cannot be met, or the
project and branch context conflict with the checkout. Do not silently narrow,
ignore, or invent missing contract fields.

Re-read the packet before a status completion or merge when implementation,
review, blockers, branch state, or ledger state may have changed.

## Durable goal

The goal must stand alone without chat history. Include:

- the concrete outcome;
- included scope and explicit exclusions;
- important prerequisite assumptions;
- validation expectations;
- evidence that must be recorded;
- safety or privacy limits when relevant.

Keep it to one focused paragraph when possible. Use acceptance criteria for
checklist details and Notes for the implementation journal.

Weak:

```text
Add presence support and tests.
```

Better:

```text
Implement only the contract and read-model foundation for shopper chat
presence. Update the shared contracts and management read shape so reads can
optionally return a safe presence summary. Keep runtime derivation, UI rendering,
and send policy out of this ticket. Add focused contract and read-model tests and
record sanitized validation evidence in TaskForge.
```

Use `update_task` to write or clear a goal:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {"goal":"Complete the API retry migration and verify it with unit and smoke tests."}
}
```

Send `"goal": null` to clear it. Do not store goal history in Notes.

If the agent runtime supports an explicit goal feature, mirror the TaskForge
goal before long-running work. The TaskForge goal remains the durable source.

## Structured agent execution contract

`agentExecution` complements `goal`, description, and acceptance criteria. Use
it when a task needs durable machine-readable boundaries or checks. Do not add
it merely to repeat other fields. Legacy tickets without it remain valid and
must not acquire empty contract objects during unrelated updates.

Supported v1 shape:

```json
{
  "outcome": "Optional concise result statement.",
  "scope": {
    "included": ["Work that belongs in this ticket."],
    "excluded": ["Work that belongs elsewhere."]
  },
  "paths": {
    "allowed": ["relative/or/absolute/path"],
    "doNotTouch": ["path-or-service-to-avoid"]
  },
  "assumptions": [
    {
      "statement": "Assumption to verify.",
      "verificationHint": "Optional proof path."
    }
  ],
  "references": [
    {
      "kind": "file",
      "label": "Readable label",
      "value": "path-or-url-or-ticket",
      "note": "Optional note"
    }
  ],
  "runtimePrerequisites": [
    {
      "name": "Local API server",
      "details": "Optional setup detail.",
      "required": true
    }
  ],
  "validationPlan": [
    {
      "kind": "test",
      "command": "pnpm nx test api",
      "target": "api",
      "expectedEvidence": "Relevant specs pass.",
      "required": true
    }
  ],
  "recommendedSkills": [
    {
      "skill": "nestjs-doctor",
      "useWhen": "After changing NestJS files.",
      "priority": "recommended"
    }
  ],
  "safety": {
    "constraints": ["Do not expose secrets."],
    "privacy": ["Use sanitized examples."]
  },
  "reviewFocus": ["Contracts", "Backward compatibility"]
}
```

Field meanings:

- `outcome`: concise successful result.
- `scope.included`: work owned by this ticket.
- `scope.excluded`: non-goals or work owned elsewhere.
- `paths.allowed`: likely inspect or edit paths and commands.
- `paths.doNotTouch`: forbidden paths, services, generated output, or data.
- `assumptions`: claims to verify before editing.
- `references`: durable files, docs, tickets, URLs, commands, or artifacts.
- `runtimePrerequisites`: required local or remote setup.
- `validationPlan`: checks to run or explicitly skip with a reason.
- `recommendedSkills`: skills that materially improve execution.
- `safety`: destructive, branch, data, tenant, secret, auth, and privacy limits.
- `reviewFocus`: areas the reviewer must inspect.

Allowed reference kinds: `file`, `doc`, `ticket`, `url`, `command`, `artifact`,
and `other`.

Allowed validation kinds: `test`, `lint`, `build`, `doctor`, `browser`,
`debugger`, `review`, and `manual`.

Allowed skill priorities: `required`, `recommended`, and `optional`.

Use `required` when the task cannot be considered validated without the named
skill or equivalent explicit check. Use `recommended` when it materially helps
but does not block. Use `optional` for useful extras.

Most text entries are capped at 1000 characters. Human-facing labels such as a
reference `label`, prerequisite `name`, and recommended skill `skill` are capped
at 140 characters. Put detailed run evidence in Validation, Notes, or
attachments.

When skill discovery is requested or the suitable skill is unknown, use
`$find-skills`. Do not invent decorative skills.

Never store API keys, bearer tokens, passwords, cookies, raw browser or session
data, raw provider payloads, broad PII, raw prompt text, or unrelated browser
state in `agentExecution`.

## Reasoning guidance

`agentExecution.reasoning` may override the root Reasoning Preflight for that
task only. Treat it as dispatch advice, not runtime enforcement. Preserve
`requiresRedispatch`, `redispatchReason`, `returnLevel`, and `returnConditions`
when supported. Never claim TaskForge changed the current model or effort.

## Agent-tab editor format

The web Agent tab edits the same API fields. Lists use one item per line.

```text
Assumptions:
statement | verificationHint

References:
kind | label | value | note

Runtime prerequisites:
required | name | details
optional | name | details

Validation plan:
kind | command | target | expectedEvidence | required
kind | command | target | expectedEvidence | optional

Recommended skills:
priority | skill | useWhen
```

Simple labels map as follows:

```text
Outcome -> outcome
Scope -> scope.included
Non-goals -> scope.excluded
Allowed paths -> paths.allowed
Do not touch -> paths.doNotTouch
Safety constraints -> safety.constraints
Privacy -> safety.privacy
Review focus -> reviewFocus
```

Trailing columns may be omitted, but generated content should use explicit
columns so UI round-tripping stays predictable.

## Update examples

Write or replace the contract with `update_task`:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "agentExecution": {
      "outcome": "API retry behavior is covered by focused tests.",
      "validationPlan": [
        {
          "kind": "test",
          "command": "pnpm nx test api",
          "target": "api",
          "expectedEvidence": "Retry specs pass.",
          "required": true
        }
      ]
    }
  }
}
```

Send `"agentExecution": null` to clear it. Omit the field to leave a legacy
task unchanged.

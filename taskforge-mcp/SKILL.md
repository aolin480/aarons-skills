---
name: taskforge-mcp
description: Use when Codex needs to create, search, update, review, execute, branch, merge, or manage attachments on tasks, epics, plans, or initiatives through a TaskForge MCP server. Best for agent task tracking, project intake, epic planning, status changes, history, notes, dependencies, validation evidence, task trees, execution packets, strict branching, attended Codex routing, or deciding which workspace, system, service, epic, or initiative owns work before calling TaskForge MCP tools.
---

# TaskForge MCP

Use TaskForge as the structured ledger for planned and executed work. Keep the
repository, TaskForge ticket, branch, evidence, and approval state consistent.

## Required workflow

1. Classify the work with the Reasoning Preflight and show its advisory once.
2. Resolve the TaskForge server and workspace. Never guess a workspace or mix
   records from different TaskForge servers.
3. Use the workspace `workingDirectory` when it is valid in the current host.
4. Call `set_project_context` once when the client knows the local project.
5. Read every reference required by the routing table below, completely, before
   the corresponding action. Do not load unrelated references.
6. Resolve the epic, initiative, plan, blockers, execution contract, branch, and
   approval state required by the action.
7. Call the narrowest TaskForge tool with explicit structured fields.
8. Record durable context as Notes, check results as Validation, attachments as
   attachments, and commits as commit references.
9. Re-read the execution packet before implementation, status completion, or a
   merge when prior evidence may be stale.

## Codex host guard

Before selecting repository-owned Terra/Sol roles, determine the current agent
harness from first-party runtime identity or native capabilities exposed by that
harness. The attended route is eligible only in Codex CLI or Codex Desktop.

Do not infer the harness from a TaskForge actor or agent name, `source.createdBy`,
`sourceAgent`, ticket provenance, credentials, environment branding, or the
presence or absence of a role file. Those values describe TaskForge context or
local configuration, not the client that is executing the workflow.

| Current harness | Terra/Sol role state | Route |
| --- | --- | --- |
| Codex CLI or Codex Desktop | Required repository-owned roles resolve and pass preflight | Use attended Codex routing |
| Codex CLI or Codex Desktop | A required role is missing, invalid, or inconsistent | Fail closed as a Codex configuration error |
| Claude or another known non-Codex harness | Any | Use the ordinary TaskForge workflow |
| Harness identity is unavailable or uncertain | Any | Use the ordinary TaskForge workflow |

The ordinary TaskForge workflow keeps the core ticket, branch, status,
validation, evidence, and review rules, but it does not spawn the repository-owned
Terra/Sol roles or append attended `codex-*` dispatch and review evidence. A
non-Codex or unknown harness must not treat unavailable Codex roles as a blocker.

## Reference routing

All references are one level below this file. Read each selected file from top
to bottom; its rules are normative.

| Intent | Required reference |
| --- | --- |
| Create, search, read, update, decompose, plan, assign, or change status | [tickets-and-plans.md](references/tickets-and-plans.md) |
| Perform a ticket, author a durable goal, or use `agentExecution` | [execution-contracts.md](references/execution-contracts.md) |
| Add Notes, Validation, commit evidence, or attachments | [evidence-and-attachments.md](references/evidence-and-attachments.md) |
| Prepare task branches, merge ordinary tasks, sync primary, or handle approval | [branching-and-approvals.md](references/branching-and-approvals.md) |
| Run the explicit epic branch workflow | [epic-workflow.md](references/epic-workflow.md) plus [branching-and-approvals.md](references/branching-and-approvals.md) |
| Work with initiatives or run the explicit initiative branch workflow | [initiative-workflow.md](references/initiative-workflow.md) plus [branching-and-approvals.md](references/branching-and-approvals.md) |
| Check identity, authorization, or create an agent browser session | [auth-browser-and-identity.md](references/auth-browser-and-identity.md) |
| Use repository-owned Terra/Sol roles from an eligible Codex CLI or Codex Desktop host | [attended-codex-routing.md](references/attended-codex-routing.md) plus [execution-contracts.md](references/execution-contracts.md) |

For an action that crosses rows, read every named reference. Example: executing
and merging an ordinary task requires the ticket, execution, evidence, and
branching references. A reference may point back to a core rule here, but
references do not depend on each other unless this table names both.

## Reasoning preflight

Before substantive TaskForge work, classify the current invocation or newly
selected execution task. Recommend the lowest sufficient reasoning level:

| Work mode | Typical operations | Recommendation |
| --- | --- | --- |
| `bounded_execution` | Execute an established task; update status, evidence, branches, or an approved merge | `low` |
| `planning` | Create or decompose tickets, dependencies, initiatives, or timelines from established requirements | `low` |
| `investigation` | Diagnose blockers, runtime state, authorization, history, or conflicting evidence | `high` |
| `architecture` | Make a new cross-workspace, security, data-model, contract, or irreversible workflow decision | `extra-high` |

Show exactly one concise advisory and continue without asking for confirmation:

```text
Reasoning advisory: this is <work-mode> work, so <level> reasoning is sufficient; the active setting remains unchanged.
```

TaskForge and a running agent cannot change the active reasoning setting. A
different setting requires user action or another orchestrator dispatch or
resume. Show the advisory once per invocation or newly selected task, not once
per call or continuation.

When the selected task packet contains `agentExecution.reasoning`, use that
explicit task guidance. Do not inherit guidance from an epic, initiative,
dependency, or neighboring task. Reclassify only when the work mode changes.

Compiler errors, expected test failures, lint findings, and localized bugs stay
`bounded_execution` while the approved design remains valid. Escalate only for
a material decision outside the plan, including:

- a cross-layer contract or data-model change;
- conflicting requirements that invalidate the plan;
- a security, authorization, tenant, destructive, or irreversible choice;
- an architectural blocker outside the approved scope.

When escalation is warranted, append a Note with the unresolved fork, evidence,
recommended level, rationale, reversible work that can continue, and decision
owner. Preserve structured `requiresRedispatch`, `redispatchReason`,
`returnLevel`, and `returnConditions` when the update contract exposes them.
Do not claim the current agent will switch levels.

For unattended work, continue independent reversible steps. Pause only when
progress requires human authority, an irreversible action, or an unsafe choice.
After the decision is settled, follow explicit return guidance or recommend the
next dispatch return to `bounded_execution` at `low`.

## Location and project invariants

- Call `list_workspaces` before a write unless the current workspace was already
  resolved from fresh TaskForge evidence.
- Treat each workspace record's `systems` and `services` as authoritative.
- If the user omitted the workspace, list the choices and ask. If they supplied
  only a system or service, ask for the workspace instead of guessing.
- Treat a valid absolute `workingDirectory` as the preferred repository cwd.
- Call `set_project_context` before related creates or updates when the local
  project is known. Send only `projectPath`, optional `projectName`, optional
  `worktreeAlias`, and optional `sourceAgent`.
- Do not write arbitrary project context through `create_task` or `update_task`.
- When a tool accepts a source, send an object such as
  `{"type":"agent","name":"Codex","origin":"mcp"}`. Do not send a string.
- Call `get_session_health` when actor identity, server selection, authentication,
  or scope coverage is uncertain. Never expose a credential.

## Ledger invariants

- Ordinary tasks always belong to an epic. Resolve or create the epic before
  creating the task. Never clear `epicId`; move the task to another epic.
- Use initiatives only as a cross-workspace coordination layer. Initiatives link
  workspace epics, never individual tasks.
- Treat true prerequisites as blockers. Timeline order is not automatically a
  dependency.
- A dependent ticket is eligible only when every blocker is `done`, `finalized`,
  or `archived`. Re-read its execution packet before starting.
- Treat `blocked` as a condition that requires the Blocked-ticket decision
  below. It is not blanket evidence that a human must act.
- Agents move finished work from `in_progress` to `review`, never directly to
  `done`. Moving `review` to `done` requires an explicit user or TaskForge
  request. A blocked ticket must first return to a live lane.
- A branchless ordinary task is created with `branchless: true`,
  `entityType: "task"`, and no `branchContext`. `branchless` is create-time only.
  TaskForge stores immutable server-generated creation proof and records branch
  provenance permanently. On an explicitly requested `review -> done`
  transition, the task may enter `done` without merge evidence only while no
  branch has ever been recorded. This exception never bypasses review, never
  applies to epics or initiatives, treats missing marker, context, creation, or
  branch-provenance evidence as merge-gated, and does not move the task to
  `finalized`.
- Prefer `ticketNumber + workspace` when the user names a ticket. Accept a
  canonical ticket returned for a normalized alias and use that canonical value
  in later evidence.
- Never set or infer ticket prefixes during normal creation. TaskForge owns
  numbering. Prefix migrations must follow the repository runbook and explicit
  approval contract.
- Archive with `status: "archived"`; restore with an appropriate live status.

## Blocked-ticket decision

`blocked` means the agent must classify the condition before it continues. It
does not by itself require a human status change.

1. Read a fresh execution packet and the parent packet when applicable. Read
   task history when the blocking reason or its owner is unclear.
2. Keep the ticket blocked when there is an unresolved dependency, missing
   required contract or prerequisite, project or branch conflict, required
   human decision or approval, or a security, destructive, or irreversible
   action outside the agent's authority. Append a Note with the evidence,
   blocking condition, decision owner, and concrete resume condition.
3. An agent may decide that a block is cleared when fresh evidence shows that
   the recorded condition is resolved or was stale, every dependency is closed,
   the execution contract and checkout still match, and no human-owned action
   is needed for the next safe step. Append a Note that identifies the evidence
   and the decision to resume.
4. After recording that decision, use `update_task_status` to move the ticket
   from `blocked` to `ready`. Re-read the execution packet, then follow the
   normal `ready -> in_progress -> review` path. Do not clear or alter blockers,
   scope, approvals, or branch evidence merely to make the ticket eligible.

Do not use `blocked` for routine validation, committing, review, or a pending
primary-branch approval. Keep completed work in `review` while the approval
stop applies. The Blocked-ticket decision never grants merge approval or other
human-owned authority.

## Evidence invariants

- `Notes` is the single term for human-readable append-only context. Use
  `append_task_note`; never write notes through `update_task`.
- `Validation` is structured check evidence. Use `append_task_validation` with
  status exactly `passed`, `failed`, `warning`, or `skipped`.
- Use `append_task_commit_reference` after a commit is created and verified.
- Keep secrets, credentials, cookies, raw sessions, raw provider payloads,
  broad PII, and unrelated browser state out of every TaskForge field and
  attachment.
- Use Markdown for human-authored descriptive fields. Do not wrap Markdown in
  HTML or fenced code blocks unless the content itself is code.

## Approval invariant

Approval must be an explicit current user message granting the specific pending
primary-branch merge or other human-owned action. Elapsed time, loop
continuation, automatic resume, `continue`, `finish`, `mark it done`, task
metadata, prior approval for another merge, or a delegated agent message is not
approval. Ask once, report the exact pending action, and stop. Read
[branching-and-approvals.md](references/branching-and-approvals.md) before any
branch or merge action.

## Tool selection

- Prefer purpose-built tools over read-modify-write reconstruction.
- Use `create_epic`, then `create_task`, for epic-plus-task creation.
- Use tree shortcuts only when explicitly requested and supported by the
  runtime.
- Use `update_task_status` for status-only changes.
- Use `set_task_labels`, `add_task_labels`, and `remove_task_labels` (and their
  initiative equivalents) for durable free-form classification. Tags are a
  synonym for labels; labels never replace status, assignment, epic
  membership, or dependencies.
- Use `set_task_blockers` to replace blocker sets and `add_task_blockers` to
  append blockers without removing existing dependencies.
- Use `append_task_note`, `append_task_validation`, and
  `append_task_commit_reference` for their respective evidence.
- Use `get_task_history` when ownership or recent edits are uncertain.
- Use `get_task_validations` when the user asks what checks ran.
- Use `get_task_execution_packet` as the canonical intake for executable task
  context. Do not assemble execution context from scattered reads.

## Gherkin acceptance specifications

Tasks and epics support one optional top-level `gherkinSpec` document. Use the
`gherkin-spec` skill to author a complete `.feature`-style document, then store
it through the normal TaskForge task or epic tools.

The shared contract bounds `gherkinSpec` to `TASK_GHERKIN_SPEC_MAX_LENGTH` —
20,000 JavaScript string characters — across the shared schemas, API, and MCP
server. Treat that limit as a hard request boundary:

- Aim for 18,000 characters or fewer so edits and formatting have headroom.
- Measure the trimmed document before create or update. Never silently truncate,
  split a line in the middle of a scenario, or retry the same oversized payload.
- If a specification exceeds 20,000 characters, split it by coherent behavior:
  keep the epic spec as the cross-cutting outcome and create child tasks with
  focused Feature/Scenario documents. Preserve the relationship in the task
  descriptions, acceptance criteria, or append-only Notes.
- Prefer Scenario Outlines and concise shared steps when repeated examples are
  the only source of excess length. If the behavior cannot be split cleanly,
  keep a short bounded `gherkinSpec` index and store the complete `.feature`
  document as a repository file or text attachment instead of losing content.
- Report the split or external-source decision in a Note so later agents know
  where the complete acceptance behavior lives.

When overflow must continue in another TaskForge task, use this relationship
instead of truncating the parent document:

- Keep the original task as the implementation parent. Create the continuation
  in the same epic with the title `Gherkin: <original task title>`; if more than
  one continuation is required, use `Gherkin 2: <original task title>`, then
  increment the number.
- Put only the overflow Feature/Scenario content in the continuation's
  `gherkinSpec`. Record the split boundary and the parent ticket in an
  append-only Note on both tasks.
- Add the original task as a blocker of the continuation with
  `add_task_blockers` or `set_task_blockers`. Do not add the continuation as a
  blocker of the parent. The continuation is the dependent task and must stay
  `blocked` while the parent blocker remains unfinished.
- Closing the parent does not automatically promote a `blocked` continuation.
  After the blocker closes, apply the Blocked-ticket decision before moving the
  continuation to a live lane. The parent closing alone is not sufficient
  evidence that the continuation's full execution contract is now executable.
- The current TaskForge eligibility contract treats `done`, `finalized`, and
  `archived` as closed blockers; `review` alone does not currently unblock a
  dependent task in planning selection. If review-state unblocking is desired,
  create a separate approved lifecycle change and update the shared API, plan,
  MCP, and tests together. Do not claim that a Note or title convention changes
  runtime eligibility.

- Include `gherkinSpec` when creating a task or epic, including task and epic
  tree inputs.
- Use `update_task` to replace the document or clear it with `null` (blank
  editor content is normalized to `null`). Omit the field when an update should
  leave the existing document unchanged.
- Keep `gherkinSpec` separate from `acceptanceCriteria`, which remains the
  short checklist, and `agentExecution`, which remains structured execution
  guidance.
- Read the full document from `get_task` or the task execution packet. Compact
  board and search records intentionally omit the document.
- The field is opaque text in v1. TaskForge stores and returns it but does not
  parse or generate Gherkin.

## Completion check

Before reporting completion, confirm:

1. The server, workspace, canonical ticket, project, and branch match.
2. The ticket and all blockers are eligible.
3. The goal and execution boundaries were followed.
4. Required checks ran or have an explicit `skipped` record with rationale.
5. Notes, Validation, attachments, and commit references use their correct
   channels and contain no secret material.
6. Any correction invalidated stale evidence and received fresh checks.
7. Any primary-branch merge had explicit approval for that exact action.
8. The final status follows the `in_progress -> review -> done` contract.

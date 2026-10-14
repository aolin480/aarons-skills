# Authoring tasks and execution contracts

Read this reference before creating or editing tasks, epics, goals, source, or
`agentExecution`.

## Create work

Ordinary tasks are epic-first: resolve or create the epic, then create each
child with its `epicId`. Never clear `epicId`; move a task when ownership
changes. TaskForge owns ticket numbers and prefixes; do not infer one from
`system`.

Before creating several tasks, separate prerequisites from preferred order.
Create the records, add blockers only for prerequisites, then verify the graph.
Use `create_epic_tree` or `create_task_tree` only when the user explicitly
asks and the runtime exposes the shortcut. Explicit calls keep failures and
ownership visible. For Markdown import, inspect the source, resolve the
workspace and epic, then use `convert_markdown_to_tasks`. Preserve hierarchy;
list order alone is not a blocker.

Respect each advertised tool schema when persisting the plan. The current
`create_epic` contract does not accept `acceptanceCriteria`; do not send that
field during epic creation. If integrated epic criteria are required, persist
them with a separately advertised `update_task` after the epic exists. A host
that does not advertise that update capability must report the gap rather than
retrying an invalid create or dropping the criteria.

When create or update accepts `source`, send the live structured origin shape:

```json
{
  "createdBy": "mcp-agent",
  "agentName": "Codex",
  "conversationId": "<conversation-id>"
}
```

`createdBy` is `human`, `codex`, `chatgpt`, or `mcp-agent`. Agent
sources require `agentName` and `conversationId`; the MCP boundary supplies
defaults when they are omitted. `repo` and `branch` are optional but must be
provided together. Source records origin, not authorization or ownership. Do
not put credentials, authentication-session identifiers, raw prompts, or broad
client state in it.

## Durable goal and agent execution

For executable work, write a stand-alone goal that states the outcome, scope,
exclusions, assumptions, validation, evidence, and safety or privacy limits.
Use one focused paragraph when possible. Acceptance criteria are checklists;
Notes are the journal, not goal history. Use `update_task` to update or clear a
goal. Mirror it into a runtime only when that runtime has an explicit goal feature; TaskForge
remains authoritative.

For executable epics and tasks, populate applicable `agentExecution` fields
from the agreed plan. Do not add empty contracts or duplicate prose. Supported fields are `outcome`, `scope`,
`paths`, `assumptions`, `references`, `runtimePrerequisites`,
`validationPlan`, `recommendedSkills`, `safety`, `reviewFocus`, and
`reasoning`.

- Reference kinds: `file`, `doc`, `ticket`, `url`, `command`,
  `artifact`, `other`.
- Validation kinds (`validationPlan[].kind`): `test`, `lint`, `build`, `doctor`,
  `browser`, `debugger`, `review`, `manual` (never invent unlisted enum values).
- Skill priorities: `required`, `recommended`, `optional`.
- `update_task` shape: `{ workspace, id, payload: { ... } }` (always wrap updated
  fields in `payload: { ... }`, never at the top level).

Executable child contracts must include at least one concrete safety
constraint. Add privacy limits when the accepted scope handles sensitive data;
do not leave the safety arrays empty or rely on a generic privacy statement to
replace an execution constraint.

Most text values are capped at 1,000 characters and labels at 140. Put detailed
evidence in Validation, Notes, or attachments.

## Planning and tasking completeness

Planning applies this section to the prospective epic and each work package,
without ledger writes or API payloads. Tasking translates those decisions into
the supported fields and checks both the epic and every child independently.

- Cover outcome, included/excluded scope, allowed/do-not-touch paths,
  assumptions with verification hints, source references, runtime prerequisites,
  validation with expected evidence, skills, safety/privacy, and review focus.
  Evaluate reasoning per record; never inherit it from the epic. Record a short
  reason in the plan or handoff for genuinely inapplicable sections instead of
  filler fields. An unknown required prerequisite needs an owner and resolution.
- Keep the epic's paths and safety limits consistent with its child packages.
  Include necessary module wiring, shared exports, tests, and documentation.
  Surface a real scope conflict rather than silently broadening permissions.
- Distinguish task dependencies from runtime setup. Name actual services,
  supported runtime/tool versions, setup commands, ports, transaction support,
  and authenticated test access when relevant. Never include secret values.
- Give the epic integrated acceptance criteria and each child its own measurable
  checklist. Preserve the agreed requirement-to-scenario-to-proof mapping; a
  goal, Gherkin document, or child checklist does not replace epic acceptance.
- Ground validation commands in repository evidence. Mark required checks
  explicitly, include applicable repository doctor/review/readiness gates, and
  keep planned checks separate from actual Validation evidence. A missing runner
  is an owned prerequisite, never a guessed command.

### Skill selection and optional discovery

Inspect the host's advertised or installed skill inventory and applicable
repository instructions first. For each epic/package, identify the exact skill,
why and when it applies, availability evidence, and required/recommended/optional
priority. Map these to `recommendedSkills` using the live schema. A repository
requirement stays required; a useful optional skill must not become a blocker.
Keep availability, evidence, and discovery decisions in plan/handoff context
when the schema has no matching field. Do not invent field names or skill IDs.

Find Skills (`find-skills`, or a verified host alias) is an optional discovery
aid. Invoke it only when it is installed and usable AND the user explicitly
accepts discovery for this scope. Availability, an unknown skill, a suggested
option, or approval of the feature is not consent. If available and useful, ask
once using the host-permitted interaction method; reuse an explicit answer
across planning and tasking while scope is unchanged. Pending or declined
consent means no invocation. Continue from known skills and repository evidence.
If unavailable, record that fact and continue without an installation request.
Discovery consent does not authorize installing, enabling, or executing found
skills. Review candidates for relevance and availability before recording them.

### Persisted-record verification

After authorized writes, read back the epic and every child with execution
packets. Compare goals, acceptance criteria, applicable execution fields,
skill priorities, ownership, paths, and causal blockers against the agreed plan.
Check Gherkin presence/digest and verify authored content with the specification
read tool. Repair omissions within authorized scope; preserve unrelated fields
and existing contracts according to live update semantics. Reconcile partial
writes before retrying. Report each record as complete, intentionally
inapplicable with a reason, or incomplete with an owner and resolution. Do not
report tasking complete merely because create calls succeeded. Assignment and
branch context are not mandatory unless requested by the active workflow;
tasking must not prepare branches or start execution to fill them.

`agentExecution.reasoning` is task-specific dispatch guidance, not runtime
enforcement. Preserve supported redispatch fields and never claim it changed
the model or effort. Map Outcome, Scope, Non-goals, Allowed paths, Do not touch,
Safety constraints, Privacy, and Review focus to their matching fields. Omit a
field to preserve it; send `"agentExecution": null` only to clear the entire
contract.

The Agent tab presents assumptions, references, prerequisites, Validation, and
skills as explicit columns with one entry per line; keep round trips compatible
with that shape.

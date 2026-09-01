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

Use `agentExecution` only when structured fields improve execution. Do not add
empty contracts or duplicate prose. Supported fields are `outcome`, `scope`,
`paths`, `assumptions`, `references`, `runtimePrerequisites`,
`validationPlan`, `recommendedSkills`, `safety`, `reviewFocus`, and
`reasoning`.

- Reference kinds: `file`, `doc`, `ticket`, `url`, `command`,
  `artifact`, `other`.
- Validation kinds: `test`, `lint`, `build`, `doctor`, `browser`,
  `debugger`, `review`, `manual`.
- Skill priorities: `required`, `recommended`, `optional`.

Most text values are capped at 1,000 characters and labels at 140. Put detailed
evidence in Validation, Notes, or attachments. Use `$find-skills` only when
skill discovery is requested or the correct skill is unknown.

`agentExecution.reasoning` is task-specific dispatch guidance, not runtime
enforcement. Preserve supported redispatch fields and never claim it changed
the model or effort. Map Outcome, Scope, Non-goals, Allowed paths, Do not touch,
Safety constraints, Privacy, and Review focus to their matching fields. Omit a
field to preserve it; send `"agentExecution": null` only to clear the entire
contract.

The Agent tab presents assumptions, references, prerequisites, Validation, and
skills as explicit columns with one entry per line; keep round trips compatible
with that shape.

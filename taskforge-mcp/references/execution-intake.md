# Execution intake

Read this reference before beginning, resuming, or merge-validating ticket
implementation.

Call `get_task_execution_packet`; it is the canonical execution intake. Do not
rebuild the contract from scattered reads. Verify ticket identity, workspace,
status, type, epic and initiative context, blockers, goal, included and
excluded scope, allowed and forbidden paths, assumptions, references,
prerequisites, required validation, recommended skills, safety, privacy, review
focus, project context, and branch context.

Read the parent epic packet for an ordinary task. Read the initiative packet
when the router requires it. Stop for an unresolved blocker, missing goal or
boundary, required unavailable prerequisite, or conflicting project or branch.
Do not narrow, ignore, or invent contract fields. Reread before completion or a
merge when implementation, review, blockers, branch state, or ledger state may
have changed.

The packet is compact by design. It links initiative data through
`get_initiative_execution_packet`, reports bounded validation summaries, and
reports Gherkin availability and digest rather than the full specification. Use
the purpose-built attachment list and Gherkin tools only when their referenced
detail is needed.

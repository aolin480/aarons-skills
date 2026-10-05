---
name: tasking
description: "Convert an agreed engineering plan into TaskForge epics, executable tasks, goals, acceptance criteria, and genuine prerequisite blockers. Stop before scheduling or implementation."
---

# TaskForge tasking

Inputs are an agreed plan, authorized record changes, and a resolved workspace.
If the plan is not agreed, return that prerequisite to the caller before writes.

1. Read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), [authoring](references/authoring.md),
   [lifecycle](references/lifecycle.md), [Gherkin](references/gherkin-acceptance.md), and
   [evidence](references/evidence-and-attachments.md) before their actions.
2. Resolve the selected runtime and workspace from current evidence. If MCP is
   unavailable, return the prerequisite gap; do not invent record IDs.
3. Resolve or create the epic first, then create each ordinary child with its
   `epicId`. Write stand-alone goals, acceptance criteria, and useful
   `agentExecution` fields from the agreed plan for both epic and children.
   Pass only fields advertised by the selected create tool: the current
   `create_epic` contract does not accept `acceptanceCriteria`. When integrated
   epic criteria must be persisted, use a separately advertised `update_task`
   after creation; never add unsupported fields or silently drop the criteria.
   Each executable child must include at least one concrete
   `agentExecution.safety.constraints` entry; add privacy limits when the
   accepted scope handles sensitive data.
   Apply authoring's completeness and consent-gated skill selection rules.
   Persist agreed specifications in top-level `gherkinSpec`; explain any
   inapplicability. Keep path and safety limits.
4. Add blockers for real prerequisites and verify the resulting graph. Preferred
   order is not a blocker. Preserve every successful or partial create receipt;
   after an uncertain write, reconcile authoritative reads before any retry.
   When `get_task` is advertised, read each created record for identity and
   hierarchy, then use its execution packet for contract completeness.
5. Perform authoring's persisted-record verification across the epic and every
   child before declaring completion. Use
   [initiative](references/initiative-workflow.md) for initiative context, and
   [programmatic orchestration](references/programmatic-orchestration.md) only
   for explicitly requested, advertised optional capabilities.
6. Return canonical records, dependency verification, partial outcomes, and the
   [handoff](references/handoff.md). Do not start implementation, create a timeline,
   reset order, or activate epic/initiative execution from this invocation.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `add_task_blockers`
- `add_task_labels`
- `attach_task_to_epic`
- `convert_markdown_to_tasks`
- `create_epic`
- `create_epic_tree`
- `create_task`
- `create_task_tree`
- `link_task_dependency`
- `move_task_to_epic`
- `remove_task_labels`
- `set_task_blockers`
- `set_task_labels`
- `update_task`

---
name: initiative
description: "Coordinate TaskForge initiative context and explicitly activated participant branch execution, with serial epic integration and separate approval and proof for every primary merge."
---

# TaskForge initiative

Inputs are the exact initiative, participant context, and requested operation.
Linkage or cross-workspace scope alone never activates branch execution.

1. For every invocation, read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), and the [handoff contract](references/handoff.md).
   Reuse complete unchanged reads under the operating rules. Skip project-context
   writes during pure lookup. Classify the requested operation before resolving
   or reading an initiative packet or loading broad execution references.
2. For an existing initiative lookup or operation, resolve its exact packet with
   `get_initiative_execution_packet`. For an explicitly requested initiative
   creation, do not require a pre-existing packet: load the canonical initiative
   contract, [authoring](references/authoring.md), and
   [evidence](references/evidence-and-attachments.md) rules, then verify the
   created initiative identity. For an explicitly
   requested change to an existing initiative, load the canonical contract and
   evidence rules needed for that change. Pure lookup returns without
   execution or project-context writes. Do not infer branch activation
   or standing approval.
3. On explicit branch workflow activation, load [execution intake](references/execution-intake.md),
   [lifecycle](references/lifecycle.md), [branching](references/branching-and-approvals.md),
   [evidence](references/evidence-and-attachments.md), and the complete
   [initiative workflow](references/initiative-workflow.md), then require
   participant-scoped runtime compatibility before Git changes. Prepare each
   participant lazily and keep all workspace identities and persisted branch
   contexts distinct.
4. After explicit branch-workflow activation, resolve each linked epic,
   participant workspace, Git root, registered primary, blockers, and readiness.
   Compose epic execution one epic at a time, each from its repository's latest
   initiative branch. Read [epic workflow](references/epic-workflow.md) for the
   serial child loop; initiative rules own the epic's local initiative target.
5. Compose validation and merge for clean authorized integration. Run required
   participant and cross-workspace checks before initiative review. Never
   substitute one repository's success for all required participants.
6. Request explicit approval naming initiative, workspace, and registered primary
   for each final merge. Apply only approved participants, verify each persisted
   proof, and retain review until all required proof exists. Return the
   [handoff](references/handoff.md) with local and cross-workspace outcomes.

Activation grants only the canonical integration approvals. Delegation and
host-specific attended routing remain separately gated. Use the
[worker packet](templates/worker-packet.md) only when delegation is authorized.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.

- `add_initiative_labels`
- `create_initiative`
- `get_initiative`
- `get_initiative_execution_packet`
- `link_initiative_epic`
- `list_initiatives`
- `merge_initiative_branch`
- `prepare_initiative_branch`
- `remove_initiative_labels`
- `set_initiative_labels`
- `unlink_initiative_epic`
- `update_initiative_goal`
- `update_initiative_readiness`
- `update_initiative_status`

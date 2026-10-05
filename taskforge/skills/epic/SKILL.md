---
name: epic
description: "Run an explicitly activated TaskForge epic branch workflow through serial child implementation, validation, and clean integration. Stop for exact final primary approval."
---

# TaskForge epic

Require explicit epic execution activation. Naming an epic, inspecting it,
planning its children, or invoking this entry for information is not activation.

1. For every invocation, read [operating rules](references/operating-rules.md),
   [discovery](references/discovery.md), and the [handoff contract](references/handoff.md).
   Reuse complete unchanged reads under the operating rules. Skip project-context
   writes during pure lookup. Determine whether the current request explicitly
   activates the Epic Branch Workflow before loading broad execution references.
2. Without explicit activation, resolve only the requested inspection scope and
   return that inspection result; execution was not requested. Do not load
   branch, execution, evidence, or epic-workflow details, prepare branches,
   change status, or infer approval. For explicit activation, load [execution
   intake](references/execution-intake.md), [lifecycle](references/lifecycle.md),
   [branching](references/branching-and-approvals.md),
   [evidence](references/evidence-and-attachments.md), and the complete [epic
   workflow](references/epic-workflow.md) before execution.
3. After explicit activation, resolve the epic contract, workspace, authoritative
   primary or legacy branch, timeline, blockers, and scope. Bootstrap and run the
   canonical serial child loop. Compose implementation, validation, and merge for
   each child, returning to the latest validated epic branch before preparing the
   next. Do not create all child branches up front.
4. Preserve the clean child-to-matching-epic standing approval boundary.
   Validation returns failures; this caller owns authorized corrections and
   evidence invalidation. Run integrated validation before epic review.
5. Apply [Gherkin](references/gherkin-acceptance.md) when present and
   [timeline](references/timeline.md) for eligible selection. Optional attended
   routing requires its own current opt-in and host guard via
   [special workflows](references/special-workflows.md).
6. Leave the reviewed epic unmerged until exact primary approval. Return the
   [handoff](references/handoff.md) and follow the canonical approval stop.
   For an activated initiative caller, return integrated epic evidence to that
   caller; its exact local initiative target governs the next merge.

Execution activation does not authorize subagent delegation. Use the
[worker packet](templates/worker-packet.md) only after separate delegation authority.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.



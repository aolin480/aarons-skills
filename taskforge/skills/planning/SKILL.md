---
name: planning
description: "Create an engineering plan for a feature or defect from repository evidence. Stop before creating tasks, changing a timeline, or implementing code."
---

# TaskForge engineering planning

Use for “plan a feature,” “plan a bug fix,” or an explicitly named planning
invocation. Start with the supplied request and bounded local evidence. After a
short source check, ask early about material product choices the repository
cannot answer, while continuing independent read-only investigation. The
workflow then returns a plan that another engineer can task without repeating
the architecture discovery.

1. Before drafting or returning, read [operating rules](references/operating-rules.md)
   and the [handoff contract](references/handoff.md). Reuse content already
   read completely in this invocation when available. Planning from supplied or
   local context does not require MCP, a workspace selection, or ledger writes.
2. Classify the request before loading the long planning material. Use the
   compact route only for a bounded, known-owner change with settled requirements
   and no material uncertainty about architecture, data, shared or public
   contracts, auth/tenant behavior, retries, external effects, or recovery. One
   package is valid. Do not force full matrices or N/A sections. If investigation
   finds material risk or uncertainty, upgrade to the detailed route; meaningful
   risk or a cross-layer/shared/public contract change also uses the detailed
   route. A user-requested deep plan always uses it.
3. For the compact route, read the whole [compact planning](references/compact-planning.md)
   reference for its decision-complete minimum. For the detailed route, read
   [engineering planning](references/engineering-planning.md)
   and its [plan template](templates/engineering-plan.md) completely before
   drafting. Load
   [interactive planning questions](references/planning-questions.md) only when
   a material user decision is actually needed, before asking it, and follow its
   native-first or inline fallback contract.
4. Follow the selected workflow's phases: the compact workflow for compact plans
   or every applicable detailed phase for detailed plans. Mark evidence as
   confirmed, observed, inferred, hypothesized, decided,
   assumed, or unknown. Carry supplied product constraints as settled decisions;
   keep defect causes separate from hypotheses, and do not claim a file or owner
   is absent without evidence of the inspected scope. Make every low-risk
   assumption and every unresolved decision visible with an owner, impact, and
   resolution path.
5. In both compact and detailed plans, apply the planning-only completeness and
   skill-selection rules in [authoring](references/authoring.md), and draft
   [Gherkin acceptance](references/gherkin-acceptance.md) for the prospective
   epic and each package. Include applicable execution details, skill
   availability and discovery consent, and a specification or justified
   inapplicability. These are plan content only; do not perform authoring writes.
6. Return the plan, evidence, package dependencies, epic-first tasking mapping,
   validation commands with expected outcomes, rollout concerns, and the
   handoff contract. For a non-trivial plan, use the user's requested artifact
   path or an authorized existing repository planning convention; a compact plan
   may stay in chat. Mark the plan implementation-ready only when material
   architecture and product decisions are settled; otherwise include bounded
   discovery work and state the blocker.

Stop with the plan. Do not create or update records, call `create_plan`, change
status, prepare a branch, edit implementation code, delegate work, or invoke
tasking, execution, or timeline scheduling automatically. Package labels such as
`P1` are local plan identifiers, never TaskForge ticket IDs.

## TaskForge MCP Tool Guide

Tool inventory is not permission to call a tool. Apply the workflow gates above.



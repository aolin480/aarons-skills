# Compact planning

Use this whole-file workflow only after the planning entry selects the compact
route. It produces a decision-complete plan for a bounded, known-owner change
without loading the detailed planning reference or full template.

## Eligibility

Compact planning requires all of the following:

- the owner and affected behavior are known from supplied context and a bounded
  read of the repository;
- requirements and product constraints are settled;
- no material uncertainty remains about architecture, data, shared or public
  contracts, auth or tenant behavior, retries, external effects, recovery, or
  release safety; and
- the user did not request a deep plan.

One package is valid. If investigation finds material risk or uncertainty, a
cross-layer or shared/public contract change, or a user request for more depth,
upgrade to the detailed route. Never hide a question or risk to remain compact.
A small fixture or one-file scope does not make unsettled material product
behavior compact; ask before dependent drafting or upgrade to detailed.
Use [engineering planning](engineering-planning.md) and the [full plan
template](../templates/engineering-plan.md) completely after that upgrade.

## Compact workflow

1. State the observable outcome, affected users or operators, allowed scope,
   constraints, settled product decisions, exclusions, and success measure.
2. Record current evidence and map the known owner, consumers, and flow. Use
   repository-relative paths and state the inspected scope for every claim.
   Do not claim that a file, symbol, consumer, or owner is absent from a partial
   search.
3. Mark claims as confirmed, observed, inferred, hypothesized, decided,
   assumed, or unknown. Keep defect observations and confirmed causes separate
   from hypotheses. Carry supplied product constraints as settled decisions. If
   current evidence conflicts with a settled decision, surface the evidence,
   impact, and decision owner, then upgrade to the detailed route.
4. Define target behavior with observable success and failure scenarios. Keep
   relevant interface, data, failure, auth, compatibility, and recovery meaning
   inline. If a material decision is missing, follow [interactive planning
   questions](planning-questions.md) before asking; dependent work waits for the
   actual answer while independent read-only investigation continues. Do not
   draft dependent compact sections until the answer arrives; upgrade when the
   decision changes compact eligibility.
5. Create one or more cohesive `P#` work packages. Each package includes its
   implementation, directly relevant tests, and necessary docs or setup;
   allowed paths, real prerequisites, approach, acceptance scenarios, grounded
   validation checks, expected outcomes, and source context. Leave exact helper
   names and local mechanics to the implementer. Separate validation work only
   for a distinct integration or release boundary or an independently valuable
   outcome. Do not split one-file chores or force microsteps.
6. Map each prospective ordinary task to supplied epic context or a proposed
   epic goal/grouping for later tasking. A single package has no orphan-task
   exception. Unknown workspace or epic identity remains pending tasking; do not
   use MCP or create an epic merely to plan.
7. State validation checks as `planned` or `run`. Ground commands in repository
   scripts, targets, configuration, or verified precedent, and give expected
   evidence. Diagnostic checks are read-only with respect to implementation and
   the TaskForge ledger; do not seed data, migrate, or run mutation experiments
   solely to prove a hypothesis.
8. State implementation readiness separately from release readiness. Set
   `release-ready` only when every release-required check is marked `run` and
   its expected evidence is satisfied. A required check that is `planned`,
   unavailable, or unsatisfied means `release-evidence-needed` (or
   `release-decision-needed` for a human decision); implementation-ready may
   remain true. Name each unknown's owner, impact, and resolution. Preserve
   settled decisions and unchanged `P#` IDs when revising an existing plan.

## Compact output minimum

Use this structure in chat or at the authorized artifact path. Omit sections
that do not apply, but do not omit a material requirement, decision, owner,
failure meaning, proof obligation, or release concern.

```markdown
# Engineering plan: <observable outcome>

Plan state: `implementation-ready` | `discovery-required` | `blocked`
Release state: `release-ready` | `release-evidence-needed` | `release-decision-needed`
Release-ready requires every release-required check to be `run` with satisfied
evidence; pending planned proof means `release-evidence-needed`.

## Outcome and scope

- Problem or opportunity: <why>
- Observable outcome: <what users, operators, or consumers see>
- Requirements and success: <R# and observable proof>
- Constraints and settled decisions: <supplied or decided constraints>
- Low-risk assumptions: <assumption — why safe — impact — revisit trigger>
- Exclusions: <deferred behavior and disposition>

## Evidence and current owners

- Evidence: <E# — claim — repository-relative source or supplied evidence — state>
- Current flow: <trigger -> owner -> state/data -> consumer>
- Owners and consumers: <responsibility, owner, consumers, impact>
- Reused pattern: <source and reason it fits>
- Defect evidence (if applicable): <observed behavior — confirmed cause — hypothesis and resolving check>

## Target behavior and decisions

- Scenarios: <success and relevant failure cases>
- Decisions: <D# — owner — selected behavior — provenance>
- Decision conflicts: <evidence, impact, and owner; otherwise none found in the inspected scope>
- Interface/data/failure meaning: <inline semantics when applicable>

## Work packages

### P1 — <package outcome>

- Owner and allowed paths: <accountable owner and bounded paths>
- Implementation, tests, docs/setup: <cohesive behavior slice>
- Prerequisites: <causal package IDs, decisions, evidence, or runtime needs>
- Approach: <responsibility boundary and implementation discretion>
- Acceptance: <observable scenarios>
- Validation: `planned` or `run` — <exact check> — expected: <evidence>
- Context: <E#/D#/paths/references>

## Epic-first tasking mapping

- Existing epic context or proposed epic goal/grouping (required for every
  prospective ordinary task, including one `P1`): <context or proposal; never an
  orphan task>
- Package-to-task relation: <each package's outcome, acceptance, proof, and real dependencies>
- Workspace/epic identity: <supplied or `pending tasking`>

## Unknowns and readiness

- Unknowns: <question — owner — impact — resolution>
- Implementation readiness: <state and reason>
- Release readiness: <state and reason>
- Next permitted action: <tasking, bounded discovery, implementation, or decision>

## Completeness challenge

- [ ] Every requirement has a package, acceptance scenario, and proof.
- [ ] Packages are cohesive, independently reviewable, single-owned, and dependency-acyclic.
- [ ] Every prospective ordinary task maps to supplied epic context or a proposed epic goal/grouping, including a one-package plan; no TaskForge record or MCP lookup was used to fill the mapping.
- [ ] No material decision is hidden as an assumption; planned and run checks are distinct.
```

This is a planning artifact only. Do not create records, change status, prepare
branches, edit implementation code, schedule a timeline, delegate work, or
invoke tasking or execution. A later authorized workflow performs TaskForge
tasking under the epic-first contract.

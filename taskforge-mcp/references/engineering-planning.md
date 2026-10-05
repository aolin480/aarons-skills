# Engineering planning

This reference owns the investigation and decomposition rules for the planning
skill. It produces a repository-grounded plan that can later become TaskForge
work without repeating architecture discovery. It is planning-only: it creates
no TaskForge records, timeline entries, statuses, branches, or implementation
code. An authorized plan-artifact write follows the path rules below.
Planning from supplied or local evidence works without MCP, authentication, a
workspace selection, or project-context writes. Read [discovery.md](discovery.md)
only for a separately authorized, read-only ledger lookup; do not make that
lookup a prerequisite for this workflow.

Use the [engineering plan template](../templates/engineering-plan.md). Keep the
plan proportional to the change, but do not omit a material contract, owner,
failure path, proof obligation, or decision. Write `not applicable` with a
reason when a section does not apply.

Use [compact planning](compact-planning.md) as the whole-file workflow for a
bounded compact plan. This detailed reference and the full template are required
after the entry selects detailed mode or compact investigation upgrades because
of material risk, uncertainty, cross-layer behavior, or a deep-plan request.

## Artifact and revision handling

For a non-trivial plan, use the user's requested artifact path. If none is
provided, use an existing repository planning-document convention only when the
write is authorized; do not invent a new location. A compact plan may remain in
chat. Inside the plan, use repository-relative source paths so the document can
move with the checkout. The final response may link the actual local artifact.

When revising an existing plan, preserve its settled decisions, relevant
evidence, and stable package IDs. Keep each `P#` ID when its outcome and boundary
remain the same; record material changes and re-check affected evidence instead
of silently replacing the plan's history.

## Investigation contract

Before deep investigation, record:

- the requested outcome or defect, affected users or operators, and supplied
  evidence;
- constraints, allowed investigation, explicit exclusions, and settled
  decisions;
- the repository and instruction scope being inspected; and
- the stopping boundary: enough evidence to name current owners and consumers,
  describe target behavior, choose package boundaries, and prove each acceptance
  scenario.

Identify material product choices at intake. After a short, bounded read of the
directly relevant source, ask a focused question when the repository cannot
answer one. Continue independent read-only investigation while awaiting the
answer; only the dependent contract or package decisions must wait.

Carry explicit product constraints supplied by the user or existing context into
the settled-decisions record. Do not convert a supplied constraint into a new
question unless current evidence directly conflicts with it. If it conflicts,
surface the evidence, impact, and decision owner under the decision-conflict
rule below.

Read applicable `AGENTS.md`, `CLAUDE.md`, and `CONTEXT.md` files before relying
on a local convention. Inspect source, schemas, routes, configuration, tests,
history, and documentation only where they answer a question in scope. Prefer
the smallest relevant owner and consumer set. Do not turn a plan into a broad
repository audit.

Maintain an evidence ledger. Give each material claim a source path, command,
user statement, or observed result and one of these states:

| State | Meaning |
| --- | --- |
| Confirmed | Directly supported by current source, tests, configuration, or an explicit settled decision. |
| Observed | Behavior was reproduced or directly observed; the cause may still be unknown. |
| Inferred | A reasoned reading of structure that has not been directly verified. |
| Hypothesis | A possible defect cause or design explanation with a resolving check. |
| Decided | A material product, architecture, or release choice accepted by its owner. |
| Assumed | A low-risk provisional choice that names its impact and revisit trigger. |
| Unknown | Evidence or authority is missing; an owner, impact, and resolution are required. |

Do not present an inferred fact or hypothesis as confirmed. Do not claim a check
was run when it is only planned.

## Investigation phases

Work through these phases in order. Return to an earlier phase when new evidence
changes an owner, contract, or decision. Preserve settled decisions unless their
owner explicitly reopens them. If current evidence contradicts a settled
decision, surface the conflict with its source, impact, and decision owner. Do
not silently preserve a now-invalid decision or assumption or replace the
decision with an inference; keep dependent work unresolved until the owner
decides.

### 1. Frame the outcome and boundary

Describe the observable result in user or operator terms. State the trigger,
expected behavior, affected surfaces, measurable success, constraints, and
exclusions. Split compound requests into requirements without deciding
implementation details prematurely.

List material product choices early. Perform a short, bounded source check only
long enough to see whether current behavior or repository conventions answer
each one. If the repository cannot answer a choice, ask a focused question that
names the evidence, available choices, and consequence of each choice. Continue
independent owner, consumer, and validation investigation while awaiting the
answer. Ask only for a decision that changes user-visible behavior,
compatibility, data meaning or retention, authorization, failure semantics,
ownership, or release safety. Record the answer as decided. If no answer is
available, keep the decision in Unknowns and do not label dependent work
implementation-ready.

Follow the interactive planning questions reference for capability selection,
question count and options, inline formatting, answer provenance, and
pending-answer behavior. Do not ask again for a choice already settled by the
user or context.

Make low-risk assumptions explicit. For each assumption, state why it is safe,
what it affects, and the event that would require revisiting it. Do not hide a
material product or architecture decision inside an assumption.

### 2. Map current owners, consumers, and flow

Inspect the current path from trigger to observable result:

`trigger -> boundary -> owner -> data/state -> side effect -> consumer`

Name the current owner for each responsibility and the consumers that depend on
it. Include web, API, MCP, jobs, commands, shared contracts, persistence,
events, caches, and tests when they are in the path. Record the exact paths,
symbols, routes, schemas, or configuration keys that support each claim.

Capture at least:

- the entry point and boundary validation;
- the source of truth and read/write owners;
- public or cross-package interfaces and their consumers;
- authorization, tenant identity, audit, and external side effects when
  applicable; and
- existing tests, fixtures, commands, and runtime checks that establish current
  behavior.

If the proposed change crosses a boundary, state which owner changes and which
consumers remain stable. If no suitable owner exists, propose the narrowest new
owner and explain why adjacent owners are unsuitable. Do not invent exact
helper names or speculative code to make the map look complete. Do not claim
that a file, symbol, consumer, or owner is absent from the repository based on
a partial search. State the inspected search scope and evidence; otherwise say
it was not located in that scope and keep the claim unknown.

### 3. Find repository patterns and real alternatives

Inspect the nearest analogous implementation, shared contract, validation path,
error mapping, persistence pattern, and relevant test. State which pattern the
plan reuses and why its ownership and semantics fit. Check consumers before
copying or extracting behavior.

List alternatives only when the current evidence exposes a genuine choice, such
as a different owner, compatibility strategy, data representation, or rollout
shape. For each material alternative, state the relevant benefit, cost, and
reason for the selected option. Omit speculative variants and cosmetic choices.
Do not force reuse across a module boundary that would create coupling or change
semantics.

### 4. Diagnose a defect from evidence

For a defect, record the smallest reproducible case:

- environment and relevant revision or configuration;
- trigger and steps;
- expected and actual behavior;
- frequency, scope, and affected consumers; and
- whether the behavior was reproduced in this investigation.

Separate the result into three records:

| Record | Required content |
| --- | --- |
| Observed behavior | What happened, where, and under which conditions. |
| Confirmed cause | The causal chain supported by source or a resolving experiment. |
| Hypothesis | A plausible cause, supporting clue, and exact next check. |

Diagnostic checks must be read-only with respect to implementation and the
TaskForge ledger, follow host and repository authorization, and avoid mutation
experiments, seeding, or migrations solely to prove a planning hypothesis. If a
check would mutate code, ledger state, or durable data, identify its owner and
authorization as an unresolved prerequisite rather than running it.

If the cause remains a hypothesis, do not write an implementation package that
quietly assumes it. Add a bounded discovery package with an outcome, allowed
paths, resolving check, and handoff evidence, or mark implementation readiness
blocked when the discovery cannot be bounded safely.

### 5. Settle target behavior and contracts

Describe the target behavior as observable scenarios. Define the contract at
each affected boundary before naming implementation units. For every relevant
interface, data shape, and failure path, specify:

| Concern | Define |
| --- | --- |
| Interface | Caller, owner, input, output, validation, and compatibility behavior. |
| Data | Source of truth, reads and writes, required/optional/null/default meaning, ordering, retention, migration or backfill, and audit implications. |
| Failure | Invalid input, missing state, unauthorized access, conflict, timeout, dependency failure, duplicate, retry, crash/reload, and terminal result. |
| Concurrency | Idempotency key or duplicate rule, ordering, locking/version check, and stale-write behavior when applicable. |
| Security | Identity and tenant source, authorization point, deny-before-query rule, and sensitive-data handling when applicable. |
| Compatibility | Existing consumers, mixed versions, versioning/deprecation, and migration order when applicable. |

Use `not applicable` only after checking the current flow. Do not invent status
codes, field names, event types, helper names, or retry behavior without
repository or product evidence. When behavior is intentionally unchanged, say
so and identify the proof.

Record material choices in a decisions table with the decision owner, evidence,
selected behavior, alternatives considered when real, and consequence. Keep
settled decisions stable across plan revisions. If later evidence conflicts with
one, add the conflict and its impact to Unknowns and return it to the decision
owner; do not silently rewrite the decision or hide the conflict as an
assumption.

### 6. Define proof before decomposition

For each requirement and scenario, identify observable proof. Use exact
repository-grounded commands, test targets, fixtures, browser or API paths, or
manual checks. Record:

- the command or action and its target;
- the expected evidence and failure signal;
- prerequisites and responsible owner;
- whether it is `planned` or `run`; and
- limitations, unavailable services, or unverified claims.

Derive commands from current package scripts, Nx targets, test configuration,
repository runbooks, or verified local precedent. Do not guess a command from a
framework name. A plan may list a check as planned without running it; a run
result needs its actual output or a concise observed result. Child package proof
does not replace integrated proof when behavior crosses packages, services,
durable state, or a public contract.

### 7. Decompose into behavior slices

Create stable local work-package IDs such as `P1`, `P2`, and `P3`. Keep an ID
when a package's outcome and boundary survive a plan revision; do not reuse an ID
for a different package. These labels are not TaskForge ticket IDs.

Each package must be a cohesive, independently reviewable behavior slice. It
must include:

- a concise outcome and accountable owner;
- implementation, directly relevant tests, and necessary documentation or setup
  in the same package by default;
- allowed paths and explicit do-not-touch boundaries where useful;
- genuine prerequisites only, expressed as package IDs, settled decisions,
  required evidence, or runtime prerequisites;
- the approach and responsibility boundary, with implementation discretion left
  to the implementer;
- observable acceptance scenarios, including relevant failure cases;
- validation and evidence with exact commands or actions and expected outcomes;
  and
- relevant source context, decisions, contracts, and references.

Separate validation work into its own package only when it has a distinct
integration or release boundary, or an independently valuable outcome. Do not
create a separate test-only package for convenience.

Do not split a package into forced microsteps, one-file chores, or time-based
estimates. Split when ownership, reviewability, deployment safety, or a real
dependency requires it. A preferred order is not a prerequisite. Dependencies
must be causal and acyclic; explain any cross-layer dependency in terms of the
behavior it enables.

If implementation depends on unresolved architecture, mark the plan
`discovery-required` or `blocked`. A bounded discovery package can precede
implementation only when it has a clear question, allowed paths, owner,
resolving evidence, acceptance scenarios, and a handoff outcome.

### 8. Assess safety, rollout, and rollback

Scale this phase to risk. For changes involving data ownership, public
contracts, auth or tenancy, queues/retries, external side effects, migrations,
or runtime rollout, cover:

- release and consumer order, including mixed-version behavior;
- feature-flag or staged-exposure defaults when applicable;
- monitoring, alerts, and the operator who owns them;
- rollback trigger and concrete rollback action;
- migration, backfill, forward-compatibility, and recovery prerequisites; and
- exclusions classified as safe deferral, release blocker, or human decision.

For low-risk local or documentation changes, state why rollout and rollback are
not applicable. Keep implementation readiness separate from release readiness:
bounded code work may be ready while launch evidence, operations, or a human
release decision remains open.

### 9. Map the plan to prospective TaskForge work

Preserve the epic-first handoff. Any prospective ordinary task must map to an
existing epic supplied by the context or to a proposed epic goal/grouping that
the later tasking workflow will resolve. The goal should state the resulting
behavior, scope, and integrated quality bar. A single behavior package is valid,
but its ordinary task still has an epic context or proposed epic grouping; small
size is not an orphan-task exception. Map each package to a prospective task by
carrying over its outcome, allowed paths, prerequisites, acceptance scenarios,
and proof.

Use one task per package by default. Combine packages only when they share an
owner and behavior boundary without losing independent review or proof. Split
only when a package has multiple genuine owners, release boundaries, or
independent behavior slices. Preserve only real dependencies. This mapping is
an explanation for a later tasking workflow; it contains no API payloads,
TaskForge ticket IDs, record writes, timeline order, or MCP lookup merely to
resolve workspace or epic identity, and does not create an epic merely to plan.
If that identity is not supplied, leave it pending tasking; it is not a planning
blocker.

### 10. Challenge completeness and assign readiness

End with the completeness challenge in the template. Confirm that every
requirement has a package, acceptance scenario, and proof; dependencies are
acyclic; responsibilities are single-owned; and no material implementation
decision is hidden as an assumption.

Then state one of:

- `implementation-ready`: architecture, product behavior, contracts, owners,
  and material prerequisites are settled enough for bounded implementation;
- `discovery-required`: bounded evidence work must complete first; or
- `blocked`: a material decision or architecture question cannot be bounded
  without its owner.

State release readiness separately as `release-ready`, `release-evidence-needed`,
or `release-decision-needed`, with the owner and next proof or decision. Use
`release-ready` only when every release-required check is marked `run` and its
expected evidence is satisfied. Planned, unavailable, or unsatisfied required
proof means `release-evidence-needed`; an unresolved human choice means
`release-decision-needed`. Implementation-ready may remain true while release
evidence is pending.

## Return boundary

Return the completed plan or its local artifact path, evidence ledger, settled
decisions, explicit assumptions, unknowns, package dependency graph, prospective
tasking mapping, validation status, release concerns, and the next permitted
action. Use the [handoff contract](handoff.md) for the summary. Stop there.

Do not create or update TaskForge records, call `create_plan`, change status,
prepare or clean branches, edit implementation code, delegate work, schedule a
timeline, or invoke tasking or execution automatically. A later user request
must authorize those separate workflows, even when the original request also
asked to implement the idea.

# Engineering plan: <observable outcome>

Plan state: `implementation-ready` | `discovery-required` | `blocked`
Release state: `release-ready` | `release-evidence-needed` | `release-decision-needed`
Evidence basis: `<supplied context, local paths, commands, or observed run>`
Artifact: `<requested or authorized repository path>` | `chat (compact plan)`

`release-ready` requires every release-required check to be `run` with satisfied
evidence. Any required check still `planned`, unavailable, or unsatisfied means
`release-evidence-needed`; `implementation-ready` may remain true.

For a non-trivial plan, use the user's requested artifact path or an authorized
existing repository planning-document convention. A compact plan may stay in
chat. Use repository-relative source paths inside this plan; the final response
may link the actual local artifact. When revising an existing plan, preserve its
settled decisions, relevant evidence, and stable `P#` IDs for unchanged package
outcomes and boundaries.

> Compact route: use the whole [compact planning reference](../references/compact-planning.md)
> for its workflow and output minimum. Use this full template only for detailed
> plans or compact plans that upgrade after investigation.

## Outcome, scope, and success

- **Problem or opportunity:** <what needs to change and why>
- **Observable outcome:** <what users, operators, or consumers will see>
- **Requirements:**
  - R1: <behavioral requirement>
  - R2: <behavioral requirement>
- **Success measures:** <observable result for each material requirement>
- **Constraints:** <technical, product, compatibility, safety, or process limits>
- **Allowed scope:** <repositories, packages, services, or paths investigated>
- **Exclusions:** <explicitly deferred behavior and disposition: safe deferral, release blocker, or human decision>
- **Settled decisions:** <decisions supplied or accepted before this plan; preserve them>
- **Low-risk assumptions:** <assumption — why safe — impact — revisit trigger>

## Evidence and current architecture

### Investigation record

| ID | Claim or observation | Source or command | State | Consequence |
| --- | --- | --- | --- | --- |
| E1 | <current behavior or constraint> | `<path>`, `<symbol>`, `<command>`, or supplied evidence | confirmed / observed / inferred / decided / assumed / unknown | <design or validation effect> |

### Owner and consumer map

| Responsibility or flow step | Current owner | Consumers and dependencies | Evidence | Change impact |
| --- | --- | --- | --- | --- |
| <trigger / boundary / state / side effect / output> | `<path or module>` | `<paths, services, jobs, or tests>` | E1 | <stable / moves / extends> |

**Current flow:** `<trigger> -> <boundary> -> <owner> -> <data/state> -> <side effect> -> <consumer>`

**Relevant existing patterns and reuse:** <nearest analogous implementation,
shared contract, validation/error path, persistence pattern, and test. State the
selected pattern and why its boundary fits. List alternatives only when a real
tradeoff affects the decision.>

### Defect diagnosis (use for defects)

- **Reproduction:** <environment, revision/configuration, trigger, steps, frequency>
- **Expected:** <behavior>
- **Actual:** <behavior>
- **Observed scope:** <affected users/consumers and whether reproduced>

| Record | Evidence | Status | Next check |
| --- | --- | --- | --- |
| Observed behavior | E# | <confirmed observation> | <none or follow-up> |
| Confirmed cause | E# | <causal chain supported by evidence> | <none or follow-up> |
| Hypothesis | E# | <possible cause; do not treat as confirmed> | `<exact resolving check>` |

## Decisions, interfaces, data, and failure semantics

### Material decisions

| Decision | Owner | Evidence or choices | Selected behavior | Impact if changed |
| --- | --- | --- | --- | --- |
| D1: <decision> | <person/role> | E#; <real alternatives only> | <accepted choice> | <affected scope> |

**Decision conflicts:** <current evidence that contradicts a settled decision,
its impact, decision owner, and resolution. Do not silently preserve or replace
the decision.>

**Supplied product constraints carried forward:** <constraints from the request
or existing context recorded as settled decisions; do not turn them into new
questions unless current evidence conflicts.>

**Answered planning questions:** `<Q#>` — `<concise answer>` — provenance:
`<actual user answer, supplied context, or current evidence>` — recorded as
`D#` and carried into later work.

### Target behavior scenarios

- **Scenario S1 — <success or failure case>**
  - Given: <precondition>
  - When: <trigger>
  - Then: <observable result and proof>
- **Scenario S2 — <boundary or failure case>**
  - Given: <precondition>
  - When: <trigger>
  - Then: <observable result, error meaning, and recovery/terminal behavior>

### Contract matrix

| Boundary | Owner | Input and validation | Output or state | Failure and retry semantics | Auth/tenant and compatibility |
| --- | --- | --- | --- | --- | --- |
| <route, event, module, job, or UI boundary> | `<path>` | <explicit meaning> | <explicit shape/state> | <invalid, missing, conflict, timeout, duplicate, crash, terminal> | <source, deny-before-query, mixed-version behavior, or N/A with reason> |

### Data semantics

<Source of truth, reads/writes, required/optional/null/default meaning, ordering,
retention, migration/backfill, audit history, cache invalidation, and recovery.
Use N/A with a reason when checked and irrelevant.>

## Work packages

These are stable local labels, not TaskForge records or ticket IDs. Each package
is an independently reviewable behavior slice. Do not turn it into microsteps or
add time estimates.

### P1 — <package outcome>

- **Outcome:** <behavior this package makes true>
- **Owner:** <accountable owner or module>
- **Implementation, tests, docs/setup:** <keep the behavior slice's implementation, directly relevant tests, and necessary documentation or setup together by default>
- **Allowed paths:** `<path or bounded path pattern>`
- **Do not touch:** `<explicit boundary, if useful>`
- **Prerequisites:** <causal package IDs, settled decisions, evidence, or runtime prerequisite; no preferred order>
- **Approach:** <responsibility boundary, reused pattern, and implementation discretion>
- **Acceptance scenarios:** S#; <additional observable scenarios>
- **Validation and evidence:**
  - `planned` — `<exact command/action>` — expected: `<evidence>` — owner: `<owner>`
  - `run` — `<exact command/action and concise observed result>` — `<revision/limitations>`
- **Context and references:** E#, D#, `<path>`, `<docs or contract>`
- **Execution readiness:** <applicable assumptions, runtime setup, safety/privacy,
  review focus, reasoning, and required checks; omissions need a reason>
- **Skills:** <verified skill ID, availability evidence, priority, why/when;
  Find Skills availability and actual consent decision, if relevant>
- **Gherkin specification:** <complete Feature/Scenario document mapped to S#,
  or inapplicability with reason and alternative acceptance check>

Repeat the package block for `P2`, `P3`, and so on only when a distinct,
independently reviewable behavior slice, ownership boundary, integration/release
boundary, or valuable discovery outcome requires it. One package is valid.

Separate validation work only when it has a distinct integration or release
boundary or an independently valuable outcome; do not create a test-only or
one-file chore package.

### Integrated package (add when cross-layer proof or coordination is needed)

- **Outcome:** <end-to-end behavior across the affected owners>
- **Owner:** <integration or release owner>
- **Allowed paths:** `<test, fixture, or integration paths>`
- **Prerequisites:** <all causal package IDs>
- **Acceptance scenarios:** <consumer-visible flow, mixed-version, rollback, or recovery case>
- **Validation and evidence:** <exact integrated command/action, expected evidence, and status>
- **Context and references:** <contracts, runtime prerequisites, and prior package evidence>

## Requirement-to-proof index

| Requirement | Acceptance scenario(s) | Package | Proof and expected evidence | Status |
| --- | --- | --- | --- | --- |
| R1 | S1 | P1 | `<exact command/action>` — `<expected result>` | planned / run / blocked |

## Dependency graph and prospective tasking mapping

**Causal dependency graph:** `<P1 -> P2 -> ...>` or `<P1>` when one package is sufficient

**Acyclicity check:** <why every edge is causal and no cycle exists>

**Existing epic context:** <epic supplied by the request or existing context, if any>

**Proposed epic goal/grouping:** <one measurable goal for the later TaskForge
epic when ordinary tasks are proposed; resolve this grouping during later
tasking if no existing epic context was supplied. A single package still needs
this grouping.>

**Workspace/epic identity:** <supplied identity or `pending tasking`; do not use
MCP lookup or create an epic merely to plan>

**Epic execution and acceptance:** <integrated checklist, execution details and
skills for the epic itself; check child paths against epic scope>

**Epic Gherkin specification:** <integrated Feature/Scenario document, or
inapplicability with reason; do not duplicate every child scenario>

| Package | Epic mapping | Prospective task outcome | Relation | Dependencies carried forward | Acceptance and proof carried forward |
| --- | --- | --- | --- | --- | --- |
| P1 | supplied epic context / proposed grouping | <task-sized outcome> | one task / combined with P# / discovery | <real prerequisites> | S#; `<proof>` |

This mapping contains no API payloads, TaskForge ticket IDs, record writes,
timeline order, or orphan ordinary tasks. Unknown workspace or epic identity is
pending tasking, not a planning blocker.

## Integrated validation

| Check | Target and prerequisites | Expected evidence | Status | Limitation or owner |
| --- | --- | --- | --- | --- |
| `<exact command/action>` | `<target>`; `<runtime prerequisite>` | `<pass signal or observed result>` | planned / run / blocked | `<reason or owner>` |

Include cross-package, public-contract, migration, auth/tenant, failure, browser,
or operator checks when the change requires them. Child package success does not
prove integration.

## Rollout, monitoring, and rollback

- **Applicability:** <risk assessment; state why this is N/A for low-risk work>
- **Consumer/deployment order:** <order required by compatibility, if any>
- **Mixed-version behavior:** <supported behavior or release gate>
- **Feature flag/staged exposure:** <default, scope, and removal condition, if any>
- **Monitoring and operator:** <signals, alerts, and owner>
- **Rollback trigger:** <observable condition>
- **Rollback action:** <reversible action, data recovery prerequisite, and owner>
- **Release gates:** <evidence or human decision still required>

## Unknowns, readiness, and handoff

| Unknown or open decision | Owner | Impact | Resolution or evidence needed | Blocks implementation? | Blocks release? |
| --- | --- | --- | --- | --- | --- |
| U1: <question> | <person/role> | <what changes> | `<exact check or decision>` | yes / no | yes / no |

**Pending planning questions:** `<Q#>` — `<question>` — owner: `<person/role>` —
impact: `<what changes>` — resolution: `<actual user answer or exact evidence>`.
Dependent work waits for the answer; independent investigation may continue.

- **Implementation readiness:** <implementation-ready, discovery-required, or blocked and why>
- **Release readiness:** <release-ready, release-evidence-needed, or release-decision-needed and why>
- **Next permitted action:** <later tasking, bounded discovery, implementation, or named decision>

## Completeness challenge

- [ ] Every requirement has at least one work package, acceptance scenario, and proof.
- [ ] Every package has one accountable owner, bounded paths, a cohesive outcome, real prerequisites, and independently reviewable behavior.
- [ ] Each behavior package includes implementation, directly relevant tests, and necessary docs/setup by default; validation is separate only for a distinct integration/release boundary or independently valuable outcome.
- [ ] Dependencies are causal and acyclic; preferred order is not represented as a blocker.
- [ ] Each responsibility has one owner; no package duplicates another package's behavior.
- [ ] Current owners, consumers, reused patterns, interfaces, data semantics, and applicable failure paths are evidenced.
- [ ] Defect observations and confirmed causes are separate from hypotheses, and each material hypothesis has a resolving check or bounded discovery package.
- [ ] No unresolved material product or architecture decision is hidden as an assumption.
- [ ] Supplied product constraints remain settled decisions unless current evidence conflicts; conflicts have evidence, impact, and a decision owner.
- [ ] Answered planning questions have concise provenance and are carried forward as constraints or decisions; pending questions have an owner, impact, and resolution, and block only dependent work.
- [ ] Claims that a file, symbol, consumer, or owner is absent identify the inspected search scope and evidence; partial searches are reported as unknown.
- [ ] Any conflict between current evidence and a settled decision is surfaced with evidence, impact, and decision owner.
- [ ] Planned checks are distinct from checks actually run; every claimed result has evidence and limitations.
- [ ] Rollout, monitoring, rollback, exclusions, and release decisions are proportional to risk and have owners where applicable.
- [ ] The prospective tasking mapping preserves package outcomes, acceptance, proof, and real dependencies without producing records, payloads, ticket IDs, or timeline order.
- [ ] Every prospective ordinary task maps to supplied epic context or a proposed epic goal/grouping; one-package plans have no orphan-task exception, and missing workspace/epic identity remains pending tasking.

Stop before task creation or implementation.

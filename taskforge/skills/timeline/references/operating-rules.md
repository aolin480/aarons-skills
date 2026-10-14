# Operating rules

Apply each rule only when its action is authorized and in scope. Engineering
planning from supplied or local evidence does not require a TaskForge connection
or ledger writes. Specialist completion boundaries remain binding.

## Core rules

- Resolve the server and workspace from fresh TaskForge evidence. Never guess a
  workspace or mix records from different servers.
- Use the narrowest available tool and explicit fields. Gate programmatic
  reads, trees, and toolset-specific operations on advertised capabilities.
- Use Notes for context, Validation for check results, attachments for durable
  artifacts, and commit references for verified commits.
- Re-read the execution packet when task, blocker, branch, validation, or merge
  evidence may have changed.
- Reuse complete, unchanged canonical reference content already available in the
  same artifact or task context; another agent's read receipt is not your
  content. Do not reread duplicate materialized copies. This never suppresses a
  necessary fresh packet, blocker, branch/head, digest, approval, conflict, or
  correction read.
- Follow [evidence-and-attachments.md](evidence-and-attachments.md)
  for sanitation and [auth-browser-and-identity.md](auth-browser-and-identity.md)
  for API-key and browser-session secrecy.

## MCP Schema Cheatsheet (Avoid Parameter Amnesia)

- `get_task`: `{ id }` (use the task ID, not `ticketNumber` or `taskId`).
- `get_task_execution_packet`: `{ workspace, id }` or `{ workspace, ticketNumber }` (never `taskId`).
- `update_task`: `{ workspace, id, payload: { ... } }` (never pass top-level update fields outside `payload`; `validationPlan[].kind` must be one of `test | lint | build | doctor | browser | debugger | review | manual`).
- `append_task_commit_reference`: `{ workspace, id, commitHash, branchName }` (never pass `commit` or `branch`).
- `append_task_validation`: `{ workspace, id, payload: { tool, status, summary, command, details, target, actor } }` (always wrap fields in `payload: { ... }`; `status` is `passed | failed | warning | skipped` and `summary` is `<= 280` chars).
- `prepare_task_branch`: `{ workspace, id, projectPath, apply }` (always include `workspace`; preparation has no `approved` field).
- `merge_task_branch`: `{ workspace, id, projectPath, targetBranch, apply, approved }` (always include `workspace`; `apply: true` requires `approved: true` and current merge authorization).


## Authorized continuation

An activated run continues scoped implementation, validation, correction,
commit evidence, and clean standing-approved integration without asking for
permission again. Return to the latest integration branch and select the next
eligible record after each verified completion. Planning, tasking, selection,
and ordinary implementation retain their own stop boundaries.

Reuse existing approval within its exact ticket, target, and stated candidate
scope until the user changes or revokes it. A changed candidate invalidates
only the affected checks and any approval explicitly bound to that candidate.
Never turn internal standing approval into final-primary approval. At a human
boundary, ask once and stop; generic continuation is not the missing approval.

## Harness portability

Canonical TaskForge workflows define intent, authority, evidence, and completion
boundaries independently of any agent harness. Express coordination in terms of
capabilities such as coordinator, worker, reviewer, native question mechanism,
bounded wait or event notification, and read-only execution when needed.

Do not make a particular provider, model family, role name, tool name, sandbox
flag, or dispatch API a prerequisite for an ordinary TaskForge workflow.
Host-specific adapters may add those mechanics only behind their own explicit
opt-in and capability guard. If an adapter is unavailable or does not match the
current host, continue with the ordinary workflow when the requested action is
otherwise supported.

## Agent orchestration is opt-in

TaskForge is a ledger by default. Do not select, preflight, require, or spawn
repository-owned roles unless the current user explicitly opts in for the
current task or epic. Prior
opt-in, role files, `agentExecution`, host eligibility, and TaskForge metadata
are not confirmation.

Without opt-in, use the ordinary workflow. Do not load attended-routing rules,
append adapter-specific dispatch evidence, or treat absent repository-owned
roles as a blocker. Keep any active orchestrator in control unless the user asks
TaskForge to replace or supplement it.
Do not ask the user to enable roles merely because the host is eligible.

After opt-in, classify the host only through first-party runtime identity or
native harness capabilities. Select a repository-owned host adapter only when
that adapter explicitly supports the current host and its required capabilities
are present. Unsupported or unknown hosts use the ordinary workflow. Never
infer the host from actor data, credentials, source metadata, branding, or
role-file presence.

## Reasoning preflight

Before substantive TaskForge work, show this advisory once for the invocation
or newly selected task, then continue:

```text
Reasoning advisory: this is <work-mode> work, so <level> reasoning is sufficient; the active setting remains unchanged.
```

Default to `low` for `bounded_execution` and `planning`, `high` for
`investigation`, and `extra-high` for `architecture`. A selected task's
`agentExecution.reasoning` overrides these defaults for that task only. A
host-specific routing adapter may impose its own runtime model or effort
requirements only after explicit opt-in and successful adapter selection. Those
adapter settings do not redefine the ordinary TaskForge reasoning contract.

Do not inherit guidance from an epic, initiative, dependency, or neighboring
ticket. Reclassify only when the work mode changes. TaskForge cannot change the
active model or effort; a different setting needs user action or a dispatcher.
Compiler failures, expected tests, lint findings, and local bugs remain bounded
execution while the approved design holds. Escalate only for a material
cross-layer, data-model, security, authorization, destructive, irreversible,
or requirements conflict. Record the unresolved fork and decision owner in a
Note.

## Execution efficiency

- Let the owner of a long-running process own its wait cycle. After a
  coordinator confirms the process is healthy, use the host's longest practical
  wait or event mechanism and wake the coordinator only for completion, a
  blocker, or a meaningful state change. Avoid repeated unchanged status polls.
- Before an expensive validation or quality gate, run the cheapest prerequisites
  that can invalidate it: required local services and runtime inputs, exact
  command/configuration and scope, focused baseline tests or type checks, and a
  supported dry-run or preflight. Do not use the expensive runner as the first
  detector of setup or baseline failures.
- Verify the runner's effective working directory and collected inputs, not
  only its mutation targets or the size of a copied directory. Isolated runs
  must exclude dependency stores, earlier reports, nested worktrees, runtime
  data, and protected files while retaining required build inputs. Keep output
  outside the collected inputs. Preserve failed-run evidence and retry only
  after a demonstrated cause or justified narrowing changes the execution plan.
- Bind validation, review, and quality evidence to the source revision plus the
  relevant configuration, test, and specification inputs. Reuse still-valid
  evidence and rerun only checks whose inputs changed or whose prior result was
  incomplete.
- For uncommitted candidates, record a content digest for the relevant files;
  a shared base or `HEAD` does not identify different working-tree snapshots.
  Record the actual command, working directory, terminal result, and sanitized
  report location. Process launch, an existing output file, or a previous
  successful report does not prove the current check passed.
- Classify a failed check or review finding before editing production source:
  behavior defect, missing test or assertion, equivalent/non-actionable result,
  tooling/configuration failure, or contract decision. Change production
  behavior only when the evidence supports a real defect or approved contract
  change.
- Compare each finding's exact source range and behavior with the baseline
  before calling it new. Keep assertion failures, compiler rejections,
  uncovered cases, timeouts, and runner failures distinct. Live execution alone
  does not prove that a test detects a wrong result or omitted control.
- For parity and query-shaping tests, include discriminating expected results:
  records that must be included and excluded, boundary values, and observable
  failure behavior. Agreement between two adapters or a permissive mock can
  hide the same mistake in both. Assert essential query constraints when the
  test double cannot execute them; avoid assertions on incidental structure.
- When adding a dependency or runtime integration, verify package/workspace
  installation, supported runtime versions, built artifact, and container or
  packaging surface early when applicable.
- For storage or query-engine changes, probe contract-relevant semantic
  differences early, such as regex behavior, null or missing values, collation
  and case handling, ordering or cursor behavior, and transaction/error
  semantics, before broad adapter implementation.
- Before final handoff, remove temporary diagnostics, duplicate compatibility
  paths, dead branches, speculative helpers, and other investigation scaffolding
  that no longer carries required behavior. Preserve the smallest maintainable
  diff that satisfies the contract.

For unattended work, continue reversible steps. Pause only for human authority,
an irreversible action, or an unsafe choice. Preserve supported redispatch
fields when updating an execution contract.

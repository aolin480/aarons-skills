---
name: taskforge-mcp
description: Use when Codex needs to create, search, update, review, or manage attached files on tasks or epics through a TaskForge MCP server. Best for agent task tracking, project intake, epic planning, status changes, task history lookups, notes, dependency linking, task attachments, task trees, epic trees, or converting markdown worklists into structured tickets. Use this skill when the request involves deciding which workspace, system, service, or epic a task belongs to before calling TaskForge MCP tools.
---

# TaskForge MCP

Use this skill to work with a TaskForge MCP server as a structured task ledger.

## Core Workflow

1. Identify the intent:
   `create task`, `create epic`, `search`, `review`, `update`, `status change`, `agent goal`, `history`, `note`, `dependency`, `attachment upload`, `attachment list`, `attachment read`, `attachment delete`, `planning timeline`, `next planned task`, `task tree`, `epic tree`, or `markdown import`.
2. Resolve the location before writing:
   call `list_workspaces`, select the target workspace slug, then choose `system`
   and optional `service` from that workspace record's `systems` and `services`.
3. If the selected workspace record includes `workingDirectory`, treat that
   absolute local path as the preferred cwd for implementation work in that
   workspace. If it exists in the current agent environment and the current
   shell is elsewhere, switch to that directory before editing or running repo
   commands. If it is missing or invalid on this machine, continue with the
   current project directory only when the user or context makes that safe.
4. If the MCP client knows the local project directory:
   call `set_project_context` once before creating or updating related tickets.
   TaskForge will attach that context automatically to create/update/status tools.
5. When authentication, actor identity, or scope coverage is unclear:
   call `get_session_health` before assuming the MCP credential has the needed
   access. Use it to see the current actor and scopes without exposing the raw
   API key.
6. If the user did not specify a workspace:
   call `list_workspaces` and ask which workspace slug the task belongs to before creating it.
7. If the user gave a system or service but not a workspace:
   ask for the workspace instead of guessing.
8. Before creating ordinary tasks:
   resolve the target epic. If no epic exists or the user has not chosen one,
   create or select an epic first.
9. Before creating more than one task:
   identify the dependency graph. Decide which tasks are true prerequisites,
   which tasks can run in parallel, and which tasks are only timeline-ordered
   for convenience. Record true prerequisites as blockers after task creation
   if the create tool cannot attach them directly.
10. Before creating agent-executable tasks:
   write a durable `goal` that can stand alone without chat history. Include the
   intended scope, explicit exclusions, prerequisite assumptions, validation
   expectations, and what evidence should be recorded.
11. Add `agentExecution` only when the task needs structured execution guidance
   beyond the goal and acceptance criteria. Keep it optional for legacy/simple
   tasks.
12. When filling `agentExecution.recommendedSkills`, use stable skill names and
    explain exactly when the agent should use each one. If the user asks to
    discover or attach useful skills and the right skills are not already known,
    use the `$find-skills` skill before writing the task.
13. After location, project context, epic, blocker intent, and agent guidance are clear:
   call the appropriate TaskForge MCP tool with explicit structured fields.

## Human-Owned Agent Identity

TaskForge agents are users for authentication and audit history, but each agent
belongs to a human user. Treat the authenticated MCP agent as the human owner's
sub-user, not as an independent root account.

- Each developer should register a separate TaskForge agent under their own
  human account and configure that agent's one-time secret as
  `TASKFORGE_API_KEY`. Do not share one agent credential across a team.
- Tickets created through the MCP server are attributed to the authenticated
  agent. TaskForge's `Mine` board scope includes tickets created by the signed-in
  human and by that human's owned agents, including disabled historical agents.
- Do not infer creator-family ownership from task assignment, source labels,
  display names, or usernames. The API owns the human-agent relationship.
- `list_tasks` and `search_tasks` are team-wide ledger queries. They do not
  implement the board's `Mine` scope. Use the web board or its snapshot contract
  when the user explicitly needs the `All` versus `Mine` Kanban view.

## Default-Deny API Authorization Contract

The NestJS API owns authentication and permission decisions. The MCP server is
an authenticated API client; it must not copy role, scope, route, or business
authorization rules into MCP tool handlers.

- When `TASKFORGE_API_KEY` is configured, the MCP HTTP client sends it only in
  the TaskForge agent-auth header. Never place it in tool output, URLs, notes,
  validations, screenshots, or error details.
- Treat `get_session_health` as the safe preflight for actor and scope checks.
  A configured key is not proof that the current agent has every permission.
- Read tools normally require `tasks:read`. Task and planning mutations normally
  require `tasks:write`. Administrative task lifecycle operations require
  `tasks:admin`. Task scopes include the workspace-read permission needed by
  workspace discovery; they do not grant user, workspace-management, or
  settings-management permissions.
- Let the API's declarative authorization metadata and default-deny guard make
  the final decision. Do not add optimistic client-side allowlists, bypasses,
  fallback credentials, or retries with another authentication mode.
- Preserve the API distinction between unauthenticated `401` responses and
  authenticated-but-under-scoped `403` responses. Do not convert either into a
  successful empty result. `get_session_health` is the intentional exception:
  it reports a failed identity lookup as `authenticated: false` without exposing
  credential or response details.
- `/auth/session` and `/auth/agent-browser-sessions` are specialized API
  authentication routes. Their explicit guard exception does not make them
  public: the route owner still validates the supplied agent credential.

After changing an API route, permission annotation, authentication contract, or
MCP API mapping, run MCP tests and build, then exercise one allowed request and
representative `401` and `403` paths. Rebuild and reconnect the MCP client before
judging the live contract so a stale process does not mask the current behavior.

## Agent Browser Session Workflow

Before browser automation opens a protected TaskForge page:

1. Call `get_session_health`. Confirm the agent is authenticated and inspect
   `webBaseUrl` plus `webBaseUrlConfigured` without reading secret files.
2. Call `create_agent_browser_session` with the original same-origin path in
   `redirectPath`, including its query string when relevant. If it is omitted,
   the handoff lands on the generic TaskForge root `/`, not a workspace board.
3. Navigate the same browser context to the returned `handoffUrl`. Do not put
   `TASKFORGE_API_KEY` in a URL and do not record the short-lived session id or
   handoff URL in tickets, logs, screenshots, or validation evidence.
4. Origin precedence is the tool's explicit `webBaseUrl`, then
   `TASKFORGE_WEB_URL`, then `http://127.0.0.1:4411`. Configure
   `TASKFORGE_WEB_URL` when the browser must use another host, such as a LAN
   hostname that owns the browser's remembered session.
5. Do not ask a human to log in until this handoff flow has been attempted. Mint
   a new session when switching browser tools, profiles, or contexts.

`TASKFORGE_AGENT_BROWSER_SESSION_SECRET` belongs only to the TaskForge API
runtime. Never place it in MCP client configuration. The MCP client needs the
agent's `TASKFORGE_API_KEY`, not the API signing secret or a human password.

## Initiative-Aware Cross-Workspace Workflow

Use initiatives for features that span multiple workspaces. An initiative is a
coordination layer, not a workspace replacement: each workspace keeps its own
epics, tasks, plans, branching policy, tools, and validation expectations.

When the user references cross-workspace work:

1. Call `list_initiatives` or `get_initiative` to resolve the `INIT-*` record.
2. Call `get_initiative_execution_packet` before choosing a workspace task. Use
   it as the canonical cross-workspace execution contract: initiative title,
   cross-workspace goal, linked epics, participating workspaces,
   readiness/tooling notes, workspace-owned plans, and open blockers.
3. If starting from a task, call `get_task_execution_packet`; modern packets
   include `initiativeContext` when the task belongs to a linked initiative epic.
4. For full initiative work, treat the initiative title and cross-workspace
   goal as the top-level agent context and completion objective. Mirror the
   initiative goal into the agent's active goal/work plan when the runtime
   supports it, and keep it visible throughout planning, workspace selection,
   validation, and final handoff.
5. When working a linked epic or child task inside an initiative, use the task or
   epic `agentGoal`/`goal` as the immediate implementation objective, but keep
   the initiative title and goal as parent context. Workspace-local work must
   stay aligned with the broader cross-workspace outcome.
6. Initiatives are epic-first. Link existing workspace epics with
   `link_initiative_epic`. Do not link individual tasks directly to an
   initiative.
7. Agents may create an initiative with `create_initiative` when the execution
   context establishes a clear title and cross-workspace goal. Create the
   initiative first, then link existing workspace epics with
   `link_initiative_epic`. Agents may update the cross-workspace goal with
   `update_initiative_goal` when the current goal is missing, placeholder text,
   or clearly stale and the intended replacement is known from the active
   execution context. Agents may
   also update workspace readiness and non-secret tooling notes with
   `update_initiative_readiness`. Do not edit initiative title, status,
   ownership, or archival state unless a human/admin explicitly manages those
   fields through an approved UI/API path.
8. Cross-workspace blockers are real blockers. Treat dependencies from another
   workspace exactly like local dependencies: they must be complete before
   dependent work is executable.
9. Before editing code for any linked epic or task, write a local initiative
   alignment checklist from the initiative packet. Keep it short, but include:
   the initiative title, initiative goal in one sentence, the current
   workspace's responsibility, sibling workspace dependencies, cross-workspace
   validation needed, and the evidence that must be written back to TaskForge.
10. Use the initiative to constrain code scope, not to expand it. Implement only
   the current workspace/task boundary, preserve contracts that sibling
   workspaces depend on, and avoid speculative helpers or broad refactors unless
   the initiative packet or task goal explicitly requires them.
11. Final handoffs for initiative-linked work must name both the workspace-local
    result and the cross-workspace impact. Mention linked blockers that remain,
    validation that proves the initiative contract, and any readiness notes that
    should be updated with `update_initiative_readiness`.

## Initiative Execution Packet Intake Rule

Use this rule whenever an agent takes on a full TaskForge initiative, plans
initiative execution, or coordinates work across more than one linked workspace.

1. Call `get_initiative_execution_packet` before selecting work, creating
   workspace tasks, changing readiness, or relying on chat history.
2. Treat `packet.initiative.title` and `packet.initiative.goal` as the
   initiative-level execution contract. The title identifies the initiative; the
   goal defines the cross-workspace outcome the agent is trying to complete.
3. If the runtime supports an explicit goal feature, mirror the initiative goal
   into that runtime before long-running initiative work. If it does not, restate
   the initiative title and goal in the local plan before taking action.
4. Preserve and use the packet's linked epics, plans, participants,
   readiness/tooling notes, and blockers when choosing execution order.
5. Before working any linked epic, call `get_task_execution_packet` for that
   epic and reconcile it with the initiative packet. The initiative goal remains
   the parent cross-workspace objective; the epic `agentGoal` and
   `agentExecution` define that workspace's release context.
6. Before working any child task, call `get_task_execution_packet` for the task
   and reconcile initiative, epic, and task context. The task packet defines the
   immediate implementation work, but it must not exceed or contradict the
   initiative cross-workspace goal.
7. If initiative blockers are open, stale, or unclear, stop and report the
   blocker chain before treating the initiative as executable.
8. If the initiative goal is missing, placeholder text, or clearly stale, update
   it with `update_initiative_goal` when the intended replacement is clear from
   current evidence. Otherwise ask one targeted question before proceeding.
9. Final initiative handoffs must explain progress against the initiative title
   and cross-workspace goal, not only individual task completion.

## Single-Workspace Initiative TaskForge Branch Workflow (Explicit Opt-In Only)

Use this workflow when one initiative contains one or more epics and every
linked epic belongs to exactly one TaskForge workspace whose `workingDirectory`
is the active local project path. It extends the Epic TaskForge Branch Workflow
with a rolling initiative integration branch:

```text
taskforge/task/<ticket>-<slug> -> taskforge/epic-<number>
taskforge/epic-<number> -> taskforge/init-<number>
taskforge/init-<number> -> <workspace.masterBranch>
```

Do not use this workflow for a cross-workspace initiative, for epics spread
across multiple repositories or working directories, or when TaskForge cannot
prove the single workspace and project-path match. Use the Initiative-Aware
Cross-Workspace Workflow in those cases.

Activate it only when the user explicitly asks to take on or complete an
initiative using the Initiative TaskForge Branch Workflow or explicitly asks
for a `taskforge/init-<number>` integration branch. Examples include:

- "Take on INIT-9 using the Initiative TaskForge Branch Workflow."
- "Complete INIT-9 through a taskforge/init-9 branch."

Do not infer activation from an initiative link, a single linked epic, or the
fact that all current epics happen to use one workspace.

Explicit activation is standing approval for clean, validated task-to-epic and
epic-to-initiative merges performed during that initiative run. Always run the
dry-run merge preflight first and send `approved: true` only after it succeeds.
Standing approval never covers the final initiative-to-primary merge, merge
conflict resolution, rebasing, force-pushing, destructive cleanup, or remote
branch deletion.

### Initiative Bootstrap

1. Resolve the initiative with `get_initiative_execution_packet`, resolve its
   one workspace with `list_workspaces`, and treat the initiative title and goal
   as the top-level execution contract.
2. Confirm the initiative is `active`, has at least one linked epic, every
   linked epic belongs to that workspace, the workspace has `strictBranching`
   enabled with a configured `masterBranch`, and the active project path exactly
   matches the workspace `workingDirectory`. Stop if any eligibility check
   fails; do not approximate repository identity from a remote URL.
3. Confirm the repository is clean and no merge, rebase, cherry-pick, or revert
   is active. Synchronize the configured primary branch using the Primary
   Branch Sync rules. Stop for human direction if it has diverged.
4. From the synchronized primary branch, call `prepare_initiative_branch` with
   the initiative reference, workspace, project path when needed, and
   `apply: true`. Confirm the source is the primary branch and the result records
   `taskforge/init-<number>` as the initiative `taskBranch`.
5. Build a serial epic order from initiative plans, explicit blockers, and
   readiness. Do not substitute ticket-number order for dependency order.

### Serial Epic Loop

Work exactly one linked epic at a time. Each new epic branch starts from the
latest validated `taskforge/init-<number>` branch, which must already contain
all prior completed epics.

For each epic:

1. Return to `taskforge/init-<number>`, confirm it is clean, and refresh the
   initiative and epic execution packets. Confirm the epic is linked to the
   initiative, belongs to the eligible workspace, and has no unfinished
   blocker.
2. From the initiative branch, call `prepare_task_branch` for the epic with
   `apply: true`. Confirm the result records `taskforge/epic-<number>` as the
   epic `taskBranch` and `taskforge/init-<number>` as its `baseBranch`.
3. Execute that epic's child tasks serially using the Epic TaskForge Branch
   Workflow. Every child uses
   `taskforge/task/<ticket-number>-<slugified-title>`, branches from the current
   epic branch, validates fully, moves to `review`, preflights its merge, merges
   cleanly into the epic branch under standing initiative approval, and then
   moves to `done`.
4. After all non-archived children are `done` or `finalized`, run and record the
   epic-level validation on `taskforge/epic-<number>`, then move the epic to
   `review`.
5. Call `merge_task_branch` for the epic with `apply: false` and
   `targetBranch: "taskforge/init-<number>"`. Stop on conflicts, stale branch
   context, source/target mismatch, or incomplete validation.
6. After clean preflight, call the same merge with `apply: true`,
   `approved: true`, and the same target. Explicit initiative activation is the
   approval for this clean epic-to-initiative merge; do not ask separately.
7. Confirm the merge commit is present on the initiative branch and the epic's
   persisted branch context records the initiative target. Then move the epic
   from `review` to `done`. The strict completion gate accepts recorded,
   SHA-backed epic merge evidence into the matching initiative branch.
8. Delete a local epic or task branch only when Git proves it fully merged into
   its intended integration target. Use `git branch -d`, never `-D`; never
   delete a remote branch without explicit approval.
9. Re-read initiative plans, epic statuses, and blockers. Return to the updated
   initiative branch and repeat for the next actionable epic.

Do not create all epic branches at bootstrap. Creating each epic branch only
when its turn begins ensures it starts from the latest initiative integration
state.

### Initiative Review and Final Merge

Initiative statuses are `active`, `review`, `done`, and `archived`:

- `active`: initiative execution is underway.
- `review`: every linked epic is `done` or `finalized`, initiative-level
  validation is recorded, and the complete implementation is waiting for human
  review on `taskforge/init-<number>`.
- `done`: the user explicitly approved the final merge and TaskForge recorded
  the initiative branch merged into the workspace's configured primary branch.
- `archived`: administrative removal from active work; it is not a synonym for
  completion.

When all linked epics are integrated:

1. Run the initiative-level validation on `taskforge/init-<number>`, including
   cross-epic tests and practical smoke coverage. Record the evidence and any
   intentionally archived or superseded work.
2. Call `update_initiative_status` with `status: "review"`. TaskForge rejects
   this transition when there are no linked epics, a linked epic is unresolved,
   or any linked epic is not `done` or `finalized`.
3. Give the user an implementation summary plus concrete manual test
   instructions covering the full initiative. Leave the initiative branch
   unmerged and ask for explicit approval naming the initiative and configured
   primary target.
4. After the user approves, call `merge_initiative_branch` with `apply: false`
   to preflight the exact `taskforge/init-<number>` to
   `<workspace.masterBranch>` merge.
5. If preflight is clean, call the same tool with `apply: true` and
   `approved: true`. Confirm the returned merge SHA and persisted branch context
   record the initiative source and primary target. The tool then moves the
   initiative from `review` to `done`.
6. If approval is absent or any source, target, ancestry, validation, or branch
   context check disagrees, keep the initiative in `review` and stop. Never
   treat workflow activation, elapsed time, "continue", or "finish" as final
   merge approval.

## Source Shape Rule

Always send `source` as an object, never as a string.

Some MCP clients summarize nested schemas poorly. If a tool view makes `source`
look ambiguous, use this object shape:

```json
{
  "createdBy": "mcp-agent",
  "agentName": "Assistant",
  "conversationId": "session-123"
}
```

For agent-created work, modern TaskForge MCP servers default missing
`agentName` to `Agent` and missing `conversationId` to `taskforge-mcp`.
Provide real values when available. Optional `repo` and `branch` values must be
provided together.

## Note Markdown Rule

When writing task notes or validation summaries/details through
`append_task_note` or `append_task_validation`, format code-like text with
TaskForge's supported code-markup subset so the UI can render it as code. This
is not full Markdown.

- Treat commands, code snippets, JSON, logs, diffs, stack traces, config, shell
  output, validation evidence, and environment-variable examples as code, not
  prose.
- Prefer fenced triple-backtick code blocks for any complete command, command
  sequence, multi-line snippet, structured output, validation evidence, or text
  the user may need to copy.
- Use single backticks only for short inline code references such as filenames,
  identifiers, environment variable names, API paths, ticket payload keys, and
  short literals inside a sentence.
- Use single-backtick inline code only when the code itself does not contain
  backticks. Escape literal prose backticks as `\``.
- Add a language label to fenced blocks when it is known, for example
  ` ```ts `, ` ```bash `, ` ```json `, or ` ```text `.
- If the code itself contains backticks or Markdown fence examples, prefer a
  ` ```text ` fenced block and keep the content literal rather than relying on
  nested or multi-backtick Markdown forms.
- Put opening and closing triple-backtick fences on their own lines, with no
  more than three leading spaces. Do not use quoted or nested Markdown fence
  variants.
- Do not paste raw multi-line code into prose notes without fences.
- Keep surrounding explanation concise; the code block should make the code
  boundary obvious to human readers and UI renderers.

## Workspace Rule

Treat `workspace` as required for creation flows.
Use workspace slugs managed by the TaskForge API (`/workspaces`), not static enums.

Do not infer a workspace from the task title or from a person’s name.
Do not invent new workspace, system, or service values.
Use only values that the connected TaskForge server accepts.

Workspace services are workspace-defined slug values. The default starter
services are `web`, `api`, `mcp`, `db`, `docs`, `infra`, and `other`, but a
workspace may define custom services such as `worker_queue` or
`browser-agent`. Custom services are valid only after they appear in that
workspace record's `services` array.

Workspace records may include `workingDirectory`. This is an advisory absolute
local path for the agent environment, not remote repository identity. Prefer it
as the shell cwd for implementation, tests, Git commands, project-context
capture, and browser validation when it exists on the current machine. The
GitHub repository metadata remains optional and is used for links/commit
references; do not infer local cwd from GitHub URL when `workingDirectory` is
available.

Before create/search flows that include `workspace`, resolve or verify the slug:

1. Call `list_workspaces` (set `includeArchived` when relevant).
2. Select the matching slug from the response.
3. Use that workspace record's `systems` and `services` arrays as the valid
   create values for `system` and `service`.
4. If a needed custom service is missing, ask an admin to add it to the
   workspace first; do not submit it only in the task payload.
5. Use `workingDirectory` as the preferred cwd when it is present and local to
   the current agent environment.
6. Check the workspace record's branching policy before starting implementation.
7. Use that slug in the tool payload.

## Strict Branching Rule

Workspace records may include:

- `strictBranching`: boolean
- `masterBranch`: string or null

When `strictBranching` is `true`, treat `masterBranch` as the configured
primary branch for implementation work in that workspace. Strict branching
protects that configured branch only. Other branches, including
`taskforge/epic-<number>` branches, are integration or staging branches unless
the workspace record names one of them as `masterBranch`.

Throughout this skill, `primary branch` means the selected TaskForge workspace's
registered `masterBranch` value returned by `list_workspaces`. Never infer it
from the Git remote default, the current checkout, a repository convention, or
a hard-coded `main` or `master`. If the workspace has no registered
`masterBranch` when a workflow requires a primary branch, stop and ask the user
or a workspace admin to configure or identify it before creating branches or
merging.

Before taking on or working on a task:

1. Confirm the local repository is clean. Unstaged changes, staged changes,
   untracked files, or merge/rebase/cherry-pick/revert state must block start.
2. Confirm the local project context is on an allowed start branch before
   changing ticket status, setting a runtime goal, calling
   `prepare_task_branch`, or editing files. Allowed start branches are only the
   configured primary branch, a `taskforge/epic-*` branch selected for active
   epic integration, or the matching `taskforge/init-*` branch while preparing
   a linked epic in an explicitly activated single-workspace initiative. A
   legacy `release/epic-*` branch is also allowed when the legacy-epic rule
   below applies.
3. If the current branch is anything else, stop and ask the user to switch to
   the configured primary branch or the intended `taskforge/epic-*` branch. Do
   not start from an arbitrary feature, bugfix, stale task, or personal branch.
4. Call `prepare_task_branch` for the selected task before modifying code.
5. Create or switch to a task branch before modifying code.
6. Name the task branch as `taskforge/task/<ticket-number>-<slugified-title>`.

Use lowercase hyphenated title words and remove special characters from the
title slug. Keep all TaskForge-generated task branches under `taskforge/task/`,
regardless of task type.

### Legacy Epic Branch Rule

The TaskForge branch-prefix cutover is effective 2026-07-15. New epics must use
`taskforge/epic-<number>`, and new tasks must use
`taskforge/task/<ticket-number>-<slugified-title>`.

An epic created before the cutover is legacy when its persisted
`branchContext.taskBranch` is `release/epic-<number>`, or when the existing
local integration branch is the matching `release/epic-<number>` branch and no
new TaskForge branch has been recorded. When branch context is absent, use Git
branch evidence to identify the legacy source. Do not infer legacy status from
the current date alone.

For a legacy epic:

1. Continue using its existing `release/epic-<number>` branch for child-task
   bases, child merges, epic completion checks, and the final merge into the
   configured primary branch.
2. Do not rename the branch, create a parallel `taskforge/epic-*` branch, or
   rewrite historical `branchContext` automatically.
3. Preserve the legacy branch name in returned merge results and persisted
   context so the historical workflow remains auditable.
4. If both legacy and new epic branches exist and persisted context does not
   identify the source, stop and ask for human direction before merging.

This compatibility rule is temporary migration behavior. It does not authorize
new work to create or extend `release/epic-*` branches.

Existing non-epic task branches recorded before the cutover, including
`feature/<ticket>-<slug>` and `bugfix/<ticket>-<slug>`, remain valid for their
existing task context. Preserve the persisted branch name for merges and
completion checks; generate `taskforge/task/<ticket>-<slug>` only when a new
TaskForge task branch is needed.

Agents do not move implementation work directly from `in_progress` to `done`.
When the agent finishes the requested work and records the required validation,
move the ticket to `review` and stop. Tell the user: "The task has been moved to
In Review. No further agent action is needed." Do not ask for merge approval,
do not run merge preflight, and do not continue the ticket after moving it to
`review`.

Exception: when the user starts an explicit epic execution goal, agents may run
the Epic TaskForge Branch Workflow below instead of stopping at `review` for each child
task.

Exception: when the user explicitly activates the Single-Workspace Initiative
TaskForge Branch Workflow, agents may complete clean task-to-epic and
epic-to-initiative merges under its standing approval. The final
initiative-to-primary merge still requires separate explicit user approval.

Allowed completion transitions:

- `in_progress` -> `review` when implementation and validation are complete.
- `in_progress` -> `blocked` when a real blocker prevents completion.
- `review` -> `done` only when the user or TaskForge explicitly asks to mark a
  reviewed ticket complete.
- `blocked` -> `backlog`, `ready`, or `review` only when a human or TaskForge
  explicitly unblocks the ticket.

Disallowed agent transition:

- `in_progress` -> `done`
- `blocked` -> `done`

### Task Commit Message Rule

Use this rule whenever an agent commits code, docs, tests, config, or evidence
while working a TaskForge task, epic, or initiative. The commit message should
be useful history, not just a structured label.

Commit messages must be self-contained and repo-native:

1. Inspect the local repository signals before writing the message:
   - `git status --short`
   - `git branch --show-current`
   - `git log --no-merges --format=%s -n 3`
   - relevant commit hooks such as `.husky/`, Lefthook, `.pre-commit-config.yaml`,
     `.git/hooks/`, and commitlint config when present
2. Follow the repository's enforced subject shape first. If local history or
   hooks require `type(scope): ...`, a ticket number, a hyphen after the ticket,
   sentence case, or a specific scope list, satisfy that convention.
3. Prefer a long-form commit message by default:
   - a concise subject that names the intent or outcome
   - a short plain-language body that explains why the change exists, what bug
     or constraint it handles, what rollout/testing concern matters, or why the
     grouped files belong together
4. Skip the body only for truly trivial changes where the subject already
   carries the full reason, such as a typo-only docs edit or local ignore-rule
   cleanup.
5. Write like a developer explaining the change to a teammate. Keep the body
   compact, direct, and useful six months later.

Good subjects name the outcome:

```text
fix(auth): Keep return URL after login
feat(tasks): Require project context before task branch prep
docs(mcp): Document agent browser session handoff
```

Weak subjects only narrate mechanics:

```text
fix(auth): Update middleware
feat(tasks): Add fields
docs(mcp): Change instructions
```

Use the body for context the diff cannot show. Do not restate the file list or
describe every patch detail.

Preferred body shape:

```text
fix(auth): Keep return URL after login

Users were losing the original destination when the session expired in a
protected route. Keep that URL through login so they land where they started.
```

For larger commits, two short body paragraphs are acceptable when they explain
different parts of the reason, risk, or validation context. Avoid corporate or
over-polished language. Prefer direct phrasing such as `keeps`, `uses`, `fixes`,
`blocks`, `skips`, `runs`, `checks`, and `safe to retry`.

Avoid vague activity-first subjects unless the rest of the message makes the
outcome clear:

- `update`
- `change`
- `finalize`
- `share`
- `add`
- `adjust`
- `clean up`

When creating the commit, pass the subject and body as separate `-m` arguments:

```bash
git commit -m "fix(auth): Keep return URL after login" \
  -m "Users were losing the original destination when the session expired in a protected route. Keep that URL through login so they land where they started."
```

For TaskForge task branches, include the ticket number in the subject when the
repository history or hooks use ticket references. Do not invent ticket prefixes
or scopes that the repository does not use. If the branch name, task ticket, and
local commit history disagree about the ticket format, prefer hook enforcement;
otherwise prefer the TaskForge ticket for the active task.

Before committing, group changes by behavior and review value. Keep unrelated
work out of the commit even if it is already present in the worktree. If one
file contains separate concerns and the context is clear enough to split them,
use `git add -p` or `git add -e` rather than committing the whole file for
convenience. If splitting would create a broken or misleading intermediate
state, keep the commit whole and explain that in the final handoff.

After committing task work, call `append_task_commit_reference` with the full
40-character commit hash, the branch name when available, and the relevant
TaskForge task reference.

### Epic TaskForge Branch Workflow (Explicit Opt-In Only)

This workflow completes an entire epic through a rolling TaskForge integration branch. It is
valid for feature, bug, refactor, test, documentation, infrastructure, or mixed
epics, but it is never inferred from the epic's type.

In this workflow, `primary branch` always means the epic workspace's registered
`masterBranch` from the current `list_workspaces` response. Do not substitute
Git's default branch, the currently checked-out branch, `main`, or `master`.

Activate it only when the user explicitly asks to execute or complete the
epic's child tasks as one epic goal, or explicitly asks to use a
`taskforge/epic-<number>` branch. Examples include:

- "Complete EPIC-35 using the Epic TaskForge Branch Workflow."
- "Work through all tasks in EPIC-35 and merge each one into its TaskForge branch."
- "Take on EPIC-35 as an epic goal."

Do not activate it merely because a task belongs to an epic, the user asks to
create or plan an epic, the user asks to work one child task, or an agent notices
that several child tasks are ready. In those cases, use the ordinary single-task
workflow and stop at `review`.

Explicit activation is standing approval only for clean child-task merges into
the matching `taskforge/epic-<number>` branch during that epic run. A TaskForge
integration branch is not the protected primary branch, unless the
workspace configuration explicitly names it as `masterBranch`.

#### Epic Bootstrap

1. Resolve the workspace, epic ticket number, configured primary branch,
   project context, active epic plan, child task list, and epic blockers. Stop if
   the epic is archived, finalized, blocked, or has an unfinished blocker.
2. Confirm the repository is clean and no merge, rebase, cherry-pick, or revert
   is in progress. Synchronize the configured primary branch using the Primary
   Branch Sync rules below. If it has diverged, stop for human direction.
3. Create or select the lowercase TaskForge integration branch
   `taskforge/epic-<number>` from the synchronized primary branch, for example
   `taskforge/epic-35`. Never create it from a child task branch, stale feature
   branch, or another epic's integration branch.
4. Call `get_task_execution_packet` for the epic and treat its `agentGoal`,
   acceptance criteria, `agentExecution`, blockers, initiative context,
   validation requirements, and safety boundaries as the integration contract.
   Creating or selecting the empty integration branch in step 3 is the only
   exception to the normal rule that execution-packet intake precedes branch
   creation; no implementation or status change may happen before this packet
   is read.
5. Build the child execution order from explicit blockers and the active epic
   plan. Use `get_next_planned_task` when a plan exists. Do not use ticket number
   order as a substitute for dependency or planning order. Resolve archived or
   skipped children before starting and record why they are outside the epic.
6. Move the epic to `in_progress` only after the TaskForge branch, epic packet,
   child order, runtime prerequisites, and blocker state are valid. The MCP
   validates that project context is on the matching TaskForge branch and updates
   the epic without creating or checking out a synthetic `taskforge/task/EPIC-*`
   branch.

#### Serial Child Task Loop

Work exactly one child task at a time. Even when tasks could theoretically run
in parallel, the Epic TaskForge Branch Workflow uses serial task branches so every new
task starts from the complete, validated TaskForge branch produced by the prior
task.

For each child task:

1. Return to `taskforge/epic-<number>` and confirm it is clean and contains all
   previously merged child task commits. Never branch from the previous task
   branch or directly from the primary branch.
2. Call `get_task_execution_packet` for the selected child. Reconcile its goal,
   blockers, scope, paths, prerequisites, validation plan, skills, safety, and
   review focus with the already-loaded epic packet. Stop if the task is blocked
   or any blocker is not `done` or `finalized`.
3. Call `prepare_task_branch` from the current TaskForge integration branch with `workspace`
   and `apply: true`, regardless of whether the task reference uses `id` or
   `ticketNumber`. Confirm the returned and persisted `task.branchContext`
   names the prepared child branch as `taskBranch` and the matching
   `taskforge/epic-<number>` branch as `baseBranch`. If either value is missing or
   disagrees, stop and treat the MCP runtime as stale or incompatible; do not
   patch branch context manually. Only after that check should the agent move
   the child task to `in_progress` and begin implementation. The branch must use
   the normal task branch naming rules; do not implement directly on the
   TaskForge integration branch.
4. Complete only the child task's scope. Commit the work using the Task Commit
   Message Rule and append the full commit reference to the child ticket.
5. Run the complete child validation gate before merge:
   - run every required `agentExecution.validationPlan` item or record an
     explicit skip with a concrete reason
   - run the relevant tests, typecheck, lint, build, doctor, and review gates
     required by the repository and changed stack
   - run practical smoke validation when the behavior can be exercised locally,
     through an API, or in a browser; attach safe screenshots for UI work
   - for Node.js, NestJS, API, MCP, or other backend runtime changes, use the
     `node-inspect-debugger` skill or an equivalent Node inspector workflow to
     launch or attach to the backend, hit at least one relevant breakpoint, and
     inspect safe runtime state through debugger evaluation or its REPL
   - record the exercised runtime path, breakpoint location, observed result,
     and any sanitized debugger evidence with `append_task_validation`
   - when backend breakpoint validation is genuinely not applicable, record a
     skipped validation with the reason; do not silently omit it
6. If implementation or any required validation is incomplete, failing, or
   ambiguous, do not merge and do not mark the child done. Fix the issue within
   scope, move the task to `blocked` for a real external blocker, or stop for
   human direction when product intent or safe recovery is unclear.
7. When the child is complete and validation evidence is recorded, move it from
   `in_progress` to `review`.
8. Run `merge_task_branch` with `apply: false` and
   `targetBranch: "taskforge/epic-<number>"`. If preflight reports a conflict or
   blocked result, stop; standing epic approval does not authorize conflict
   resolution, rebasing, or history rewriting.
9. If preflight is clean, run `merge_task_branch` with `apply: true`,
   `approved: true`, and the same target branch. Do not ask for separate human
   approval for this clean child-to-epic merge; explicit Epic TaskForge Branch
   Workflow activation already grants it.
10. Confirm the task branch commit is present on the TaskForge integration branch. Only then
    move the child from `review` to `done`.
11. Delete the local task branch only when Git proves it is fully merged with
    `git branch --merged taskforge/epic-<number> --list <taskBranch>`. Use
    `git branch -d`, never `git branch -D`, and never delete a remote branch
    without explicit human approval.
12. Re-read the epic plan, task statuses, and blocker graph, select the next
    actionable child, return to the updated TaskForge integration branch, and repeat from
    step 1.

Send `apply` and `approved` as JSON booleans. The MCP server accepts `"true"`
and `"false"` for compatibility with clients that stringify primitive tool
arguments, but agents should prefer booleans.

This standing approval is narrow. It covers only clean merges from child task
branches into the matching `taskforge/epic-<number>` branch during the active epic
goal. Those TaskForge-branch merges still need the task's validation and merge
preflight, but they do not need the human approval gate reserved for the
workspace's configured primary branch. This standing approval does not approve:

- merging `taskforge/epic-<number>` into the configured primary branch
- merging a child task into the configured primary branch
- resolving merge conflicts without clear evidence
- rebasing, force-pushing, deleting remote branches, or destructive cleanup
- continuing after the user changes the epic, target branch, or asks to stop

When all child tasks are complete, run the epic-level validation plan on the
integrated TaskForge branch. This includes cross-task tests and smoke coverage,
plus Node inspector breakpoint/REPL evidence for integrated backend paths when
applicable. Record the integration-level evidence on the epic, move the epic to
`review`, leave the agent on the TaskForge branch, summarize completed and
archived/skipped children, and ask for one explicit approval before merging the
TaskForge branch into the configured primary branch. Do not treat the original
Epic TaskForge Branch Workflow activation as approval for this final primary merge.

#### MCP Runtime Freshness

After changing MCP source, tool schemas, or workflow behavior, build the MCP
server and restart or reconnect every MCP client that will validate or use the
new contract. A long-running client can keep old tool descriptions, schemas,
and handlers even when the debug server has rebuilt successfully.

Use `get_session_health` to confirm the intended authenticated runtime and
project context. If a live tool behaves like the previous version, validate the
fresh build independently and restart or reconnect the stale client before
diagnosing the release code. For changes to Epic closeout behavior in this
repository, run the built protocol smoke after `mcp-server:build`:

```bash
pnpm exec tsx mcp-server/src/smoke/epic-release-closeout.ts
```

### Epic Integration Branch Completion

Use the TaskForge branch as the epic-level integration branch when an epic has
been executed through the Epic TaskForge Branch Workflow. For an epic such as `EPIC-72`,
the expected branch chain is:

```text
taskforge/task/AXE-436-* -> taskforge/epic-72
taskforge/task/AXE-437-* -> taskforge/epic-72
taskforge/epic-72 -> <workspace.masterBranch>
```

Do not invent or require a synthetic parent branch such as
`taskforge/task/EPIC-72-ingest-nexus-dealer-information-into-axel-context` when the
epic was intentionally integrated through `taskforge/epic-72`. The TaskForge branch
is the parent epic branch for validation, review, and final primary-branch
merge evidence.

#### Final Epic Merge Contract

After all child tasks and release-level validation are complete, and after the
user explicitly approves the exact Epic-to-primary merge:

1. Run `merge_task_branch` with `ticketNumber: "EPIC-<number>"`, `workspace`,
   `targetBranch: "<workspace.masterBranch>"`, and `apply: false`. Include
   `projectPath` when the MCP session does not already own the correct local
   project context.
2. Require the preflight `taskBranch` to equal the canonical
   `taskforge/epic-<number>` branch and `targetBranch` to equal the workspace's
   registered primary branch. A synthetic `taskforge/task/EPIC-*` source or
   another `taskforge/epic-*` target is a tool-contract failure, not a valid fallback.
3. Accept `action: "already_merged"` only when local Git also proves
   `git merge-base --is-ancestor taskforge/epic-<number> <workspace.masterBranch>`.
4. After clean preflight and approval, call the same tool with `apply: true`
   and `approved: true`. Confirm the returned merge SHA equals the primary
   branch `HEAD` and the persisted branch context records the canonical TaskForge
   source and primary target.
5. If source, target, ancestry, SHA, or persisted context disagrees, stop and
   report the mismatch. Do not create a synthetic Epic branch or silently use a
   manual Git merge to repair the tool result.

Before marking an epic complete after a TaskForge branch workflow:

1. Confirm all non-archived child tasks are `done` or `finalized`.
2. Confirm archived child tasks are intentionally superseded or out of scope;
   do not unarchive them only to satisfy a completion count.
3. Confirm the matching `taskforge/epic-<number>` branch contains the child task
   merge commits.
4. Confirm the TaskForge branch has been merged into the configured primary
   branch, or stop for explicit approval if that primary merge has not been
   approved yet.
5. Record a TaskForge validation on the epic with the TaskForge branch name,
   target primary branch, merge evidence, validation commands, and any
   intentionally archived/superseded child tickets.
6. Then move the epic from `review` to `done` when the user or TaskForge
   explicitly asks for completion.

If `update_task_status` rejects epic completion after the matching TaskForge
or legacy branch was merged into the configured primary branch, treat that as a
TaskForge branch-gate mismatch, not as proof that the integration branch is
unmerged. Keep the epic in `review`, record or reference the integration-branch
validation evidence, and report the exact mismatch. Do not retry the same
failing completion transition in a loop.

If a strict-branching task in `review` is explicitly approved for completion
and still needs a branch merge, then use the merge approval flow below. This
flow is only for the reviewed completion step, not for ordinary agent
implementation completion.

1. Tell the user the task branch still needs to merge into the target branch.
2. Ask for merge-specific approval before performing the merge. The approval
   must name the exact ticket and target branch, for example
   `I approve merging AXE-173 into main.` Do not infer approval from "mark it
   done", "finish it", or similar completion language. If approval is missing,
   follow the Human Approval Stop Rule below exactly.
3. Call `merge_task_branch` first with `apply: false` to run the merge
   preflight. This checks clean-repo state, local branch existence, current
   branch, and whether Git can merge the task branch into the primary branch
   without conflicts. Include `workspace` with either the task `id` or
   `ticketNumber`; the merge policy is always resolved from that workspace.
   If this MCP session has not already called `set_project_context`, include
   `projectPath` with the local git worktree path. Missing project context is a
   setup problem, not a reason to mark the task blocked.
4. If preflight reports conflicts or any blocked result, report that reason and
   do not attempt the merge.
5. Only after the user explicitly approves the exact merge, call
   `merge_task_branch` with `apply: true` and `approved: true`. Include the
   same `projectPath` when the MCP session does not already have an active git
   project context.
6. After the merge succeeds, clean up the local task branch only when Git proves
   it is fully merged into the configured primary branch:
   - Confirm the current branch is the primary branch.
   - Confirm the task branch is not the current branch.
   - Confirm `git branch --merged <masterBranch> --list <taskBranch>` returns
     the task branch.
   - Delete the local task branch with `git branch -d <taskBranch>`.
   - If Git refuses deletion, report the reason and leave the branch in place.
   Do not use `git branch -D` for automatic cleanup. Do not delete remote
   branches unless the user explicitly approves that remote deletion.
7. After the merge succeeds and only when the ticket started that step from
   `review`, call `update_task_status` to move the task to `done`.

`merge_task_branch` may update the task branch context with merge metadata, but
`update_task_status` remains the completion gate. Never perform a branch merge
inside ordinary task status updates, and never trigger a merge while moving a
ticket from `in_progress` to `review`.

### Primary Branch Sync Before Merge

Before merging a strict-branching task branch into the configured primary
branch, or before creating an epic TaskForge branch from the configured primary
branch, check whether the primary branch has moved. Other features may have
merged outside TaskForge, so a branch can be behind even when its own work is
complete.

Use this safety-first sync flow:

1. Confirm the repository is clean and no merge, rebase, cherry-pick, or revert
   is in progress.
2. Fetch the latest refs for the remote that owns the primary branch.
3. Confirm the local primary branch is up to date with its remote tracking
   branch before using it as the merge target. If it is behind, fast-forward the
   local primary branch. If it has diverged, stop and ask for human direction.
4. Compare the task branch against the updated primary branch:
   - If the task branch already contains the current primary branch tip, proceed
     to merge preflight.
   - If the task branch is behind the current primary branch, rebase the task
     branch onto the updated primary branch before merge preflight.
5. Before rebasing, create a local backup tag at the task branch `HEAD`, for
   example:
   `git tag -a <taskBranch>-rebase-backup-<timestamp> -m "pre-rebase backup" <taskBranch>`.
   Do not push backup tags unless the user explicitly asks.
6. Print the exact `git rebase <masterBranch>` command and wait for explicit
   human approval before running it. Rebasing rewrites the local task branch
   history and must not be inferred from "finish", "mark it done", or a loop
   continuation.
7. During conflicts, inspect each conflicted file and choose the smallest clear
   resolution. Keep primary-branch changes unless the task branch deliberately
   supersedes them. If product intent is unclear, ask one targeted question and
   stop. Do not guess.
8. After a successful rebase, rerun the merge preflight. If the task branch is
   pushed to a remote, do not force-push it unless the user explicitly approves
   `git push --force-with-lease`; never use plain `--force`.

This sync step should happen before `merge_task_branch apply:true` when the
target is the primary branch, not inside `update_task_status`. For epic TaskForge
branch workflow task merges, start each task from the current TaskForge branch instead of
rebasing task branches during normal unattended work. If a history rewrite is
still required, report the exact required Git commands and wait for approval at
the history-rewrite step.

Branching from a blocked task branch is allowed only when the user explicitly
says the new task depends on that blocked code; pass that intent through
`allowBlockedBranchBase`.

## Human Approval Stop Rule

Some TaskForge actions require direct human approval before the agent may
continue. Merge approval is the common strict-branching case, but this rule
applies to any action that needs explicit user permission.

This section is the canonical stop behavior for slash `/goal` commands, Codex
goals, Ralph loops, continuation wrappers, scheduled resumes, and retry loops.
Other sections should reference this rule instead of redefining approval-stop
behavior.

When an approval is required:

1. Ask for the exact approval once.
2. Make that approval request the final output of the current autonomous run.
   The final output may contain only:
   - one sentence saying the work is ready but the final merge needs explicit
     approval
   - the exact approval phrase required
3. If running inside a slash `/goal`, Codex goal, Ralph loop, continuation
   wrapper, scheduled resume, or any retry loop, end that run as
   `blocked-awaiting-human-approval` immediately after that final output.
4. Do not retry, poll, re-ask, continue the Codex goal, continue a Ralph loop,
   or emit repeated "still blocked" messages while waiting.
5. Do not call more tools to make progress on that approval-gated action.
6. Resume only after a new user message explicitly grants or denies approval.

If the agent notices it is about to send substantially the same blocked/approval
message twice, that is a hard stop signal. Do not send another blocked status.
End the autonomous run immediately and wait for user input.

For strict-branching merges into the configured primary branch, acceptable
approval must be specific to the merge, for example:

```text
I approve merging AXE-169 into <workspace.masterBranch>.
```

Replace `<workspace.masterBranch>` with the exact registered value from the
current TaskForge workspace record, for example `main` only when that record
actually returns `masterBranch: "main"`.

Approval is present only when a user message explicitly approves merging the
exact ticket into the exact target branch, such as the phrase above. That
approval remains valid until a later user message explicitly denies the merge,
changes the ticket, changes the target branch, or asks to stop. Assistant/tool
messages, Codex goal continuations, Ralph loop iterations, scheduled resumes,
and other automated continuations do not erase or create approval. When explicit
approval for the exact ticket and branch is already present, do not ask again.
Proceed to the approved merge flow by calling `merge_task_branch` with
`apply: true` and `approved: true` after any required preflight/sync checks.

For child task merges into the matching `taskforge/epic-<number>` branch, an
explicit epic execution goal is already sufficient approval. Do not stop for a
per-task merge approval prompt when the task has passed validation, the
preflight is clean, and the merge target is the active TaskForge integration
branch. Apply the Legacy Epic Branch Rule when the active epic is pre-cutover.
Still use `approved: true` in the `merge_task_branch` call so the MCP tool can
apply the clean merge.

Do not treat these as approval:

- an automated continuation
- a Codex `/goal` or goal runner resume
- a Ralph loop iteration
- "continue"
- "finish the task"
- "mark it done"
- silence or elapsed time

If you need to help the user choose, ask in this order:

1. Which workspace should this task live in?
2. Which system inside that workspace owns the work?
3. Is there a service marker for it?

## Project Context Rule

Use project context when the task or epic belongs to a local repository,
conversation, or agent work session.

Preferred setup at the start of an MCP session:

```json
{
  "projectPath": "/absolute/path/to/project",
  "projectName": "TaskForge",
  "worktreeAlias": "optional-worktree-alias",
  "threadId": "codex-thread-123",
  "sourceAgent": "Codex"
}
```

Call `set_project_context` with that payload. The MCP server resolves Git
metadata first and stores a richer active session context:

- `projectHash`: worktree-scoped identity hash
- `repoHash`: repo-scoped identity hash shared by linked worktrees
- `repoRoot`: repository root when available
- `branchName`: current branch when attached
- `worktreePath`: current worktree root
- `worktreeName`: worktree folder name
- `worktreeAlias`: optional human override

Treat `branchName` as the feature/task discriminator. The repo or worktree
identifies the broader project scope, but the branch identifies which feature
line a task belongs to.

When reporting context back to the user, prefer:

1. Branch label: `branchName`
2. Scope label: `worktreeAlias`, then `worktreeName`, then `projectName`, then
   the project path basename
3. Hash label: short `repoHash` when present, otherwise short `projectHash`

If a compact fallback display name is needed, use `worktreeAlias`, then
`branchName`, then `worktreeName`, then `projectName`.

Before creating or updating branch-scoped work, confirm that the active context
contains the expected `branchName`. If `branchName` is missing, call
`set_project_context` with the absolute `projectPath` for the current worktree
and inspect the returned context before writing tickets.

After that, `create_task`, `create_epic`, `create_task_tree`,
`create_epic_tree`, `convert_markdown_to_tasks`, `update_task`, and
`update_task_status` attach the current context automatically.

If the MCP config sets `TASKFORGE_PROJECT_PATH`, the server initializes the
active project context at startup. Use `get_project_context` to confirm it
before creating project-scoped work, and verify `branchName` before creating
branch-scoped work.

Use `hash_project_path` when you only need to inspect the context/hash without
making it active. Use `get_project_context` before creating work if you are not
sure whether the MCP session already has the right context. Use
`clear_project_context` before switching to unrelated project work.

The MCP server persists both worktree-scoped and repo-scoped fields when
project context is attached. Set `TASKFORGE_PROJECT_HASH_SALT` when you want
hashes to be stable only inside your environment.

For existing tickets created before project tracking, use
`backfill_project_context` first with `dryRun: true`, then run it again with
`dryRun: false` only after confirming both the candidate list and the active
`branchName`. Do not apply a backfill when the active context only proves the
general repo/project and does not identify the intended feature branch.

## Epic Rule

Treat `epicId` as required for ordinary task creation.

This applies to `create_task`, `create_task_tree`, and `convert_markdown_to_tasks`.
If the user asks for tasks but no epic is available, create the epic first with
`create_epic`, inspect the returned epic id, and then create ordinary tasks in
separate `create_task` requests with that `epicId`.

Do not send `epicId` for `create_epic` or `create_epic_tree`; those tools create
the parent epic directly.

## Epic-First Batch Creation Rule

When creating an epic plus tasks, do not try to create the full tree in one API
request. Use a deliberate multi-request flow:

1. Call `create_epic` with only the parent epic payload.
2. Read the returned epic `id` and ticket number.
3. Create each child task with a separate `create_task` request that includes
   the returned `epicId`.
4. Add blockers or sibling dependencies only after the relevant task ids or
   ticket numbers exist.

Prefer this flow for agent-created work even when `create_epic_tree` is
available. `create_epic_tree` and `create_task_tree` are compact API shortcuts,
but they push parent creation, child creation, ticket-number allocation, and
linking through one larger request. Use them only when the user explicitly asks
for a tree tool, the target runtime is known to support the transactional tree
endpoint, and the resulting batch is small. If a tree request fails, fall back
to the epic-first flow instead of retrying the same large payload.

## Creation-Time Blocker Rule

When creating a set of tasks, the agent must also account for execution
dependencies before considering the task creation complete.

Use this rule for `create_task`, `create_task_tree`, `create_epic_tree`, and
`convert_markdown_to_tasks` whenever the request creates or imports multiple
work items.

Before creating tasks:

1. Sketch the smallest dependency graph needed for safe agent execution.
2. Identify true blockers: contracts, schemas, migrations, API foundations,
   auth/policy enforcement, fixtures, or shared components that another task
   cannot implement or verify without.
3. Identify parallel work: tasks that can start from the same accepted contract
   and do not need each other's code.
4. Do not make every later task depend on every earlier task. Add blockers only
   for real prerequisites.
5. If dependency intent is ambiguous and the wrong ordering would cause rework,
   ask one targeted question. Otherwise, choose the conservative dependency
   graph and proceed.

After creating tasks:

1. Attach blockers immediately while the ticket ids or ticket numbers are fresh.
2. Use `dependsOn` in `create_task` only for blockers that already exist before
   the new task is created.
3. When newly created sibling tasks depend on each other, create the tasks first,
   then call `set_task_blockers` or `add_task_blockers` using the fresh ids or
   `ticketNumber + workspace`.
4. Prefer `set_task_blockers` when the full blocker set is known. Prefer
   `add_task_blockers` only when preserving existing blockers.
5. Report the resulting blocker chain to the user along with the created
   tickets.

Planning timelines are not a substitute for blockers. A timeline says "work
these in this order"; blockers say "this task is not agent-eligible until these
prerequisites are complete." When both exist, keep them consistent: earlier
timeline stages should usually contain unblocked foundation tasks, and later
stages should carry blocker links for true prerequisites.

## Runtime Blocker Eligibility Rule

TaskForge blocker links are stored as task dependencies (`dependsOn`) and are
returned in execution packets as `blockers`. Blocker links are stronger than
planning order, priority, or chat intent.

Use this rule whenever an agent selects, starts, resumes, reviews, or performs
epic TaskForge branch work for a task or epic:

1. A ticket is agent-eligible only when its own status is not `blocked` and all
   of its blocker tickets are completed.
2. A blocker is completed only when the blocker ticket status is `done` or
   `finalized`. Treat `finalized` as already completed because it is downstream
   of Done. Treat `review`, `ready`, `in_progress`, `blocked`, `backlog`, and
   `archived` as not completed for blocker eligibility.
3. If any blocker is unresolved, missing from the packet, or not completed,
   stop before setting a runtime goal, creating a branch, editing files, running
   implementation commands, or changing this ticket's status.
4. Report the blocking ticket numbers, titles, and statuses. If the user wants
   the next useful action, offer to work the unfinished blocker ticket instead.
5. Do not remove blocker links, move the blocked ticket out of `blocked`, or
   mark the blocked ticket eligible just to continue. The normal unblocking path
   is completing the blocker ticket first.
6. Once the blocker ticket is marked `done` or `finalized`, the dependent ticket
   may be treated as unblocked on the next execution-packet or planning read.
   Re-read the packet before starting so the agent sees current blocker state.

Useful dependency examples:

- Contract task first; API implementation depends on the contract.
- API policy or endpoint task before UI integration that consumes it.
- Data migration before runtime code that reads the new shape.
- Fixture or seed task before demo/smoke evidence only when the evidence cannot
  be captured without that fixture.
- Documentation can run in parallel with implementation when it only captures
  planned behavior, but final demo evidence usually depends on the UI/runtime
  task it proves.

## Attachment Rule

Use TaskForge MCP attachment tools for task files. Do not read or write
TaskForge attachment storage directories directly, and do not query MongoDB for
attachment records. The MCP server talks through the API so provider settings,
path safety, and per-attachment provider metadata stay centralized.

Tasks can have multiple attachments. Each attachment stores its provider kind,
so old attachments remain readable when the default provider changes. Provider
enablement and default selection live in the TaskForge settings API and UI.
Cloud-provider credentials and connection details live only in the API runtime
environment; do not try to configure either concern through task attachment
tool payloads.

Typical attachment evidence includes screenshots, images, zip archives,
Markdown notes, exported logs that are safe to share, and small text artifacts
that help a reviewer understand the completed work. Prefer attachments for
visual or file-shaped evidence; prefer validation records for command/test
outcomes; prefer notes for narrative context.

For frontend, browser, or UI work, attaching screenshots is the default
evidence path when a TaskForge ticket is known and browser/tooling can capture
them. For web UI tasks, capture desktop, tablet, and mobile final states when
practical. For visual bug fixes, attach a before/reproduction screenshot when
available and a final fixed-state screenshot after the change. Name the files so
the ticket, state, and viewport are obvious, for example:

```text
ABC-12-final-desktop.png
ABC-12-final-tablet.png
ABC-12-final-mobile.png
ABC-12-before-desktop.png
ABC-12-after-desktop.png
```

If only one viewport is relevant or available, attach that screenshot and record
the limitation in a validation record or note. Do not block task completion only
because tablet/mobile screenshots are impossible in the current tool context,
but do make the missing evidence explicit.

Attach other relevant screenshots while working when they provide durable review
value, such as before/after UI states, a reproduced visual bug, a fixed error
state, or a final non-web app surface. Avoid noisy intermediate screenshots that
do not help review the task. If screenshot capture fails because authentication,
browser tooling, or local runtime state is unavailable, record a skipped or
warning validation with the reason and the exact URL or UI path that still needs
manual visual review.

When referencing a task by ticket number for attachment tools, pass `workspace`
with the ticket number. Prefer `id` when the exact task id is already known.

Before upload:

1. Use an absolute local `filePath`.
2. Check the path and filename for obvious secret material, such as `.env`,
   private keys, certificates, tokens, credentials, or files named `secret`.
   If the file appears secret-bearing, stop and ask the user to confirm or
   provide a sanitized file.
3. Upload only user-intended files. Do not upload generated logs, build output,
   dependency folders, or broad directories.
4. For browser screenshots, verify the image is the intended final UI state
   before upload. Do not attach blank pages, login screens produced by missing
   agent auth, or screenshots containing secrets, session tokens, raw cookies,
   private customer data, or irrelevant local desktop content.
5. Upload each viewport screenshot separately with `upload_task_attachment`;
   then include a short validation or note that names what was attached.

If the attachment id is unknown, call `list_task_attachments` first. Use
`read_task_attachment` for text-like files that are safe to inline. Binary or
oversized files may return metadata without inline content; use the web/API
download path when the user needs the original bytes.

Deletion requires the exact `attachmentId` plus one supported task reference
shape:

- `id` plus `attachmentId`
- `ticketNumber` plus `workspace` plus `attachmentId`

Filename matching is not supported for deletion. Do not call
`delete_task_attachment` with only a filename, and do not infer the task from a
filename. Duplicate displayed filenames are common enough that filename matching
is intentionally outside the delete tool contract.

The server resolves the task reference before deleting, and filename matching
is unsupported. `workspace` is required only when using `ticketNumber`. If the
task reference or attachment ID is unknown or ambiguous, call
`list_task_attachments` for the suspected task first and ask the user which
attachment ID to remove.

The TaskForge API endpoint performs the authoritative task-scoped delete through
the attachment's configured provider. The response contains
`deletedAttachment.attachmentId` and `remainingAttachments`.

Example upload payload:

```json
{
  "ticketNumber": "AXE-21",
  "workspace": "axel",
  "filePath": "/absolute/path/to/spec.md"
}
```

Example list payload:

```json
{
  "ticketNumber": "AXE-21",
  "workspace": "axel"
}
```

Example read payload:

```json
{
  "ticketNumber": "AXE-21",
  "workspace": "axel",
  "attachmentId": "attachment-id"
}
```

Example delete payload with task id:

```json
{
  "id": "task-id",
  "attachmentId": "attachment-id"
}
```

Example delete payload:

```json
{
  "ticketNumber": "AXE-21",
  "workspace": "axel",
  "attachmentId": "attachment-id"
}
```

## Tool Guide

Use these TaskForge MCP tools directly:

- `list_workspaces`
- `hash_project_path`
- `set_project_context`
- `get_project_context`
- `get_session_health`
- `create_agent_browser_session`
- `clear_project_context`
- `backfill_project_context`
- `create_task`
- `create_epic`
- `list_tasks`
- `search_tasks`
- `get_task`
- `get_task_execution_packet`
- `list_initiatives`
- `get_initiative`
- `get_initiative_execution_packet`
- `link_initiative_epic`
- `unlink_initiative_epic`
- `update_initiative_goal`
- `update_initiative_readiness`
- `prepare_initiative_branch`
- `update_initiative_status`
- `merge_initiative_branch`
- `get_task_history`
- `get_task_validations`
- `update_task`
- `update_task_status`
- `prepare_task_branch`
- `merge_task_branch`
- `set_task_blockers`
- `add_task_blockers`
- `move_task_to_epic`
- `attach_task_to_epic`
- `append_task_note`
- `append_task_validation`
- `append_task_commit_reference`
- `link_task_dependency`
- `upload_task_attachment`
- `list_task_attachments`
- `read_task_attachment`
- `delete_task_attachment`
- `list_plans`
- `get_plan`
- `create_plan`
- `ensure_plan_for_workspace`
- `add_task_to_plan`
- `move_task_in_plan`
- `move_task_before`
- `move_task_after`
- `reorder_plan`
- `remove_task_from_plan`
- `get_next_planned_task`
- `create_task_tree`
- `create_epic_tree`
- `convert_markdown_to_tasks`

## Planning Timeline Workflow

Use planning tools when the user or workspace has an explicit execution order.
Priority, status, and ticket number are not planning order.

For agent work selection:

1. Call `list_plans` with the workspace.
2. If no workspace-level plan exists and the user wants a workspace sequence,
   call `ensure_plan_for_workspace` instead of manually creating a default plan.
3. Select the active workspace, epic, or project-scoped plan.
4. Call `get_next_planned_task` before deciding what to work on.
5. Treat the returned `recommendedTask` as the next agent candidate unless it is
   `null`; if it is `null`, report that the plan has no currently actionable
   task.
6. An agent may move a ticket to `status: "blocked"` when it discovers a real
   blocker, but blocked tickets are not agent-eligible work. If the next
   candidate or any manually selected ticket is blocked, or if its execution
   packet shows unfinished blockers, do not work on it. Report the blocker
   chain and work the unfinished blocker first when appropriate.
7. After selecting a candidate from a plan, call `get_task_execution_packet` and
   apply the Runtime Blocker Eligibility Rule before creating a branch or
   changing code.

Plan structure:

- A plan belongs to one workspace.
- A plan can scope to a workspace, epic, or project context.
- Stages are ordered vertically. Earlier stages happen first.
- Treat a stage as the planning timeline "instance" for a logical slice of
  work, for example `1. Contracts and Read Model` or
  `2. Presence Ingestion and Derivation`.
- Multiple task ids in one stage are parallelizable.
- Task dependencies remain blocker semantics and are not timeline order.
- When creating or recalculating a plan for newly created tasks, also apply the
  Creation-Time Blocker Rule so `get_next_planned_task` can distinguish
  actionable tasks from tasks that only appear later in the timeline.

Use `add_task_to_plan` to bring existing work into the timeline.
When adding newly created tasks to an existing active plan, default to appending
them after the current final stage. Put each sequential logical slice in its own
new stage, and use `mode: "parallel"` only when tasks can run at the same time
inside that slice.
Use `move_task_before` and `move_task_after` when expressing order relative to
another ticket. Prefer these over calculating stage indexes.
Use `move_task_in_plan` with `mode: "parallel"` when a task should run beside
another task in the same stage.
Use `remove_task_from_plan` to take a task out of the timeline without deleting
the ticket.
Do not use `reorder_plan` to replace, clear, or recalculate the existing
timeline unless the user explicitly asks to clear, replace, recalculate, or
reset the plan. If the user asks to recalculate, read the current plan first and
preserve existing unrelated stages unless they explicitly asked to remove them.

Plans include a `revision` number. For any mutation, read the current plan first
and pass `expectedRevision` from that plan when the tool supports it. If the API
returns a revision conflict, call `get_plan`, inspect the latest stage layout,
and retry against the new revision only if the intended ordering still makes
sense.

## Create Patterns

### Single task

Use `create_task` when the user wants one task created.

Minimum useful payload:

```json
{
  "title": "Add export audit logging",
  "workspace": "workspace-alpha",
  "system": "core-platform",
  "service": "api",
  "type": "feature",
  "priority": "medium",
  "goal": "Complete export audit logging with API tests and a verified event record.",
  "epicId": "665f1f77bcf86cd799439011",
  "source": {
    "createdBy": "mcp-agent",
    "agentName": "Assistant",
    "conversationId": "session-123"
  }
}
```

Do not set `ticketNumber`. The API generates the prefix from the workspace slug
and allocates the next number for that prefix; the chosen system does not define
the ticket namespace. Pass an existing `epicId`; tasks cannot be created outside an epic.
For agent-executable work, include a `goal` that follows the Agent Goal Rule at
creation time.
If the task needs structured execution guidance, include `agentExecution` using
the Agent Execution Contract Rule below. If the task is simple or existing
clients do not know the field, omit it; omission is fully supported.
If this task depends on existing tickets, pass `dependsOn` during creation or
call `set_task_blockers` immediately after creation.

Minimal legacy create payload that intentionally omits `agentExecution`:

```json
{
  "title": "Add export audit logging",
  "workspace": "workspace-alpha",
  "system": "core-platform",
  "service": "api",
  "type": "feature",
  "priority": "medium",
  "goal": "Complete export audit logging with API tests and a verified event record.",
  "epicId": "665f1f77bcf86cd799439011",
  "source": {
    "createdBy": "mcp-agent",
    "agentName": "Assistant",
    "conversationId": "session-123"
  }
}
```

Minimal create payload with `agentExecution`:

```json
{
  "title": "Add export audit logging",
  "workspace": "workspace-alpha",
  "system": "core-platform",
  "service": "api",
  "type": "feature",
  "priority": "medium",
  "goal": "Complete export audit logging with API tests and a verified event record.",
  "epicId": "665f1f77bcf86cd799439011",
  "source": {
    "createdBy": "mcp-agent",
    "agentName": "Assistant",
    "conversationId": "session-123"
  },
  "agentExecution": {
    "outcome": "Export actions produce durable audit events with tests.",
    "scope": {
      "included": ["API service changes", "Focused task tests"],
      "excluded": ["UI reporting"]
    },
    "paths": {
      "allowed": ["api/src/app/exports", "api/src/app/tasks"],
      "doNotTouch": ["web/src"]
    },
    "assumptions": [
      {
        "statement": "Existing export endpoints already identify the actor.",
        "verificationHint": "Inspect the current export controller before editing."
      }
    ],
    "references": [
      {
        "kind": "file",
        "label": "Export service",
        "value": "api/src/app/exports/export.service.ts"
      }
    ],
    "runtimePrerequisites": [
      {
        "name": "MongoDB local dev database",
        "required": true,
        "details": "Needed for API integration checks."
      }
    ],
    "validationPlan": [
      {
        "kind": "test",
        "command": "pnpm nx test api",
        "target": "api",
        "expectedEvidence": "Export audit specs pass.",
        "required": true
      }
    ],
    "recommendedSkills": [
      {
        "skill": "nestjs-doctor",
        "priority": "recommended",
        "useWhen": "After touching NestJS task or export services."
      }
    ],
    "safety": {
      "constraints": ["Do not record tokens, cookies, or raw user payloads."],
      "privacy": ["Use sanitized request and response examples only."]
    },
    "reviewFocus": ["Audit event shape", "Legacy export behavior"]
  }
}
```

### Single epic

Use `create_epic` when the user wants a parent epic created.

Minimum useful payload:

```json
{
  "title": "Improve onboarding flow",
  "workspace": "workspace-alpha",
  "system": "core-platform",
  "priority": "high",
  "source": {
    "createdBy": "mcp-agent",
    "agentName": "Assistant",
    "conversationId": "session-123"
  }
}
```

The server generates the `EPIC-#` ticket number. Do not send `epicId`,
`ticketNumber`, or a custom prefix for epics.

### Parent with children

Use `create_task_tree` when a parent task should immediately spawn child tasks.

Do not use `create_task_tree` for ordinary epic-backed task batches. Prefer
separate `create_task` calls against an existing `epicId` unless the user
explicitly asks for a parent task with children and the transactional tree
endpoint is known to work in the target runtime.

Pass `epicId` for the existing epic. Keep the parent location authoritative.
Child tasks inherit the same workspace, system, service, epic, and source.
Give the parent and child tasks durable `goal` values when agents may execute
them later.
After the tree is created, apply the Creation-Time Blocker Rule to any child
tasks that depend on the parent or on sibling tasks.

### Epic with child tasks

Avoid `create_epic_tree` for normal agent-created epic-plus-task batches. The
default flow is `create_epic` first, then one `create_task` request per child
using the returned epic id.

Use `create_epic_tree` only when the user explicitly asks for the tree shortcut,
the runtime is known to support the transactional tree endpoint, and the batch is
small enough that a single request is operationally safer than separate creates.
Do not send `epicId`; the created epic becomes the parent for the children. Give
every child task a durable `goal` value when agents may execute it later. After
the tree is created, apply the Creation-Time Blocker Rule to the child tasks
before reporting that ticket creation is complete.

### Markdown import

Use `convert_markdown_to_tasks` when the user pasted a checklist or worklist.

`convert_markdown_to_tasks` requires a resolved `epicId` because imported
items become ordinary tasks. Ask for the workspace and epic first if the
markdown does not clearly belong to a known target. If no epic exists, create
one before importing the markdown.
After import, add or tighten `goal` values for any task that may be executed by
an agent.
After import, inspect the created task list and apply the Creation-Time Blocker
Rule when the markdown implies prerequisites or sequential implementation.

Minimum useful payload:

```json
{
  "markdown": "- Add webhook retry tests\n- Document retry behavior",
  "workspace": "workspace-alpha",
  "system": "core-platform",
  "service": "api",
  "type": "test",
  "priority": "medium",
  "epicId": "665f1f77bcf86cd799439011",
  "source": {
    "createdBy": "mcp-agent",
    "agentName": "Assistant",
    "conversationId": "session-123"
  }
}
```

## Read and Review Patterns

Use `list_workspaces` to resolve valid workspace ids/slugs before create/search when workspace choice is unclear. For create flows, use the selected workspace record's `systems` and `services`; do not fall back to legacy static values from older TaskForge clients.
Use `list_tasks` for broad filtered retrieval. It returns a compact
cursor-paged result with `items` and `pageInfo`, not full task detail. Use the
returned `pageInfo.nextCursor` as `cursor` while `pageInfo.hasMore` is true.
Stop and investigate if `hasMore` is true without `nextCursor` or if the same
cursor repeats.
Use `search_tasks` when the user gives a title fragment, ticket fragment,
entity type, epic, project hash, thread id, priority, service, or status-constrained search. It also returns compact cursor pages.
Both tools read the team-wide task ledger. Do not describe their results as the
signed-in human's `Mine` board scope; that scope includes the human's creator
family and is owned by the board snapshot contract.
Archived records are excluded from `list_tasks` and `search_tasks` unless you
set `includeArchived: true` or explicitly search with `status: "archived"`.
Use `get_task` for a single full-detail record, including notes, validations,
attachments, and acceptance criteria. Do not load full detail for every task in
a large workspace unless the user explicitly asks for exhaustive detail and the
workflow is intentionally paginated.
Use `get_task_execution_packet` when starting implementation on a specific
ticket. Prefer it before broad history reads because it returns compact,
deterministic execution context: identifiers, status, `agentGoal`, acceptance
criteria, `agentExecution`, blockers, project and branch context, safe source
metadata, counts, recent validation summaries, and attachment metadata. It omits
notes, full history, raw attachment content, validation command details, and
secret-bearing browser/session data.
Use `get_task_history` when the user wants an audit trail or wants to know who changed what.
Use `get_task_validations` when the user wants to know what checks were run,
whether a task was validated, or how code verification was recorded.
If the record or packet includes `goal` or `agentGoal`, treat it as the ticket's
agent objective. Read it before starting implementation work and report it when
the user asks what the ticket is trying to accomplish.
If the record has `status: "blocked"`, treat that as an explicit stop signal,
including when the task also has an agent goal. Agents may mark tickets blocked,
but they cannot start, resume, retry, or continue implementation work on blocked
tickets.
When reviewing completed work, prefer `doneAt` over `updatedAt` for
"most recently completed" ordering and recent-completion summaries.

## Execution Packet Intake Rule

Use this rule whenever an agent takes on a TaskForge task or epic for
implementation, validation, review, or epic TaskForge branch work. The execution packet
is the canonical TaskForge-to-agent handoff.

1. Call `get_task_execution_packet` for the target ticket before changing code,
   creating a task branch, setting an agent goal, or relying on chat history.
The only integration-branch exception is the empty integration-branch bootstrap
   explicitly defined by the Epic TaskForge Branch Workflow; read the epic packet before
   any implementation or status change.
2. Treat the packet as the current execution contract. Read and preserve:
   identifiers, workspace, status, blockers, project context, branch context,
   `agentGoal`, acceptance criteria, `agentExecution`, `initiativeContext`, recent
   validations, and attachment metadata.
   Before editing, summarize the packet into a local execution checklist that
   covers the goal, blockers, scope, do-not-touch paths, prerequisites,
   validation plan, required skills, safety/privacy constraints, and review
   focus.
3. If the target ticket is an ordinary task with `epicContext.epicId`, call
   `get_task_execution_packet` for that parent epic before editing unless the
   parent epic packet is already available in the current run. Treat the epic
   packet as parent context and the task packet as the active implementation
   contract. Preserve both packets' `agentGoal`, acceptance criteria,
   `agentExecution`, blockers, project context, branch context, recent
   validations, and attachment metadata.
4. If the target ticket is an epic, its own packet is the active epic execution
   contract. For epic TaskForge branch or multi-task execution, read each child task's
   execution packet before starting that child and layer it under the epic
   packet.
5. If the packet says the ticket is `blocked`, follow the blocked-ticket stop
   rules. Do not start work or create a branch.
6. Inspect `packet.blockers` and apply the Runtime Blocker Eligibility Rule. If
   any blocker is not `done` or `finalized`, stop and report the blocker chain
   instead of working the dependent ticket.
7. If the active packet includes `agentGoal`, mirror it into the active agent
   runtime:
   - For Codex, use it as the Codex goal or `/goal` objective when goal mode is
     available.
   - For Claude or another agent runtime, use it as that agent's task goal or
     top-level working objective.
   - If no runtime goal feature exists, restate the goal in the agent's local
     work plan before implementation.
8. If the active packet includes `agentExecution`, convert it into concrete
   execution constraints before editing:
   - verify `assumptions` first when their proof path is available
   - obey `scope.included`, `scope.excluded`, `paths.allowed`, and
     `paths.doNotTouch`
   - load or inspect `references` that are safe and relevant
   - satisfy required `runtimePrerequisites` before validation
   - run or explicitly skip each required `validationPlan` item with rationale
   - use `recommendedSkills` according to their priority and `useWhen`
   - preserve `safety` and `privacy` constraints throughout the run
   - include `reviewFocus` in the final handoff or review summary
9. When both epic and child task packets are available, reconcile them before
   editing:
   - the child task's `agentGoal` and `agentExecution` define the active work
   - the epic's `agentGoal` and `agentExecution` define parent release,
     sequencing, safety, and validation context
   - do not let a child task exceed the epic's scope, safety limits,
     do-not-touch paths, or release goal
   - if the task and epic conflict, stop and ask one targeted question or update
     stale TaskForge context before coding
10. If the packet includes `initiativeContext`, treat its initiative title and
   goal as parent cross-workspace context. Do not replace the task or epic goal
   with the initiative goal; use the initiative goal to check scope alignment,
   cross-workspace blocker decisions, readiness assumptions, validation
   evidence, and final handoff language. Before editing, explicitly reconcile:
   current ticket goal versus initiative goal, current workspace ownership
   versus sibling workspace ownership, inbound blockers, outbound dependents,
   and the smallest code surface that satisfies this ticket without stealing
   work from another workspace.
11. If the packet references attachments, list or read only the specific safe
   attachments needed for execution. Do not bulk-read attachments or download
   binary files unless they are directly relevant to the work.
12. If required execution data is missing or stale, update the ticket with a
   better `goal` or `agentExecution` before starting when the intended objective
   is clear. If the stale data is the parent epic, update the epic. If the stale
   data is the current task, update the task. If the stale data is the parent
   initiative goal, use
   `update_initiative_goal` when the replacement is clear from context. If it
   is not clear, ask one targeted question.
13. After validation, record evidence back to TaskForge with
   `append_task_validation`, `append_task_note`, `upload_task_attachment`, and
   `append_task_commit_reference` as appropriate.

## Update Patterns

Use `update_task_status` for a simple lane/status move.
Use `status: "archived"` to archive a task or epic without deleting it.
To restore archived work, use `update_task_status` or `update_task` with a live
status such as `backlog`.
When an agent finishes implementation work, move the ticket to `review`, tell
the user the task has been put into review and that no further agent action is
needed, then stop. Do not move directly from `in_progress` to `done`.
Only move a ticket to `done` when its current status is `review`, and only when
the user or TaskForge explicitly requests that completion step. Blocked tickets
must be moved out of `blocked` before they can enter `review` and later `done`.
If a blocked ticket is ready to continue, move it to `backlog`, `ready`, or
`review` according to the user's instruction and current evidence; do not skip
directly from `blocked` to `done`.
When a task enters a completed status (`done` or `finalized`), TaskForge locks a
completion timestamp in `doneAt`. Treat `doneAt` as the source of truth for
"when this task was completed". Do not infer completion order from `updatedAt`
when `doneAt` is available.
For `update_task_status`, prefer `ticketNumber` when the task is being
referenced from chat or from an external planning note and you do not already
have a fresh TaskForge record in hand. Include `workspace` when the user gives
it or when you want an additional scope guard.
Use raw internal `id` only when it came from the current TaskForge read flow
such as `list_tasks`, `search_tasks`, or `get_task` in the same session.
Do not carry old Mongo ids across sessions when a stable ticket number is
available; resolve the current record instead.

Large-workspace read rule:

- Prefer compact `list_tasks` / `search_tasks` pages for discovery, filtering,
  planning queues, epic/task lookup, and broad workspace scans.
- Follow cursors until enough compact records have been found; do not assume the
  first page is exhaustive.
- Call `get_task` only for the specific task or epic whose full detail is needed
  for implementation, editing, notes, validation review, or attachments.
- For exact ticket lookups, start with `search_tasks` using the ticket number
  and workspace when known, then call `get_task` only on the matched record if
  full detail is required.

Valid `update_task_status` shapes:

```json
{
  "id": "69f020dfb053e2565579e767",
  "status": "in_progress"
}
```

```json
{
  "ticketNumber": "NEX-12",
  "status": "in_progress"
}
```

When resolving by `ticketNumber`, `workspace` is optional because TaskForge
ticket numbers are globally unique. Include it when available to keep updates
scoped to the intended workspace.

Use `update_task` for broader edits such as title, priority, workspace, system, service, type, acceptance criteria, goal, agentExecution, or source.
Use `update_task` with `projectContext` only when correcting or reassigning the
project provenance for an existing ticket.
Use `set_task_blockers` when the user says a task or epic is blocked by a
specific complete set of other tickets. This replaces the full `dependsOn`
array. Use `add_task_blockers` when adding blockers without removing existing
ones. Treat "Blocked by" as the human-facing label for `dependsOn`; do not
invent a separate status such as `depends_on` or `waiting_on`.
Do not clear blocker links merely because an agent wants to work the dependent
ticket. A blocker normally clears by completing the blocker ticket (`done` or
`finalized`), then re-reading the dependent ticket's execution packet. Use
`set_task_blockers` with an empty blocker list only when the dependency itself
was wrong or the user explicitly asks to remove the blocker relationship.
Never send `notes` through `update_task`.
Do not fetch a task, merge note text into a `notes` array, and write it back
through `update_task`.
Use `append_task_note` for every note write, including agent breadcrumbs,
follow-up context, reviewer feedback, and status notes.
Use `append_task_validation` for structured validation records such as
ShellCheck, `bash -n`, typecheck, lint, test, or deploy verification results.
Use `append_task_commit_reference` after a local Git commit is created for task
work following the Task Commit Message Rule. Provide a full 40-character
`commitHash`, optional `branchName`, and either `id` or
`ticketNumber + workspace`.
Use `move_task_to_epic` or `attach_task_to_epic` when re-homing a task under a different epic.
Use `append_task_note` when adding extra context, implementation details, reviewer notes, or status breadcrumbs to a ticket.
Use `link_task_dependency` only when the dependency is already known and the target task exists.
Prefer `set_task_blockers` or `add_task_blockers` over `link_task_dependency`
when the user references blockers by ticket number or says something like
"Task ABC-12 is blocked by ABC-10 and ABC-11."

## Owner And Assigned Agent Contract

- `ownerUserId` is the accountable human owner. New task and epic writes may
  provide it explicitly; otherwise the API applies the authenticated actor
  defaults.
- `assignedAgentUserId` is optional and task-only. The API verifies that the
  agent is active and belongs to the selected human owner; MCP must not copy
  that relationship policy.
- When the authenticated actor is an agent and assignment fields are omitted,
  a new task defaults to the agent's owning human plus that current agent.
  Epics still default to the owning human without an assigned agent.
- If an assigned agent is later disabled, keep the historical assignment.
  Reads expose the retained agent through `assignedAgent` with its current
  `status`; do not clear or replace it implicitly. New assignment or
  reassignment still requires an active agent owned by the selected human.
- `create_task`, `create_task_tree`, and `convert_markdown_to_tasks` accept both
  fields. Tree and markdown children inherit the request assignment through the
  API contract.
- `create_epic` and `create_epic_tree` accept `ownerUserId` and reject
  `assignedAgentUserId`.
- In `update_task`, omit an assignment field to leave it unchanged. Send
  `assignedAgentUserId: null` to clear task delegation. Task reads and execution
  packets return `owner` first plus nullable `assignedAgent` and
  `assignedAgentUserId`.

## Agent Goal Rule

TaskForge stores a task or epic's agent objective in the optional `goal` field.
In UI, label it "Agent goal". Execution packets expose this value as
`agentGoal`. The field supports long-form goal text for durable Codex, Claude,
or other agent-runtime objectives, but keep it focused on the verifiable
objective rather than using it as an implementation journal.

Use `goal` when creating or updating tickets that should carry a durable
OpenAI Codex `/goal`-style objective. A good value states what to complete and
how the agent should know it is done.

When creating agent-executable tickets, write the `goal` before calling
`create_task`, `create_task_tree`, `create_epic_tree`, or
`convert_markdown_to_tasks`. Do not rely on the title, description, acceptance
criteria, planning stage, or chat history to carry the execution objective.

A solid task or epic goal should include:

1. The concrete outcome the agent must deliver.
2. The owning boundary or likely edit surface, such as package, app, API,
   contract, migration, UI, docs, or fixture.
3. Explicit out-of-scope work that belongs to later tickets.
4. Prerequisite assumptions or blocker references when the ticket depends on
   earlier work.
5. Required validation, such as typecheck, unit tests, API smoke, browser smoke,
   doctor skills, screenshots, or skipped-test rationale.
6. Evidence requirements, especially TaskForge validation records, sanitized
   request/response shapes, screenshot paths, commit references, or notes.
7. Safety and privacy limits when relevant, such as no secrets, tokens, cookies,
   raw provider payloads, raw browser state, broad PII, or tenant-ambiguous
   data.

Keep the goal as one focused paragraph when possible. It may be long enough to
stand alone, but it should not become an implementation journal or duplicate
every acceptance criterion. Use acceptance criteria for checklist-style pass/fail
details; use `goal` for the agent's durable execution objective.

Weak goal:

```text
Add presence support and tests.
```

Better goal:

```text
Implement only the contract/read-model foundation for shopper chat presence.
Update the shared contracts and management read shape so reads can optionally
return a safe presence summary. Keep runtime derivation, UI rendering, and send
policy out of this ticket. Add focused contract/read-model tests and record
sanitized validation evidence in TaskForge.
```

When performing a ticket:

1. Call `get_task_execution_packet` for the target ticket and follow the
   Execution Packet Intake Rule.
2. If the task status is `blocked`, stop immediately. Do not set or continue a
   Codex `/goal`, do not move the ticket back to `in_progress`, and do not make
   code changes for that ticket. An agent may put a ticket into `blocked`, but
   once blocked it cannot work that ticket at all.
3. Report the blocked status to the user, include the blocker context available
   on the ticket, and wait for an explicit human unblock before touching the
   ticket again. A human unblock means the user or TaskForge has moved the
   ticket out of `blocked` after deciding how to resolve the blocker; an agent
   must not unblock its own ticket just so it can keep working.
4. If `agentGoal` or `goal` is present, use it as the execution objective for
   the work.
5. If the current agent environment supports an explicit goal feature, set or
   mirror the goal before beginning long-running work. For Codex, use
   `/goal <ticket agent goal>` when available. For Claude or another runtime,
   use the same text as that agent's top-level ticket goal or working objective.
6. If `goal` is missing and the user asks for goal-driven work, ask for the
   intended objective or write one with `update_task`.

Use `update_task` to write, replace, or clear the task goal:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "goal": "Complete the API retry migration and verify it with unit and smoke tests."
  }
}
```

To clear a goal, send `"goal": null`. Do not store goal history in `notes`;
use notes only for discussion, breadcrumbs, and implementation context.

## Agent Execution Contract Rule

TaskForge stores structured agent execution guidance in the optional
`agentExecution` field on tasks and epics. It complements `goal`,
`description`, and `acceptanceCriteria`; it does not replace them.

Use `goal` for the durable objective paragraph: what the agent should complete
and how it knows the work is done. Use `acceptanceCriteria` for pass/fail
checklist items. Use `agentExecution` when the task or epic benefits from
structured machine-readable guidance that an agent should preserve across tools,
branches, or handoffs.

Good reasons to include `agentExecution`:

1. The ticket has important scope boundaries, explicit non-goals, or do-not-touch
   paths.
2. The ticket has assumptions that should be verified before editing.
3. The ticket needs reference material, runtime prerequisites, or a validation
   plan that should survive outside chat history.
4. The ticket should recommend skills such as `react-doctor`, `nestjs-doctor`,
   `node-inspect-debugger`, or browser/CDP validation.
5. The ticket has safety or privacy constraints that agents must not miss.

Do not add `agentExecution` just to mirror the title, description, goal, or
acceptance criteria. Legacy tasks, epics, and old MCP clients that omit the
field remain valid. Existing tickets with no `agentExecution` must read, list,
search, update, render, and save without creating empty contract objects.

The ticket detail UI shows `goal` and `agentExecution` under the top-level
`Agent` tab. The `Details` tab is for normal task metadata. Agents should still
write and update the same API fields (`goal` and `agentExecution`); the tab only
changes where humans edit those fields in the web app.

Treat each `agentExecution` field as follows:

- `outcome`: a concise result statement for what successful execution produces.
- `scope.included`: work that belongs in this ticket.
- `scope.excluded`: non-goals or work that belongs in another ticket.
- `paths.allowed`: likely files, directories, packages, or commands the agent
  may inspect or edit.
- `paths.doNotTouch`: files, directories, services, generated artifacts, or
  data surfaces the agent must avoid.
- `assumptions`: statements the agent should verify before editing; add
  `verificationHint` when the proof path is known.
- `references`: durable pointers to files, docs, tickets, URLs, commands, or
  artifacts needed for execution.
- `runtimePrerequisites`: local servers, databases, environment flags, browser
  sessions, MCP servers, or other setup required before validation.
- `validationPlan`: checks the agent should run or explicitly skip with
  rationale; use `append_task_validation` for the actual results.
- `recommendedSkills`: skills that would materially improve execution quality.
  Use `$find-skills` when discovery is requested or when a suitable skill name is
  not already known. Do not invent decorative skills just to fill the field.
- `safety.constraints`: hard execution limits, including destructive-operation,
  branch, data, tenant, or path boundaries.
- `safety.privacy`: secret, auth, PII, browser-state, customer-data, or
  logging limits.
- `reviewFocus`: what a reviewer should pay attention to after implementation.

When performing a ticket, `agentExecution` is binding execution context, not
optional decoration. If an agent cannot satisfy a required prerequisite,
validation item, safety constraint, or do-not-touch path, it must stop and report
the conflict instead of silently narrowing or ignoring the contract.

The supported v1 shape is:

```json
{
  "outcome": "Optional concise result statement.",
  "scope": {
    "included": ["Work that belongs in this ticket."],
    "excluded": ["Work that belongs elsewhere."]
  },
  "paths": {
    "allowed": ["relative/or/absolute/path"],
    "doNotTouch": ["relative/or/absolute/path"]
  },
  "assumptions": [
    {
      "statement": "Assumption to verify.",
      "verificationHint": "Optional proof or inspection hint."
    }
  ],
  "references": [
    {
      "kind": "file",
      "label": "Readable label",
      "value": "path-or-url-or-ticket",
      "note": "Optional note"
    }
  ],
  "runtimePrerequisites": [
    {
      "name": "Local API server",
      "details": "Optional setup detail.",
      "required": true
    }
  ],
  "validationPlan": [
    {
      "kind": "test",
      "command": "pnpm nx test api",
      "target": "api",
      "expectedEvidence": "Relevant specs pass.",
      "required": true
    }
  ],
  "recommendedSkills": [
    {
      "skill": "nestjs-doctor",
      "useWhen": "After changing NestJS files.",
      "priority": "recommended"
    }
  ],
  "safety": {
    "constraints": ["Do not expose secrets."],
    "privacy": ["Use sanitized examples."]
  },
  "reviewFocus": ["Contracts", "Backwards compatibility"]
}
```

Allowed reference kinds are `file`, `doc`, `ticket`, `url`, `command`,
`artifact`, and `other`.

Allowed validation kinds are `test`, `lint`, `build`, `doctor`, `browser`,
`debugger`, `review`, and `manual`.

Allowed skill priorities are `required`, `recommended`, and `optional`.
Most `agentExecution` text entries are capped at 1000 characters by the shared
schema. Human-facing labels such as reference `label`, prerequisite `name`, and
recommended skill `skill` are capped at 140 characters. Keep entries short and
put detailed evidence in validation records, notes, or attachments instead.

Skill priority guidance:

- `required`: the task should not be considered validated without this skill or
  an equivalent explicit check, for example `react-doctor` after React changes
  when repo policy requires it.
- `recommended`: the skill is likely to improve quality, but absence of the
  skill does not block implementation.
- `optional`: useful when available, but not needed for the normal path.

Use the exact `recommendedSkills` object shape, not a comma-separated string:

```json
{
  "skill": "react-doctor",
  "useWhen": "After changing React task editor code.",
  "priority": "required"
}
```

Never store API keys, bearer tokens, passwords, cookies, raw browser storage,
raw auth/session data, raw provider payloads, broad PII, raw prompt text, or
unrelated tab/browser state in `agentExecution`. Put sanitized paths, labels,
commands, and evidence descriptions in the contract; put detailed run results in
`append_task_validation`.

### Agent Tab Editor Format

The web UI stores the same structured `agentExecution` contract, but the Agent
tab editor uses one line per entry. Use these line formats when editing through
the UI or when explaining how a human should fill the tab:

```text
Assumptions:
statement | verificationHint

References:
kind | label | value | note

Runtime prerequisites:
required | name | details
optional | name | details

Validation plan:
kind | command | target | expectedEvidence | required
kind | command | target | expectedEvidence | optional

Recommended skills:
priority | skill | useWhen
```

Single-value and simple list fields use these Agent tab labels:

```text
Outcome -> outcome
Scope -> scope.included
Non-goals -> scope.excluded
Allowed paths -> paths.allowed
Do not touch -> paths.doNotTouch
Safety constraints -> safety.constraints
Privacy -> safety.privacy
Review focus -> reviewFocus
```

All list fields above use one item per line.

The editor accepts omitted trailing columns. For example,
`required | react-doctor | After frontend edits` maps to a required
recommended skill. Prefer explicit columns when agents generate the content so
round-tripping through the UI remains predictable.

Use `update_task` to write, replace, or clear the contract:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "agentExecution": {
      "outcome": "API retry behavior is covered by focused tests.",
      "validationPlan": [
        {
          "kind": "test",
          "command": "pnpm nx test api",
          "target": "api",
          "expectedEvidence": "Retry specs pass.",
          "required": true
        }
      ]
    }
  }
}
```

To clear the contract, send `"agentExecution": null`. To leave a legacy task
unchanged, omit `agentExecution` from the update payload.

Valid blocker shapes:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "blockers": [
    { "ticketNumber": "ABC-10", "workspace": "workspace-alpha" },
    { "ticketNumber": "ABC-11", "workspace": "workspace-alpha" }
  ]
}
```

```json
{
  "id": "665f1f77bcf86cd799439011",
  "blockers": []
}
```

## Notes Rule

TaskForge uses `Notes` as the single product and MCP term.
Use `append_task_note` for all ticket note writes.

Notes are append-only comments with `note`, optional `actor`, and optional
`actorName`. They are for human-readable context rather than structured test
evidence. Use notes for implementation context, tradeoffs, reviewer handoff
details, blocker explanations, follow-up ideas, links to relevant artifacts, or
why an expected screenshot/validation could not be captured.

Do not use notes as a replacement for validation records when a command, smoke
test, unit test, browser test, or manual verification has a clear pass/fail
outcome. Do not rewrite note history through `update_task`; append a new note
with the correction or added context.

Useful `append_task_note` shape:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "note": "Attached final desktop, tablet, and mobile screenshots for the updated ticket detail view."
  }
}
```

Send `payload` as an object. The MCP server also accepts a JSON object string
for compatibility with clients that stringify nested tool arguments, but agents
should prefer the structured object form.

## Validation Rule

TaskForge uses `Validation` for structured check records that should stay
separate from notes.
Use `append_task_validation` when the payload needs `tool`, `status`, and
`summary` fields, or when the record represents code verification rather than
discussion context.
Validation statuses are exactly `passed`, `failed`, `warning`, and `skipped`.
Do not send alternate labels such as `pass`, `fail`, `green`, `red`, `success`,
or `error`.

Validation records have this structure:

- `tool`: short tool or method name, such as `pnpm nx test`, `playwright`,
  `browser-smoke`, `manual-smoke`, `typecheck`, `lint`, or `unit-tests`.
- `status`: one of `passed`, `failed`, `warning`, or `skipped`.
- `summary`: concise result, max one sentence.
- `command`: optional exact command that was run.
- `target`: optional file, route, viewport, project, package, or feature area.
- `details`: optional extra evidence, output summary, failure reason, or skip
  rationale.

Record validation notes for smoke tests, CLI tests, unit tests, browser checks,
typechecks, lint checks, build checks, manual QA, and any skipped validation
that a reviewer should know about. Use `passed` for clean checks, `failed` for
checks that failed and still need attention, `warning` for partial or degraded
evidence, and `skipped` when a check was intentionally not run or could not run
in the current environment.

For UI work, record a browser or manual smoke validation after final screenshots
are captured. Mention attached screenshot filenames in `details` when useful;
the screenshots themselves should be uploaded with `upload_task_attachment`.

For reference-aware validation reads and writes, prefer `ticketNumber` when the
user names a ticket in chat and you do not already have a fresh TaskForge `id`.
Include `workspace` when the user provides it or when you want the extra scope guard.

Useful `append_task_validation` shape:

```json
{
  "ticketNumber": "NEX-12",
  "workspace": "workspace-alpha",
  "payload": {
    "tool": "shellcheck",
    "status": "passed",
    "summary": "ShellCheck passed for scripts/provision-preview.sh",
    "target": "scripts/provision-preview.sh",
    "command": "shellcheck scripts/provision-preview.sh"
  }
}
```

Useful `append_task_commit_reference` shape:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "commitHash": "0123456789abcdef0123456789abcdef01234567",
  "branchName": "master"
}
```

Useful `get_task_validations` shape:

```json
{
  "ticketNumber": "NEX-12",
  "workspace": "workspace-alpha"
}
```

## Generalized Examples

Example location questions:

- "Should this go in `workspace-alpha` or `workspace-beta`?"
- "Inside that workspace, is this owned by `core-platform` or `edge-ops`?"
- "Should I tag the service as `web`, `api`, or leave it unassigned?"

Example review requests:

- "Show all blocked tasks in `workspace-alpha`."
- "Find tasks matching `export` in `workspace-beta`."
- "Show archived tasks for `workspace-alpha` with `includeArchived: true`."
- "Get the history for ticket `ABC-42`."
- "Show validation records for ticket `ABC-42`."

## Guardrails

- Prefer `list_workspaces` before asking the user to pick a workspace when you need current choices.
- For task and epic creation, treat each workspace record's `systems` and `services` arrays as authoritative.
- Ask before creating if workspace is missing.
- Ask before creating a task if no epic is specified. Ordinary tasks must always have `epicId`.
- Do not clear a task's `epicId`. Move it to another epic instead.
- Keep examples generic; never hard-code organization-specific workspace names into reusable instructions.
- Use `create_epic` for standalone epics and for the first step of epic-plus-task creation; then create child tasks separately with `create_task`.
- Avoid `create_epic_tree` and `create_task_tree` unless the user explicitly asks for a tree shortcut and the target runtime supports it.
- Do not set or infer ticket prefixes. TaskForge generates task prefixes from the workspace slug and epic prefixes as `EPIC`; `system` remains routing metadata.
- Prefer `append_task_note` over `update_task` when the request is just adding extra ticket context.
- Prefer `append_task_validation` over `append_task_note` when recording structured validation results.
- Prefer `append_task_commit_reference` after committing task work so TaskForge can resolve GitHub links from the workspace repository URL. Write the commit message according to the Task Commit Message Rule first.
- Never send `notes` through `update_task`; use `append_task_note` so notes are always appended.
- Never use `get_task` + `update_task` as a note append workflow.
- Agents should add notes to tickets when they learn important implementation context, tradeoffs, blockers, reviewer feedback, or follow-up details that should stay attached to the work item.
- Use `get_task_history` when ticket ownership or recent edits are in question instead of guessing from the current state.
- Use `get_task_validations` when the user asks what checks ran, what passed or failed, or whether the task was validated.
- For status-only moves, prefer `update_task_status` over `update_task`.
- Agents must not move a ticket directly from `in_progress` to `done`. Finished
  agent work goes to `review`; after moving it, tell the user the task has been
  put into review and that no further action is needed.
- Tickets may move to `done` only from `review`, and only when that completion
  step is explicitly requested by the user or TaskForge.
- Blocked tickets cannot move directly to `done`. First move the ticket out of
  `blocked` to the appropriate live lane, then use the normal `review` -> `done`
  path once review is complete.
- Treat `status: "blocked"` as agent-ineligible. Agents may mark tickets
  blocked, but once a ticket is blocked, an agent must not work it again until a
  human unblocks it by moving it to a non-blocked status.
- Treat unfinished blocker tickets as agent-ineligible even when the dependent
  ticket's own status is not `blocked`. A dependent task or epic may be worked
  only after all blocker tickets are `done` or `finalized`; re-read the
  execution packet before starting.
- When a user names a ticket like `NEX-12`, prefer `ticketNumber + workspace` over an old cached internal `id` for reference-aware tools such as `update_task_status`, `get_task_history`, `get_task_validations`, `append_task_note`, `append_task_validation`, and `append_task_commit_reference`.
- After a task-prefix migration, the requested ticket may be an alias. Accept
  the API's canonical task when `ticketAliases` contains the normalized
  requested ticket, and continue using the canonical ticket returned by the
  API for display and subsequent evidence.
- Never set `ticketNumber` during ordinary task creation. TaskForge allocates
  it from the owning workspace slug; manual values bypass workspace prefix and
  counter safeguards.
- Prefix migrations must follow the dry-run-first procedure in
  `docs/migrations/task-prefix-alias-runbook.md`. Do not apply without an exact
  workspace/system scope, zero-collision evidence, a verified backup, a write
  guard or maintenance window, an apply artifact, and explicit human approval.
- A prefix migration changes only canonical task numbers and aliases. Do not
  rewrite historical prose, branch names, commit references, event history,
  `projectContext`, `branchContext`, or Jira references.
- Archived work is a status, not a deletion flow. Use `status: "archived"` to archive and a live status to restore.

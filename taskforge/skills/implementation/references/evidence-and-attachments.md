# Evidence and attachments

Read this reference before writing Notes, Validation, commit references, or
attachments.

## Markdown and Notes

Use Markdown for descriptions, goals, acceptance criteria, Notes, and similar
prose. Keep identifiers, commands, paths, and ticket terms exact. Do not wrap
Markdown in HTML or a fenced block unless the content is code.

Notes are TaskForge's single term for append-only human-readable context. Use
`append_task_note` for:

- implementation context, tradeoffs, or reviewer handoff;
- blocker evidence, owner, and resume condition;
- follow-up ideas or artifact links;
- why a planned check or screenshot was unavailable.

Do not put structured pass/fail evidence in Notes, write them through
`update_task`, or reconstruct an append from a read. Append corrections.

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "note": "Attached final desktop, tablet, and mobile screenshots."
  }
}
```

Prefer a structured `payload` object. JSON object strings exist only for older
client compatibility.

## Validation

Use `append_task_validation` for checks with a clear result. Always wrap fields
inside `payload: { ... }` (never pass top-level `tool`, `status`, or `summary`
fields). Status is exactly `passed`, `failed`, `warning`, or `skipped`; aliases
such as `pass`, `success`, or `error` are invalid, and `summary` must be `<= 280`
characters.

- `tool`: short tool or method name.
- `status`: one allowed status (`passed | failed | warning | skipped`).
- `summary`: one concise result sentence (`<= 280` chars).
- `command`: optional exact command.
- `target`: optional file, route, viewport, project, package, or feature.
- `details`: optional evidence, failure reason, or skip rationale.

Record tests, smoke, browser, typecheck, lint, build, doctor, debugger, review,
and manual checks (note that in `validationPlan[]`, `kind` must be one of
`test | lint | build | doctor | browser | debugger | review | manual`). Use
`warning` for partial evidence and `skipped` for an intentional or unavailable
check. Never claim a check ran when it did not.

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "tool": "shellcheck",
    "status": "passed",
    "summary": "ShellCheck passed for scripts/provision-preview.sh.",
    "target": "scripts/provision-preview.sh",
    "command": "shellcheck scripts/provision-preview.sh"
  }
}
```

For UI work, record browser or manual smoke after final screenshots. Mention
attachment names when useful, but upload files instead of embedding bytes. Use
`get_task_validations` to answer which checks ran.

## Commit references

After creating and verifying a commit, append its evidence using exact keys
`commitHash` and `branchName` (never `commit` or `branch`):

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "commitHash": "0123456789abcdef0123456789abcdef01234567",
  "branchName": "taskforge/task/ABC-12-example"
}
```

Follow repository commit and branch rules first. A commit reference neither
approves a merge nor changes status.

## Attachments

Use attachments for durable reviewer files such as screenshots, logs, reports,
exports, and small artifacts. Use only `upload_task_attachment`,
`list_task_attachments`, `read_task_attachment`, and
`delete_task_attachment`. The API owns storage settings, path safety, and
provider metadata.
Never access attachment storage or MongoDB directly, or send provider
credentials through tool payloads.

Before upload:

1. Confirm canonical ticket and workspace.
2. Use an absolute local `filePath` within runtime size and type limits.
3. Inspect the file for secrets, tokens, cookies, raw session data, provider
   payloads, broad PII, or unrelated browser state.
4. Confirm screenshots show the intended state, not a blank or login page.
5. Use a clear filename and optional description.
6. Upload each file separately.
7. Add a Note or Validation only when the artifact needs context.

For UI work, capture desktop, tablet, and mobile final states when practical;
for a visual bug, capture before and after. Record unavailable secondary
evidence without blocking the task solely for that reason.

Resolve attachment ids from fresh TaskForge data. Never guess storage paths or
construct URLs. `read_task_attachment` may return metadata only for binary or
large files.

Delete only on explicit user request or when the workflow clearly authorizes
removal of a known error. Supply exact `attachmentId` and either task `id` or
`ticketNumber + workspace`. Filename-only deletion is unsupported. Deletion
does not rewrite related evidence; append a correction when needed.

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "filePath": "/absolute/path/to/ABC-12-final-desktop.png"
}
```

Never upload environment or credential exports, browser profiles, cookie
stores, raw authentication/session responses, private key material,
unredacted customer data, unrelated repository archives, or raw
prompt/provider traces.

## Corrections and sanitation

When implementation changes after evidence:

1. Treat affected Validation, verdicts, screenshots, and reports as stale.
2. Append a correction for the new exact revision.
3. Rerun invalidated checks and capture fresh visible evidence.
4. Obtain any fresh review required by the execution contract.

Never edit history to make evidence current. Keep TaskForge evidence free of
credentials, secrets, cookies, short-lived handoff URLs, raw session ids,
provider payloads, unrelated browser state, broad PII, and tenant-ambiguous
data. API-key and browser-secret handling is owned by
[auth-browser-and-identity.md](auth-browser-and-identity.md).

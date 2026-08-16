# Evidence and attachments

Read this reference completely before writing Notes, Validation, commit
references, or task attachments.

## Contents

- Markdown fields
- Notes
- Validation
- Commit references
- Attachments
- Correction and privacy rules

## Markdown fields

Use Markdown for human-authored descriptions, goals, acceptance criteria, Notes,
and similar long-form text. Keep identifiers, commands, paths, and ticket terms
exact. Do not wrap Markdown in HTML or a fenced block unless the content itself
is code.

Use short paragraphs and lists only when they improve scanability. Do not paste
raw command dumps when a concise result and exact command are sufficient.

## Notes

`Notes` is the single TaskForge term for append-only human-readable context. Use
`append_task_note` for:

- implementation context and tradeoffs;
- blocker explanations;
- reviewer handoff details;
- follow-up ideas;
- links to relevant artifacts;
- reasons a planned check or screenshot could not be captured.

Do not use Notes for structured pass/fail evidence. Do not write Notes through
`update_task`, and do not reconstruct appends with `get_task` plus
`update_task`. Append a correction rather than rewriting history.

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "payload": {
    "note": "Attached final desktop, tablet, and mobile screenshots for the updated ticket detail view."
  }
}
```

Send `payload` as an object. A JSON object string may exist for older client
compatibility, but generated calls should prefer the structured object.

## Validation

Use `append_task_validation` for checks with a clear result. Valid statuses are
exactly:

- `passed`
- `failed`
- `warning`
- `skipped`

Do not use aliases such as `pass`, `fail`, `green`, `red`, `success`, or
`error`.

Fields:

- `tool`: short tool or method name.
- `status`: one allowed status.
- `summary`: one concise result sentence.
- `command`: optional exact command.
- `target`: optional file, route, viewport, project, package, or feature.
- `details`: optional evidence summary, failure reason, or skip rationale.

Record unit, integration, smoke, browser, typecheck, lint, build, doctor,
debugger, review, and manual checks. Use `warning` for partial evidence and
`skipped` when the check was intentionally not run or unavailable. Never claim
a check ran when it did not.

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

For UI work, record browser or manual smoke evidence after final screenshots.
Mention attachment filenames in `details` when useful; upload the files rather
than embedding their bytes in Validation.

Use `get_task_validations` when the user asks which checks ran or whether work
was validated.

## Commit references

After creating and verifying a commit, append its reference:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "commitHash": "0123456789abcdef0123456789abcdef01234567",
  "branchName": "taskforge/task/ABC-12-example"
}
```

Use the repository's commit convention and branch contract first. A commit
reference is evidence; it does not approve a merge or change ticket status.

## Attachments

Use attachments for durable files a reviewer needs, including screenshots,
logs, reports, exports, or small artifacts that do not fit a Note or Validation.
Use `upload_task_attachment`, `list_task_attachments`,
`read_task_attachment`, and `delete_task_attachment`; never access attachment
storage or MongoDB directly. The API owns provider settings, path safety, and
per-attachment provider metadata. Do not configure provider credentials through
tool payloads.

Before upload:

1. Confirm the canonical ticket and workspace.
2. Use an absolute local `filePath`.
3. Confirm the file is within the permitted size and type for the runtime.
4. Inspect the file for secrets, tokens, cookies, session ids, raw provider
   payloads, broad PII, or unrelated browser state.
5. Verify screenshots show the intended state rather than a blank or login page.
6. Use a clear filename and optional description.
7. Upload each intended file separately with `upload_task_attachment`.
8. Record a Note or Validation only when context or a result needs explanation.

For web UI work, capture desktop, tablet, and mobile final states when practical.
For a visual bug, attach before and after evidence when available. If a viewport
or screenshot cannot be captured, record the limitation without blocking work
solely for unavailable secondary evidence.

For list, read, download, or delete operations, resolve the ticket and attachment
identifier from fresh TaskForge data. Do not guess storage paths or construct
attachment URLs manually.

If the attachment id is unknown, call `list_task_attachments`. Use
`read_task_attachment` for safe text-like content; binary or oversized files may
return metadata only.

Delete an attachment only when the user explicitly requests it or the workflow
clearly authorizes removal of a known error. `delete_task_attachment` requires
the exact `attachmentId` plus either task `id`, or `ticketNumber + workspace`.
Filename-only deletion is unsupported because displayed names may collide. Do
not infer the task from a filename. Deletion does not rewrite related Notes or
Validation; append a correction when needed.

Example upload:

```json
{
  "ticketNumber": "ABC-12",
  "workspace": "workspace-alpha",
  "filePath": "/absolute/path/to/ABC-12-final-desktop.png"
}
```

Do not upload:

- environment files or credential exports;
- browser profiles or cookie stores;
- raw authentication or session responses;
- private keys or certificates containing private material;
- unredacted customer datasets or broad PII;
- unrelated repository archives;
- raw prompts or provider traces containing sensitive context.

## Correction and privacy rules

When implementation changes after evidence was recorded:

1. Treat affected Validation, reviewer verdicts, screenshots, and reports as
   stale for acceptance.
2. Record the correction against the new exact revision.
3. Rerun every invalidated check.
4. Capture fresh artifacts when visible behavior changed.
5. Obtain any fresh review required by the execution contract.

Never edit evidence to make it appear current. Append new evidence and identify
the exact target revision.

Keep all evidence sanitized. Never place credentials, raw secrets, cookies,
short-lived handoff URLs, raw session identifiers, raw provider payloads,
unrelated browser state, broad PII, or tenant-ambiguous data in TaskForge.

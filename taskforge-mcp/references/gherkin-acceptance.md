# Gherkin acceptance specifications

Read this reference only when a task or epic `gherkinSpec` is authored,
updated, or reported by an execution packet during implementation or merge
validation. Also load the execution, evidence, and branching references for
the action.

## Scope and storage

Tasks and epics support one optional top-level `gherkinSpec`. Use the
`gherkin-spec` skill to author a complete `.feature`-style document, then
store it through normal TaskForge tools.

The v1 field is opaque text. TaskForge stores and returns it but does not parse
it, generate tests, select a runner, or infer a command.

- Include `gherkinSpec` in task, epic, and tree creation.
- Replace it with `update_task` or clear it with `null`. Blank editor content
  normalizes to `null`; omission preserves it.
- Keep it separate from `acceptanceCriteria` and `agentExecution`.
- Execution packets return only `hasGherkinSpec` and
  `gherkinSpecSha256`.
- Use `get_task_gherkin_spec` after familiarization for content. At merge,
  use `includeContent: false` to recheck metadata only.

## Authoring and overflow

The shared `TASK_GHERKIN_SPEC_MAX_LENGTH` is 20,000 JavaScript string
characters. Aim for at most 18,000. Measure the trimmed document; never silently
truncate, split a scenario, or retry the same oversized payload.

Split oversized behavior coherently: keep cross-cutting outcomes on the epic and
focused Feature/Scenario documents on child tasks. Prefer Scenario Outlines
when repeated examples cause excess. If behavior cannot split cleanly, store a
short bounded index in `gherkinSpec` and the full `.feature` as a repository
file or text attachment. Record the decision in a Note.

For continuation tasks:

1. Keep the original as implementation parent.
2. Create `Gherkin: <original title>` in the same epic; use `Gherkin 2:` and
   increment only when needed.
3. Put only overflow Feature/Scenario content in the continuation.
4. Note the split boundary and parent on both tasks.
5. Block the continuation on the original; never block the parent on its
   continuation.
6. After the parent closes, apply the lifecycle blocked-ticket decision before
   activating the continuation. `review` does not satisfy blocker eligibility.

## Executable mapping

Run a Gherkin command only when a nonblank spec has a
`kind: "test"` validation item whose `target` starts with `gherkin:` and
whose `command` is the exact repository-supported runner:

```json
{
  "kind": "test",
  "target": "gherkin: checkout acceptance",
  "command": "<repository-supported Gherkin runner command>",
  "expectedEvidence": "The named checkout scenarios pass.",
  "required": true
}
```

Do not infer `pnpm test`, Cucumber, Playwright, or a feature-file command from
scenario text. A nonblank spec without a mapping still receives the inspection
below but no synthetic test. A required mapping without a runnable command is
an incomplete contract; do not merge until the owner supplies or changes it.

## Familiarization checkpoint

The packet announces Gherkin without spending the full document's context
before source orientation:

1. Read the execution packet. If `hasGherkinSpec` is false, stop.
2. Resolve branch, source owners, and the implementation plan.
3. Before substantive implementation, call `get_task_gherkin_spec` once with
   default `includeContent: true`. Retain its digest in active task context
   and use the scenarios to guide code and tests.
4. Do not reread on each edit, check, status update, or merge retry. Read again
   only after a digest change or when a new agent lacks active task context.

## Merge-validation checkpoint

Run at most once for each unchanged candidate:

1. Read the fresh task or epic packet at the normal merge checkpoint.
2. If `hasGherkinSpec` is false, stop without a skill, runner, lookup, or
   Gherkin Validation.
3. Compare the digest with familiarization. Fetch content only if it changed or
   active context is unavailable.
4. Inspect every Feature and Scenario against implementation, approved scope,
   and current evidence. Append `gherkin-acceptance-inspection` Validation
   with source commit, digest, covered scenarios, and unresolved behavior.
   Reuse it only while source and digest match.
5. Run a declared mapping once and append separate `gherkin-acceptance`
   Validation. Invent no command.
6. On failure, do not preflight or merge. Return to `in_progress` and repair
   in-scope behavior without another confirmation. Ask only for a new contract,
   scope/path expansion, destructive action, or human-owned decision. Repeat
   only for a new candidate commit or spec.

Run a branch-bound child checkpoint after `review` and before merge preflight;
an epic checkpoint during integrated Validation before `review`; and a
branchless checkpoint before explicit `review -> done`. Initiatives have no
`gherkinSpec` and add no duplicate run.

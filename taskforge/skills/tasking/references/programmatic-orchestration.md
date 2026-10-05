---
doc_owner: codex
doc_type: process-note
created_at: 2026-08-28
updated_at: 2026-09-07
last_verified: 2026-08-30
source_scope:
  - skills/taskforge/skills/**
  - skills/taskforge/references/programmatic-orchestration.md
  - mcp-server/src/lib/mcp-programmatic-read.ts
  - mcp-server/src/lib/mcp-programmatic-epic-tree.ts
  - mcp-server/src/main.ts
---

# Programmatic MCP orchestration

Use this overlay only when the connection advertises its required capability.
It reduces deterministic read context and can submit one validated epic tree;
it does not replace ordinary approval, evidence, or workflow gates.

## Capability gate

- `taskforge/programmatic-read` is read-only. Use it for bounded listing,
  search, cursor pagination, filtering, comparison, measurement, and reduction
  of loaded pages. Missing or malformed capability means use direct compact
  reads.
- `taskforge/programmatic-epic-tree` can submit one side effect. Use it only
  for one validated `create_epic_tree` after model-led decomposition and
  workflow checks. Without it, use explicit create calls.
- Capabilities are fixed for the connection. Never infer them from client,
  model, workspace, service, or tool name, or rediscover unavailable
  capabilities mid-session.

## Route selection

Use programmatic read only for reducible collection work. Use direct
purpose-built reads for an exact record, packet, history, Validation,
attachments, project context, or session health.

Keep side effects model-visible: authoring, updates, status, blockers, labels,
plans, Notes, Validation, attachments, browser sessions, and branch operations.
The only overlay exception is one capability-gated epic-tree write.

Approval, branching, status, Gherkin, Validation, commit, merge, and final
review decisions remain direct. An overlay cannot approve, select an owner, hide a dependency,
or apply a follow-up write. Cross-epic blockers from a tree receipt remain
explicit `add_task_blockers` calls.

Use generic direct-handoff values:

```text
workspace: <workspace-slug>
service: <service-name>
projectPath: <project-path>
targetBranch: <target-branch>
model: <model>
```

## Bounds

Choose the lowest limit that covers the request. The connector clamps pages,
items, text, and receipt previews; the client enforces concurrency and output:

| Surface | Default | Hard bound |
| --- | ---: | ---: |
| Items per page | 25 | 100 |
| Pages per read | 20 | 100 |
| Selected items per read | 250 | 1,000 |
| Page text input | — | 2,000,000 UTF-8 bytes |
| Independent reads in flight | 1 | 4 |
| Side-effecting writes in flight | 1 | 1 |
| Compact read result for 25 rich records | — | 7,500 model-visible bytes |
| Child or failure previews in a receipt | — | 20 items |

Cursor pagination is sequential. Do not parallelize dependent reads or run
concurrent writes. At a page, item, cursor, or output limit, return the bounded
envelope and status instead of expanding the result.

## Write outcomes and recovery

Programmatic writes have no automatic retry path. Do not resubmit a tree after
a timeout, transport error, disconnect, restart, malformed response, or other
uncertain result. The same rule applies to direct writes initiated from an
overlay.

1. Stop the write lane.
2. Reconcile through fresh read-only calls that identify the requested parent
   and children; never probe with another write.
3. If confirmed, consume the receipt and continue once.
4. If reconciliation returns `not_found` and says a retry may be considered,
   request current explicit approval for that exact new write. One direct call
   may follow; approval does not authorize a loop.
5. Keep unresolved reconciliation blocked with owner and resume condition.

For `merge_task_branch`, consume compact `outcome`, `recovery`, `task`,
and `merge`. `merged` and `already_merged` are proof only with merge data.
A raw no-change receipt is not authority. Its private continuation must combine
the applied exact `action: "already_merged_no_change"` receipt with a fresh
persisted task read and match task id, epic id, workspace, source, target,
`noChangeSourceCommitSha`, and `branchBaseCommitSha`. Any mismatch stops the
overlay. `blocked`, `planned`, and `reconciliation_required` return control
to the direct branch workflow.

Never retry a merge or tree because a receipt is missing, partial, or unknown.
Reconcile first and preserve every returned 40-character merge SHA.

Read [discovery.md](discovery.md) for capabilities,
[lifecycle.md](lifecycle.md) for status and completion,
[evidence-and-attachments.md](evidence-and-attachments.md) for evidence, and
[branching-and-approvals.md](branching-and-approvals.md) for branch decisions.

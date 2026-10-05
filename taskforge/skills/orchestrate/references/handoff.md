# Workflow handoff

Carry only the context the next authorized workflow needs:

- the user's request, allowed scope, exclusions, and selected workflow;
- authoritative server, workspace, and canonical record IDs when applicable;
- artifact path, exact base/head revisions, and specification digest when used;
- actual check results, stale evidence, unresolved blockers, and decision owners;
- the next permitted action and the condition that allows it.

Identify the owning checkout and branch for pending edits, the exact candidate
and reusable evidence, and any process still running with its responsible owner.
Reconcile these with the receiving workspace before a write or status change.
Distinguish resuming existing work from starting a new branch; follow the
branching gates rather than recreating branches or patching ledger context to
make a stale handoff fit. A launched process is an in-progress handoff, not a
completed validation result.

This is a conceptual handoff, not an API schema or a new durable TaskForge field.
Refresh packets after mutations or evidence changes. A chat summary never replaces
current branch context, persisted proof, or the user's approval message. Do not
serialize a Boolean as approval. Omit credentials, raw sessions, and private data.

Direct specialists return to their caller; they never recursively invoke
orchestrate. Selecting a workflow does not grant permission for its side effects.
General delegation does not activate a repository-owned host-specific routing
adapter.

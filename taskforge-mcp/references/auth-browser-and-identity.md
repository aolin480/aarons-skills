# Authentication, browser sessions, and identity

Read this reference completely before checking actor identity, reasoning about
authorization, or automating a protected TaskForge page.

## Contents

- Human-owned agent identity
- API authorization contract
- Session health
- Agent browser session workflow
- Verification after auth changes

## Human-owned agent identity

TaskForge agents authenticate as users for audit history, but each agent belongs
to a human user. Treat the MCP agent as the human owner's sub-user, not an
independent root account.

- Each developer registers a separate TaskForge agent under their own account
  and configures its one-time secret as `TASKFORGE_API_KEY`.
- Do not share one agent credential across a team.
- MCP-created tickets are attributed to the authenticated agent.
- The web board's `Mine` scope includes tickets created by the signed-in human
  and that human's owned agents, including disabled historical agents.
- Do not infer creator-family ownership from assignment, source labels, display
  names, or usernames. The API owns that relationship.
- `list_tasks` and `search_tasks` are team-wide queries, not the board's `Mine`
  filter.

## API authorization contract

The NestJS API owns authentication and permission decisions. The MCP server is
an authenticated API client. Do not copy roles, scopes, route rules, or business
authorization into MCP tool handlers.

- Send `TASKFORGE_API_KEY` only in the TaskForge agent-auth header.
- Never put the key in output, URLs, Notes, Validation, attachments,
  screenshots, logs, or errors.
- A configured key is not proof of sufficient permission.
- Read tools normally require `tasks:read`.
- Task and planning mutations normally require `tasks:write`.
- Administrative lifecycle operations require `tasks:admin`.
- Task scopes include workspace discovery needed for task routing; they do not
  grant user, workspace-management, or settings-management permissions.
- Let API authorization metadata and its default-deny guard decide access.
- Do not add optimistic allowlists, bypasses, fallback credentials, or retries
  using another authentication mode.
- Preserve the distinction between unauthenticated `401` and authenticated but
  under-scoped `403`. Do not convert either to a successful empty result.

`/auth/session` and `/auth/agent-browser-sessions` have specialized guard
handling. They are not public: each route owner validates the supplied agent
credential.

## Session health

Use `get_session_health` to inspect the current actor and scopes without
exposing the key. It intentionally reports a failed identity lookup as
`authenticated: false` without returning credential or response details.

Call it when:

- the selected TaskForge server is uncertain;
- authentication is uncertain;
- the actor or scope coverage matters;
- browser session creation is planned;
- a `401` or `403` needs diagnosis.

Never infer authentication from a successful stale client call or from the
presence of a local environment variable alone.

## Agent browser session workflow

Before a browser opens a protected TaskForge page:

1. Call `get_session_health`. Confirm authentication and inspect `webBaseUrl`
   and `webBaseUrlConfigured` without reading protected secret files.
2. Call `create_agent_browser_session` with the original same-origin path in
   `redirectPath`, including its query string. If omitted, the handoff lands on
   `/` rather than the requested workspace page.
3. Navigate the same browser context to the returned `handoffUrl`.
4. Use origin precedence: explicit tool `webBaseUrl`, then
   `TASKFORGE_WEB_URL`, then `http://127.0.0.1:4411`.
5. Mint a new session when switching browser tools, profiles, or contexts.
6. Attempt this flow before asking a human to log in.

Never put `TASKFORGE_API_KEY` in a URL. Never record the short-lived session id
or handoff URL in tickets, logs, screenshots, or Validation.

`TASKFORGE_AGENT_BROWSER_SESSION_SECRET` belongs only to the API runtime. Never
put it in MCP client configuration. The MCP client uses the agent's
`TASKFORGE_API_KEY`, not the signing secret or a human password.

## Verification after auth changes

After changing an API route, permission annotation, authentication contract, or
MCP API mapping:

1. Run the focused MCP tests and build.
2. Exercise one allowed request.
3. Exercise representative `401` and `403` paths.
4. Rebuild and reconnect the MCP client before judging live behavior so a stale
   process does not mask the current contract.
5. Record sanitized results as Validation.

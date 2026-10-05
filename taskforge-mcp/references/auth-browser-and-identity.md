# Authentication, browser sessions, and identity

Read this reference before checking actor identity, diagnosing authorization,
or automating a protected TaskForge page.

## Human-owned agent identity

Agents authenticate as auditable users but belong to human owners.

- Each developer registers a separate agent and configures its one-time secret
  as `TASKFORGE_API_KEY`; never share one credential across a team.
- MCP-created tickets are attributed to the authenticated agent.
- The web board's `Mine` scope includes the signed-in human and that human's
  owned agents, including disabled historical agents.
- The API owns creator-family relationships. Do not infer them from assignment,
  source labels, display names, or usernames.
- `list_tasks` and `search_tasks` are team-wide, not the board's `Mine`.

## API authorization

The NestJS API owns authentication and permission. The MCP server is its
authenticated client; do not copy roles, scopes, route rules, or business
authorization into tool handlers.

- Send `TASKFORGE_API_KEY` only in the agent-auth header. Never put it in
  output, URLs, Notes, Validation, attachments, screenshots, logs, or errors.
- A configured key does not prove permission.
- Reads normally require `tasks:read`; task and plan mutations
  `tasks:write`; administrative lifecycle operations `tasks:admin`.
- Task scopes include workspace discovery for routing, not user,
  workspace-management, or settings-management permission.
- Let API metadata and its default-deny guard decide access. Do not add
  optimistic allowlists, bypasses, fallback credentials, or alternate-auth
  retries.
- Preserve unauthenticated `401` versus authenticated under-scoped `403`.
  Neither becomes a successful empty result.

`/auth/session` and `/auth/agent-browser-sessions` use specialized guards but
are not public; each route validates its supplied agent credential.

## Session health

Use `get_session_health` when the server, authentication, actor, scopes,
browser-session readiness, or a `401`/`403` is uncertain. It reports failed
identity lookup as `authenticated: false` without credential or response
details. Never infer auth from stale client success or environment-variable
presence.

## Browser session workflow

Before opening a protected page:

1. Call `get_session_health`; confirm authentication and inspect
   `webBaseUrl` and `webBaseUrlConfigured` without reading secret files.
2. Call `create_agent_browser_session` with the original same-origin path and
   query in `redirectPath`. Omitting it lands on `/`.
3. Open the returned `handoffUrl` in the same browser context.
4. Use the tool's explicit `webBaseUrl` or configured `TASKFORGE_WEB_URL`.
   If neither exists, report the gap; do not invent a local origin.
5. Mint a new session when changing browser tools, profiles, or contexts.
6. Try this flow before asking a human to log in.

Never put `TASKFORGE_API_KEY` in a URL. Never record the short-lived session id
or handoff URL in a ticket, log, screenshot, or Validation. The API-only
`TASKFORGE_AGENT_BROWSER_SESSION_SECRET` never belongs in MCP client config.
The client uses its agent API key, not the signing secret or a human password.

## Verification after auth changes

After an API route, permission annotation, auth contract, or MCP mapping change:

1. Run focused MCP tests and build.
2. Exercise one allowed request and representative `401` and `403` paths.
3. Rebuild and reconnect the client so stale runtime code cannot mask results.
4. Record sanitized Validation.

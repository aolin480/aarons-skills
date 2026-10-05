# Interactive planning questions

Use this reference for material questions during engineering planning. The
contract is host-agnostic: obey the active host's system and developer rules
for modes, tool purpose, permissions, and response format. A tool's presence
does not override those rules.

## When to ask

Ask only when the input materially affects the plan's scope, architecture,
strategy, requirements, product behavior, or preference and the choice cannot
be resolved from the supplied context, current repository evidence, or a safe,
low-risk judgment. Investigate the directly relevant source first. Eliminate
choices already settled by the user or context, and give the smallest useful
tradeoff context before asking.

Use the host's preferred native question mechanism when it is available and
permitted for this question. Otherwise use an inline decision block with the
fallback format below. Specific tool names and their priority belong to the
host adapter, not this ordinary workflow.

Determine capability from the active host's advertised tools and restrictions.
Never call or probe a user-facing question tool merely to discover whether it is
available. If a host requires another format, its rules govern the interaction.

Ask at most three questions in one interaction. For native questions, provide
two or three concise, meaningful options when possible. Make options mutually
exclusive unless multi-select is necessary. Put the recommendation first when
one choice is clearly better, and state the practical consequence of each
choice. Use the host-provided `Other` or free-form option; do not add a duplicate
custom option. If choices are equivalent, omit the recommendation and state the
factor the user must decide.

## Inline fallback

Use the following compact visual hierarchy when no usable native capability is
available. Render the example as Markdown in the conversation:

```markdown
❓ **Question 1 — <short topic>**

**<Full question?>**

⭐ **Recommended:** **A — <best choice>**\
<One sentence why.>

🥈 **Second choice:** **B — <second-best choice>**\
<One sentence when preferable.>

🔹 **Other options:**

- **C — <option>** — <brief tradeoff>

✍️ **You can also answer with your own preference.**

────────────────────────────────
```

Number questions in the interaction. Stable option labels such as `A`, `B`,
and `C` may support replies such as `1: A, 2: B, 3: custom`. Bold the full
question and each option name. Show only choices that exist: omit the second or
other-choice sections when they do not apply, and do not manufacture options or
a recommendation when choices are equivalent. Mark only an actual user decision
with `❓`. Put the separator at the bottom of every complete block; never place
an orphan separator before a question. Keep subsequent explanation after that
bottom separator. If useful, return only compact independent findings after an
inline question. Leave dependent plan sections until the user answers; do not
append a full speculative plan that chooses the unresolved behavior. If the
active host requires different fallback formatting, follow that host rule.
Before sending, verify the block has a complete bold question, bold selectable
option names with practical tradeoffs, the `✍️` free-form line even with only
two choices because inline fallback has no native `Other`, and the bottom
separator.

## Continue the plan around a question

Before asking, complete the bounded read needed to make the choice informed.
After asking, continue independent read-only investigation. Work that depends
on the answer waits for the actual user response; do not infer approval from an
arbitrary timeout, continuation, or an empty or cancelled response. A missing
answer remains pending and must carry an owner, impact, and resolution path.

When the user answers, record the question number, exact decision in concise
form, and provenance in the plan's settled-decisions record. Carry the answer as
a plan constraint or decision into subsequent work. Do not ask the same question
again unless current evidence has materially changed. Continue until the next
genuine decision or the plan is complete.

This interaction creates no TaskForge tickets or other records, changes no
status, implements no code, and activates no delegation or execution workflow.

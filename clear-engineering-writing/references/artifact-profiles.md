# Artifact Profiles

Read only the profile that matches the requested artifact. Combine profiles only when the artifact genuinely crosses categories.

## Pull requests and commit summaries

- Lead with the observable outcome.
- Explain why the change is needed.
- Describe the important implementation changes from the actual diff.
- Report only validation that was run.
- State material risk, compatibility impact, and rollback information when known.
- Follow the repository's PR or commit template when one exists.

Suggested PR sections: Summary, Why, Changes, Validation, Risk, Rollback. Omit empty or irrelevant sections.

## Documentation, READMEs, ADRs, and plans

- State the purpose and intended reader early.
- Define important terms before relying on them.
- Put the topic sentence first in each paragraph.
- Introduce one concept at a time, then add examples or implementation detail.
- Separate current behavior, proposed behavior, decisions, and future work.
- Use descriptive headings that tell the reader what the section contains.
- Distinguish verified facts from recommendations and unresolved questions.

## Procedures, runbooks, migrations, and troubleshooting

- Put prerequisites before dependent actions.
- Use numbered steps in execution order.
- Start each action with an imperative verb.
- Keep one primary action in each step.
- Put warnings before the hazardous or destructive action.
- Separate actions from expected results when that prevents ambiguity.
- Show commands as code, not inside dense explanatory paragraphs.
- Include verification and rollback steps when the procedure changes state.

## Presentations

- Give each slide one message.
- Use a conclusion-led title that states what the slide means.
- Keep on-slide copy brief; put explanation and nuance in speaker notes.
- Use short phrases when complete sentences add clutter.
- Keep terminology and claims consistent across slides.
- Build a narrative: context, problem, decision or approach, evidence, impact, next action.

## Release notes and change notices

- Start with user or operator impact.
- State required action, compatibility changes, and breaking behavior explicitly.
- Separate new behavior, fixes, deprecations, and known limitations.
- Avoid implementation detail unless readers need it to act.

## Reviews

- Identify unclear meaning, terminology drift, unsupported claims, missing actors, hidden conditions, and structural problems.
- Cite the exact passage or location when possible.
- Explain why the issue matters.
- Do not rewrite the artifact unless the user asks for a rewrite.

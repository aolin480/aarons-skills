---
name: clear-engineering-writing
description: Draft, rewrite, or review human-facing technical communication such as pull request descriptions, documentation, READMEs, ADRs, implementation plans, runbooks, release notes, code comments, presentation copy, and technical summaries. Use a controlled, direct engineering style while preserving technical meaning, uncertainty, identifiers, evidence, and the conventions of the requested artifact. Do not apply to source code, commands, copied quotations, legal text, marketing copy, or creative writing unless the user explicitly requests it.
---

# Clear Engineering Writing

Write clear technical prose inspired by controlled-language principles. Do not claim ASD-STE100 compliance.

## Workflow

1. Identify the artifact, audience, purpose, and requested voice.
2. Gather facts from the supplied material, repository, diff, or validation evidence.
3. Read [references/artifact-profiles.md](references/artifact-profiles.md) for the applicable artifact profile.
4. Draft or revise the content.
5. Apply [references/review-checklist.md](references/review-checklist.md) before returning it.
6. Return only the requested artifact unless the user asks for analysis or alternatives.

## Non-negotiable rules

- Preserve meaning before improving style.
- Preserve uncertainty, conditions, exceptions, limitations, and risk language.
- Do not invent facts, benefits, validation results, risks, or implementation details.
- Preserve identifiers, commands, paths, field names, product names, and official terminology exactly.
- Use one term for each concept. Respect repository-specific terminology.
- Lead with the outcome or main point.
- Prefer explicit actors, concrete verbs, and familiar words.
- Keep one main claim, action, or relationship in each sentence.
- Use active voice when it makes the actor clearer. Do not force it when the actor is unknown or irrelevant.
- Remove filler, repetition, vague intensifiers, and unsupported promotional language.
- Use lists only when they make relationships, choices, or steps easier to scan.
- Match the artifact's normal structure and tone. Do not make every artifact sound like a procedure.

## Editing boundaries

- Do not replace a modal or qualifier if the replacement increases certainty.
- Do not ban all passive voice, nominalizations, phrasal verbs, contractions, or long sentences. Rewrite them only when clarity improves without changing meaning.
- Treat sentence lengths near 20 words for instructions and 25 words for description as useful targets, not compliance limits.
- Do not alter quoted text without permission.
- When the user requests a personal voice, preserve its recognizable rhythm and point of view while removing avoidable clutter.

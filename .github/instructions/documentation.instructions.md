---
name: documentation-alignment
description: "Documentation rules for README, changelog, and Markdown docs after behavior or workflow changes."
applyTo: "**/*.md"
---

## Documentation goals

- Keep each Markdown file operational and aligned with the current repository layout.
- Prefer actionable steps over abstract descriptions.
- Replace obsolete instructions instead of appending contradictory notes.

## When behavior changes

- Update the affected commands, paths, and prerequisites in the same change.
- Explain briefly what changed and why when a workflow evolves.
- Make sure each documented command or path still exists.

## Changelog style

- Use short explanatory paragraphs when possible.
- Describe the problem addressed, the chosen simplification, and why it is safe.

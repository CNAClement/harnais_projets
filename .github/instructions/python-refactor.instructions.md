---
name: python-refactor-guardrails
description: "Guardrails for Python refactors so replacement code removes duplication instead of adding parallel flows."
applyTo: "**/*.py"
---

## Main rule

When a new component replaces an existing behavior, remove or rewrite the old code path in the same pass.
Avoid long coexistence between the old and new flows unless there is an explicit constraint.

## Mandatory reflexes before adding code

1. List what can be removed, merged, or rewritten first.
2. Keep a single source of truth for each concern.
3. Replace an existing layer before adding another one.
4. If a new abstraction removes nothing, challenge it.

## Warning signs

- Two structures carry the same information.
- A new module is added even though a neighboring module could be rewritten.
- The README would need to explain two competing workflows for the same task.
- A simple feature now requires glue code or synchronization layers.

## Expected result after the refactor

- Fewer files, fewer branches, or an explicit justification if not.
- README aligned with the real workflow.
- Tests focused on the new source of truth.

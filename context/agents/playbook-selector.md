# Playbook selector (Context Mesh)

## Mandatory rule (scope)

When the user’s request **may change application code, shell scripts, or anything under `context/`** (including creating or updating intent files and ADRs), the agent **must**:

1. **Classify** the work into **exactly one** of the playbooks listed below.
2. **Load and follow** that playbook from start to end (including its “FIRST” steps and artefacts).
3. If **two playbooks tie** or the goal is unclear, ask **one short** clarification (e.g. “Is this adding a new feature, updating one, fixing a bug, syncing context after implementation, or creating a reusable agent doc?”).

**Out of scope:** purely explanatory questions with **no** edits to repo or `context/` — use the normal context load list in [`AGENTS.md`](../../AGENTS.md) (e.g. `project-intent.md`, framework when needed); **do not** force playbook selection.

## How to classify

Use **intent**, not wording only. Typical signals (Portuguese / English):

| Situation | Signals (examples) | Playbook |
|-----------|---------------------|----------|
| **Add functionality** | Nova funcionalidade, novo comportamento nomeável / new feature, new capability | [playbook-add-feature.md](playbook-add-feature.md) |
| **Update functionality** | Atualizar feature, mudança planejada, refactor que mantém mesmo tema / update feature, revise acceptance, extend ADR same area | [playbook-update-feature.md](playbook-update-feature.md) |
| **Fix bug** | Bug, regressão, errado vs esperado / regression, defect, incorrect behavior | [playbook-fix-bug.md](playbook-fix-bug.md) |
| **Update context (Learn)** | Acabei de implementar, sincronizar context mesh, outcomes / Learn step, retrospective doc sync after code | [playbook-learn-update.md](playbook-learn-update.md) |
| **Create agent** | Criar agente reutilizável em `context/agents/` / new agent markdown, execution recipe for AI | [playbook-create-agent.md](playbook-create-agent.md) |

**Ambiguity:**

- Large refactor without a defect → usually **update feature** (+ new ADR if approach changes).
- User both implemented code **and** wants mesh synced → classify by **immediate primary ask**; if they want sync only, **learn update**; if they ask to implement plus learn, typically **implementing playbook first**, then **learn update** when they ask explicitly or in a second pass.

## Playbooks

- [Add feature](playbook-add-feature.md)
- [Update feature](playbook-update-feature.md)
- [Fix bug](playbook-fix-bug.md)
- [Learn / update context after implementation](playbook-learn-update.md)
- [Create agent](playbook-create-agent.md)

## Related

- [Context Mesh framework](../.context-mesh-framework.md)
- [AGENTS.md](../../AGENTS.md)

# Playbook: Create agent

I want to create a reusable agent for my Context Mesh project.

Agents are simple markdown files in context/agents/ that define how to execute specific tasks. They reference Context Mesh files (intent, decisions, patterns) and provide step-by-step execution instructions.

Key principle: Agents should REFERENCE context, not duplicate it. All details are in context files - agents just tell AI how to execute.

Please help me create an agent file.

Ask me:

1. What is the agent name? (e.g., "backend-api", "frontend-component", "database-migration")
2. What does this agent do? (one sentence purpose)
3. Which context files does it need? (feature intents, decisions, patterns)
4. What are the execution steps? (step-by-step what to do)
5. What does it produce? (outputs)

After I answer, create:

context/agents/agent-[name].md

Use this template:

---

AGENT-[NAME].MD TEMPLATE:

---

# Agent: [AGENT_NAME]

## Purpose

[One sentence - what this agent does]

## Context Files to Load

- @context/intent/feature-[name].md (if applicable)
- @context/decisions/[number]-[name].md (if applicable)
- @context/knowledge/patterns/[pattern].md (if applicable)

## Execution Steps

1. Load context files listed above
2. [Step 1 - what to do]
3. [Step 2 - what to do]
4. [Step 3 - what to do]
5. [Step 4 - what to do]

## Definition of Done

Technical criteria that must be met before this agent's task is complete:

- [ ] [Criterion 1 - e.g., Code compiles without errors]
- [ ] [Criterion 2 - e.g., Tests pass]
- [ ] [Criterion 3 - e.g., Context updated]

## Output

- [Output 1]
- [Output 2]

### Example Related (inside the new agent file)

- Feature: [if applicable]
- Decision: [if applicable]
- Pattern: [if applicable]

---

Remember: Keep it simple. Reference context files, don't duplicate their content.

## Related

- [Playbook selector](playbook-selector.md)
- [Context Mesh framework](../.context-mesh-framework.md)

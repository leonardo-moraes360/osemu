# Playbook: Update feature

I need to update an existing feature in this Context Mesh project.

**FIRST: Load framework context:**

- Load @context/.context-mesh-framework.md (if exists) to understand Context Mesh framework rules and file type separation
- Understand Plan, Approve, Execute pattern
- Understand when to create vs not create files

Then, analyze the existing @context/ files (feature intents, decisions) to understand the current state.

Then ask me:

**Feature Update:**

1. Which feature is being updated? (name or file)
2. What is changing?
3. Why is this change needed?
4. Do acceptance criteria change?

**Technical Decision:**

5. Does this need a new technical decision? (different approach)
   - If YES, ask:
     - Technical approach - What technical solution will be used?
     - Why this approach? (Rationale) - What are the reasons for choosing this approach?
     - What alternatives did you consider? - What other options were evaluated and why weren't they chosen?
     - Technical context - Any constraints, existing patterns, or dependencies that influence this decision?
6. Does the existing decision need to be updated? (same approach, but rationale/outcomes changed)
   - If YES, ask what needs to be updated in the existing decision

Then:

- Update context/intent/feature-[name].md with changes
  - Add "Changes from Original" section if relevant
  - Update "Related" section if links changed (ensure bidirectional links to decision files)
- Create context/decisions/[next-number]-[name].md if new technical approach
  - Include: Context, Decision, Rationale, Alternatives Considered, Related links, Status
  - Include "Related" section with bidirectional links:
    - [Project Intent](../intent/project-intent.md)
    - [Feature: [Feature Name]](../intent/feature-[name].md)
    - [Decision: Tech Stack](001-tech-stack.md) (if applicable)
- Update context/decisions/[existing-number]-[name].md if existing decision needs changes
  - Update "Related" section if links changed (ensure bidirectional links to feature files)
- Update changelog.md
- Update AGENTS.md (Feature-Specific Context section) if feature context changed

**Important**: Maintain bidirectional links between feature and decision files:

- Feature files must link to their decision files using format: `- [Decision: Name](../decisions/[number]-[name].md)`
- Decision files must link back to their feature files using format: `- [Feature: Name](../intent/feature-[name].md)`
- Use markdown link format: `- [Type: Name](path/to/file.md)`

Follow the pattern of existing files in @context/.
Remember: If creating a new decision, it should be complete with all sections (same quality as add-feature.md).

## Related

- [Playbook selector](playbook-selector.md)
- [Context Mesh framework](../.context-mesh-framework.md)

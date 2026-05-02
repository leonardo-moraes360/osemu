# Playbook: Add feature

Add a new feature to this Context Mesh project.

**FIRST: Load framework context:**

- Load @context/.context-mesh-framework.md (if exists) to understand Context Mesh framework rules and file type separation
- Understand Plan, Approve, Execute pattern
- Understand when to create vs not create files

Then, analyze the existing @context/ to check if this feature already exists:

- Check if feature-[name].md already exists in context/intent/
- If feature exists, inform me: "This feature already exists. Use update-feature.md to modify it, or choose a different name."
- If feature does NOT exist, proceed with the questions below.

Then ask me:

**Feature Information:**

1. Feature name
2. What it does and why we need it
3. Acceptance criteria

**Technical Decision (ADR):**

4. Technical approach - What technical solution will be used?
5. Why this approach? (Rationale) - What are the reasons for choosing this approach?
6. What alternatives did you consider? - What other options were evaluated and why weren't they chosen?
7. Technical context - Any constraints, existing patterns, or dependencies that influence this decision?

Then create:

- context/intent/feature-[name].md
  - Include "Related" section with bidirectional links:
    - [Project Intent](project-intent.md)
    - [Decision: [Feature Name]](../decisions/[next-number]-[name].md)
- context/decisions/[next-number]-[name].md (ADR required BEFORE implementing)
  - Include: Context, Decision, Rationale, Alternatives Considered, Related links, Status
  - Include "Related" section with bidirectional links:
    - [Project Intent](../intent/project-intent.md)
    - [Feature: [Feature Name]](../intent/feature-[name].md)
    - [Decision: Tech Stack](001-tech-stack.md) (if applicable and exists)
- Update context/intent/project-intent.md
  - Add new feature to "Related" section: [Feature: [Feature Name]](feature-[name].md)
- Update changelog.md
- Update AGENTS.md (Feature-Specific Context section)

Follow the pattern of existing files in @context/.
Remember: ADR must exist before implementation starts. The decision file should be complete with all sections.

**Important**: Create bidirectional links between feature and decision files:

- Feature files must link to their decision files using format: `- [Decision: Name](../decisions/[number]-[name].md)`
- Decision files must link back to their feature files using format: `- [Feature: Name](../intent/feature-[name].md)`
- Use markdown link format: `- [Type: Name](path/to/file.md)`

**Note**: After files are created, use the execution prompt with Plan, Approve, Execute pattern to implement.

## Related

- [Playbook selector](playbook-selector.md)
- [Context Mesh framework](../.context-mesh-framework.md)

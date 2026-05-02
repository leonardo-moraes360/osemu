# Playbook: Fix bug

I need to fix a bug in this Context Mesh project.

**FIRST: Load framework context:**

- Load @context/.context-mesh-framework.md (if exists) to understand Context Mesh framework rules and file type separation
- Understand Plan, Approve, Execute pattern
- Understand when to create vs not create files

Then, analyze the existing @context/ and ask me:

1. What is the bug? (brief description)
2. Expected vs actual behavior
3. Impact (critical, high, medium, low)
4. Root cause (if known)
5. Which feature is affected?

Then create:

- context/intent/bug-[name].md
- context/decisions/[next-number]-[name].md (only if fix requires significant technical change)
- Update changelog.md

Follow the pattern of existing files in @context/.

## Related

- [Playbook selector](playbook-selector.md)
- [Context Mesh framework](../.context-mesh-framework.md)

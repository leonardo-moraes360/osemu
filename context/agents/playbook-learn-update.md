# Playbook: Learn — update Context Mesh after implementation

I finished implementing and need to update the Context Mesh (Learn step).

**FIRST: Load framework context:**

- Load @context/.context-mesh-framework.md (if exists) to understand Context Mesh framework rules and file type separation
- Understand the Learn step purpose and what needs to be updated
- Understand file type separation rules

**THEN: Analyze automatically (do not ask questions yet):**

1. **Analyze @context/** to identify:
   - Which feature/bug intent files exist and their status
   - Which decision files are related to recent work
   - What was planned (from intent and decision files)

2. **Analyze the codebase** to identify:
   - What code was actually implemented (new files, modified files, recent changes)
   - Compare implementation with the plan (from context files)
   - Identify differences between plan and actual implementation

3. **Match implementation to context:**
   - Which feature/bug does the code correspond to?
   - Which decision files are relevant?
   - Did implementation follow the documented decisions?

**THEN: Present your analysis and ask only for subjective insights:**

Present your findings:

- ✅ What was implemented (based on code analysis)
- ✅ Which context files are related (based on code and context matching)
- ✅ Implementation vs Plan comparison (what matches, what differs)
- ✅ Technical observations (what you can see from the code)

**Ask only for insights I need to provide:**

1. What worked well? (subjective experience - what went smoothly)
2. What didn't work as expected? (surprises, issues, trade-offs you encountered)
3. Any lessons learned? (insights for future work)
4. Did you discover a reusable pattern? (if yes, describe it)
5. Did you discover something that doesn't work (anti-pattern)? (if yes, describe it)

**Then update automatically:**

- Mark feature/bug as complete in intent file (update Status)
- Add/update "Outcomes" section in decision file(s):
  - Format: "After Implementation" (what worked ✅, what didn't ⚠️, based on code analysis + my insights)
  - Format: "Lessons Learned" (insights for future)
  - Update Status section: Add "Updated: [DATE] (Phase: Learn) - Added outcomes"
- Update changelog.md with what was implemented
- Create context/evolution/learning-[name].md if significant learning
- Create context/knowledge/patterns/[name].md if pattern discovered
- Create context/knowledge/anti-patterns/[name].md if anti-pattern discovered
- Update AGENTS.md if feature context changed significantly

Follow the pattern of existing files in @context/.
Remember: Outcomes should be specific and actionable, following the format in existing decision files.

## Related

- [Playbook selector](playbook-selector.md)
- [Context Mesh framework](../.context-mesh-framework.md)

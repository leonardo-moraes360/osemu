# AGENTS.md

**Author:** Leonardo Moraes · **License:** [MIT](LICENSE)

## Setup Commands

There is no language package manager for this repo. Prerequisites are system packages.

- Check QEMU tools: `qemu-img --version`, `qemu-system-x86_64 --version`
- Ensure scripts are executable: `chmod +x qcow2.sh emu.sh`
- Run converters/emulator: `./qcow2.sh <path-to-raw> <output_dir>`, `./emu.sh <cdrom> <path-to-qcow2>`

Optional: KVM access on Linux (`/dev/kvm`); QEMU will behave differently without virtualization.

## Code Style

- Bash for `qcow2.sh` and `emu.sh`.
- Follow patterns from `@context/knowledge/patterns/` — especially [`shell-script-style-cst8177.md`](context/knowledge/patterns/shell-script-style-cst8177.md).

## Context Files to Load

Before starting work, load:

- `@context/agents/playbook-selector.md` when the request **may change** scripts, repo code, or anything under `@context/` (classify → follow exactly one linked `playbook-*.md` there; purely explanatory asks with **no** repo edits omit this rule)
- `@context/intent/project-intent.md` (always)
- `@context/intent/feature-*.md` when changing a specific feature area
- `@context/decisions/*.md` relevant to the change
- `@context/knowledge/patterns/*.md` that apply to shell work
- [`@context/knowledge/references-qemu.md`](context/knowledge/references-qemu.md) when QEMU flags, formats, or system emulation behavior need upstream confirmation
- `@context/.context-mesh-framework.md` when unsure about Context Mesh rules

## Project Structure

```text
root/
├── AGENTS.md
├── README.md
├── LICENSE
├── qcow2.sh
├── emu.sh
├── context/
│   ├── .context-mesh-framework.md
│   ├── intent/
│   ├── decisions/
│   ├── knowledge/
│   │   ├── patterns/
│   │   ├── references-qemu.md
│   │   └── anti-patterns/
│   ├── agents/
│   └── evolution/
└── ...
```

## AI Agent Rules

### Always

- When work may alter code/scripts or `@context/`, load [`@context/agents/playbook-selector.md`](context/agents/playbook-selector.md), pick exactly one playbook, and follow it (ask one short clarification if classification is ambiguous).
- Load context before implementing.
- Follow decisions in `@context/decisions/`.
- Use patterns from `@context/knowledge/patterns/`.
- Update context after substantive implementation.

### Never

- Ignore documented decisions without creating a superseding ADR or explicit intent update.
- Introduce workflows that contradict recorded anti-patterns (when present in `@context/knowledge/anti-patterns/`).

### After Implementation (Critical)

Update Context Mesh:

- Reflect completed work in intent files (acceptance/status as appropriate).
- Add **Outcomes** to affected decision docs.
- Update [`context/evolution/changelog.md`](context/evolution/changelog.md).
- Add `learning-*.md` or new pattern/anti-pattern notes when insights are reusable.

## Definition of Done (Build Phase)

Before completing implementation:

- [ ] ADR exists for non-trivial technical choices (or project intent covers them explicitly).
- [ ] Code aligns with documented patterns where applicable.
- [ ] Decisions are respected or formally revised.
- [ ] Validation path executed (automated tests if added; manual QEMU smoke check otherwise).
- [ ] Context updated (intent/decision/changelog).
- [ ] Acceptance criteria for the touched feature(s) are met.

---

**Note**: For optional advanced agent templates (file-creation rules, execution agents), see upstream Context Mesh examples if your organization provides them.

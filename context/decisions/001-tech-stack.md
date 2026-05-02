# Decision: Tech stack

## Context

Starting a CLI/shell tooling project for local QEMU workflows: preparing disk images and launching guests with optical media.

## Decision

- **Shell**: Bash for `qcow2.sh` and `emu.sh`.
- **QEMU tooling**: `qemu-img` for image conversion; `qemu-system-x86_64` for emulation.
- **Acceleration / integration**: KVM (`-enable-kvm`) where available on Linux; SDL display pipeline as currently scripted in `emu.sh`.
- **Project version**: A plain-text **`VERSION`** file at the repository root holds the canonical SemVer string for the project; no language package manager is required.

## Rationale

- Minimal dependencies aligned with manual QEMU workflows.
- No intermediate management layer (e.g. libvirt) required for the narrow scope.
- A root `VERSION` file is trivial to edit, diff, and read from scripts or release tooling without JSON/TOML or generated metadata.

## Alternatives Considered

- **Libvirt / Virt Manager** — Heavier dependency graph; oversized for two focused helper scripts.
- **Other hypervisors** — Out of scope for a QEMU-centric repository.
- **Embedded version only in `README` / tags** — Easier for the string to drift; a dedicated `VERSION` file is the single source of truth and matches common packaging conventions.

## Outcomes

- Added root [`VERSION`](../../VERSION) (plain text, one SemVer line) and documented it in [README](../../README.md), [`AGENTS.md`](../../AGENTS.md), [project intent](../intent/project-intent.md), and [changelog](../evolution/changelog.md).

## Related

- [Project Intent](../intent/project-intent.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

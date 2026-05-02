# Decision: Tech stack

## Context

Starting a CLI/shell tooling project for local QEMU workflows: preparing disk images and launching guests with optical media.

## Decision

- **Shell**: Bash for `qcow2.sh` and `emu.sh`.
- **QEMU tooling**: `qemu-img` for image conversion; `qemu-system-x86_64` for emulation.
- **Acceleration / integration**: KVM (`-enable-kvm`) where available on Linux; SDL display pipeline as currently scripted in `emu.sh`.

## Rationale

- Minimal dependencies aligned with manual QEMU workflows.
- No intermediate management layer (e.g. libvirt) required for the narrow scope.

## Alternatives Considered

- **Libvirt / Virt Manager** — Heavier dependency graph; oversized for two focused helper scripts.
- **Other hypervisors** — Out of scope for a QEMU-centric repository.

## Outcomes

To be updated after implementation in Step 3: Learn.

## Related

- [Project Intent](../intent/project-intent.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

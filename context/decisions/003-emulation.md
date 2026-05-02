# Decision: Emulation technical approach

## Context

Implementing the emulation feature for **osemu**: boot or install from optical media against a QCOW2 backing disk using QEMU’s x86_64 system emulator.

## Decision

Invoke `qemu-system-x86_64` with:

- `-cdrom` pointing at the installer or live media (ISO/img).
- `-drive file=` pointing at the QCOW2 disk image.
- Additional flags as implemented in `emu.sh` today: `-enable-kvm`, `-boot menu=on`, `-cpu host`, `-smp 8`, `-vga virtio`, `-display sdl,gl=on`, `-m 8G`.

## Rationale

- Single-process, scriptable flow without extra orchestration.
- KVM and host CPU match typical local performance expectations on capable Linux hosts.

## Alternatives Considered

- **Explicit UEFI / OVMF-only layout** — Deferred; current BIOS-style flow may be extended later if needed.
- **VirtIO-only block without IDE/SATA considerations** — Could be revisited for performance; current script uses a simple `-drive` attachment.

## Outcomes

To be updated after implementation in Step 3: Learn.

## Related

- [Project Intent](../intent/project-intent.md)
- [Feature: Emulation](../intent/feature-emulation.md)
- [Decision: Tech stack](001-tech-stack.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

# Feature: Emulation

## What

The `emu.sh` script runs `qemu-system-x86_64` to boot/emulate a **QCOW2** disk image while attaching a **CD/ISO/img** as optical media. It encodes a fixed set of machine options (KVM, host CPU, SMP, memory, VirtIO VGA, SDL display) suitable for local desktop use.

## Why

Booting installers or live media from optical drive images while targeting a QCOW2 disk is a common workflow; a single script avoids retyping long QEMU CLI lines.

## Acceptance Criteria

- With valid `cdrom` and `image` paths, QEMU starts with `-cdrom` and `-drive file=` referencing the QCOW2 image per the current implementation.
- If either argument is missing, the script exits non-zero after a clear error.

## Related

- [Project Intent](project-intent.md)
- [Decision: Emulation technical approach](../decisions/003-emulation.md)
- [Reference: QEMU documentation](../knowledge/references-qemu.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

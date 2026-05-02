# Project Intent: osemu

## What

**osemu** is a small set of Bash CLI scripts around QEMU:

- Convert a **raw** disk image to **QCOW2** (`qcow2.sh`) using `qemu-img`.
- **Emulate** a QCOW2 disk with optical media (**CD/ISO/img**) attached (`emu.sh`) via `qemu-system-x86_64`.

## Why

- QCOW2 is QEMU’s native image format and generally yields **better ergonomics and performance** characteristics for typical QEMU workflows than using raw disks directly (per QEMU documentation and common practice).
- Wrapping repetitive, error-prone `qemu-img` / `qemu-system-x86_64` invocations in scripts makes local install/boot workflows **repeatable** and easier to share.

## Acceptance Criteria

- Both scripts remain **usable from the CLI** with clear arguments and actionable errors when inputs are missing.
- `qcow2.sh` successfully converts an expected raw input image to QCOW2 using `qemu-img convert`.
- `emu.sh` launches an x86_64 QEMU session with CD/ISO/media and the given QCOW2 disk, matching the documented invocation contract.
- Project context (this repo’s `context/` and `AGENTS.md`) stays aligned with script behavior as it evolves.

## Scope

- [Feature: Image transform](feature-image-transform.md) — `qcow2.sh`
- [Feature: Emulation](feature-emulation.md) — `emu.sh`

## External references

- [QEMU documentation (mesh index)](../knowledge/references-qemu.md) — curated links into the upstream manual ([QEMU docs master](https://www.qemu.org/docs/master/)).

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

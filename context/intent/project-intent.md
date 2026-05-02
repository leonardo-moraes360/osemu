# Project Intent: osemu

## What

**osemu** is a small set of Bash CLI scripts around QEMU:

- Convert a **raw** disk image to **QCOW2** (`qcow2.sh`) using `qemu-img`, with optional **`--raspi-round`** to grow the output to a **power-of-two** virtual size for QEMU **`raspi*`** SD media.
- **Emulate** a QCOW2 disk with optical media (**CD/ISO/img**) attached (`emu.sh`) via `qemu-system-x86_64` or `qemu-system-aarch64`, defaulting guest ISA to the host unless `--arch` or `OSEMU_ARCH` overrides.

## Why

- QCOW2 is QEMU’s native image format and generally yields **better ergonomics and performance** characteristics for typical QEMU workflows than using raw disks directly (per QEMU documentation and common practice).
- Wrapping repetitive, error-prone `qemu-img` and `qemu-system-*` invocations in scripts makes local install/boot workflows **repeatable** and easier to share on both **x86_64 and ARM64** hosts.

## Acceptance Criteria

- Both scripts remain **usable from the CLI** with clear arguments and actionable errors when inputs are missing.
- `qcow2.sh` successfully converts an expected raw input image to QCOW2 using `qemu-img convert`, and when opted in may resize for **`raspi*`-compatible** SD sizing (see [Feature: Image transform](feature-image-transform.md)).
- `emu.sh` launches QEMU for **x86_64 or aarch64** guests (per host default or `--arch` / `OSEMU_ARCH`) with CD/ISO/media and the given QCOW2 disk, matching the documented invocation contract and KVM vs TCG behavior in [Decision: Emulation](../decisions/003-emulation.md).
- Project context (this repo’s `context/` and `AGENTS.md`) stays aligned with script behavior as it evolves.

## Scope

- **Version**: The project version is recorded as a single SemVer line in `VERSION` at the repository root (see [README](../../README.md#versioning) and [Decision: Tech stack](../decisions/001-tech-stack.md)).
- [Feature: Image transform](feature-image-transform.md) — `qcow2.sh`
- [Feature: Emulation](feature-emulation.md) — `emu.sh`

## External references

- [QEMU documentation (mesh index)](../knowledge/references-qemu.md) — curated links into the upstream manual ([QEMU docs master](https://www.qemu.org/docs/master/)).

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

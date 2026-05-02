# Feature: Image transform

## What

The `qcow2.sh` script converts a **raw** disk image to **QCOW2** format using `qemu-img convert`, writing the output under a caller-specified directory (output filename derives from the input basename).

## Why

QCOW2 is the natural format for QEMU-centric workflows; converting from raw aligns with QEMU guidance and improves the emulation experience versus driving raw disks in many setups.

## Acceptance Criteria

- With a valid raw `image` path and `output_dir`, the script produces a `.qcow2` file alongside logging progress.
- If `image` is omitted, the script exits non-zero after a clear error.
- Conversion uses `qemu-img convert -f raw -O qcow2` as the primary operation.

## Related

- [Project Intent](project-intent.md)
- [Decision: Image transform technical approach](../decisions/002-image-transform.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

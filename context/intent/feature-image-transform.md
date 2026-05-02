# Feature: Image transform

## What

The `qcow2.sh` script converts a **raw** disk image to **QCOW2** format using `qemu-img convert`, writing the output under a caller-specified directory (output filename derives from the input basename).

Optional **`--raspi-round`** (or **`OSEMU_QCOW2_RASPI_ROUND=1`**) runs **`qemu-img resize`** after conversion when the qcow2 **virtual size** is not already a power of two **bytes**, sizing up to the next power of two — matching QEMU **`raspi*`** SD card constraints documented with **`emu.sh`**.

## Why

QCOW2 is the natural format for QEMU-centric workflows; converting from raw aligns with QEMU guidance and improves the emulation experience versus driving raw disks in many setups. Raspberry Pi OS and similar distributions often ship **non–power-of-two** (~3 GiB) disk images that fail **`qemu-system-aarch64 -M raspi*`** unless the backing virtual capacity is rounded upward.

## Acceptance Criteria

- With a valid raw `image` path and `output_dir`, the script produces a `.qcow2` file alongside logging progress.
- If positional arguments after options are not exactly **`image`** and **`output_dir`**, the script exits non-zero with usage context.
- Conversion uses **`qemu-img convert -f raw -O qcow2`** as the primary operation.
- With **`--raspi-round`** (or env **`OSEMU_QCOW2_RASPI_ROUND=1`**), once the output qcow exists, if virtual size is not a power-of-two bytes the script invokes **`qemu-img resize`** to **`ceil_pow2(virtual-bytes)`** and verifies success; if already compliant, no resize occurs.

## Related

- [Project Intent](project-intent.md)
- [Decision: Image transform technical approach](../decisions/002-image-transform.md)
- [Feature: Emulation](feature-emulation.md)
- [Reference: QEMU documentation](../knowledge/references-qemu.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

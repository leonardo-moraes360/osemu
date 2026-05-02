# Feature: Emulation

## What

The `emu.sh` script boots guests via QEMU (`qemu-system-x86_64` or `qemu-system-aarch64`). **Two flows**: (1) **ISO/installer** style: `<cdrom>` + `<disk_image>` with `-cdrom` and a second `-drive`. (2) **Disk/SD-only** (`--disk-only <path>`): boot a single system image (e.g. Raspberry Pi OS `.img` / `.qcow2`) without optical media. Guest architecture defaults to the **host** (`uname -m`), with **`--arch x86_64|aarch64`** or **`OSEMU_ARCH`** overriding. **`--machine NAME`** selects the QEMU board for aarch64 (default **`virt`**; **`raspi*`** for Pi-like SD images with `if=sd`). KVM and `-cpu host` apply only when Linux has `/dev/kvm` and guest ISA matches host; otherwise TCG (`qemu64` / `cortex-a72`) is used. Filenames suggesting **arm64 / raspios** but guest **x86_64** are rejected with a hint to use `--arch aarch64` and disk-only boot.

## Why

Booting installers or live media while targeting a QCOW2 disk is a common workflow across **x86_64 and ARM64** desktops; automating QEMU invocation avoids retyping long command lines.

## Acceptance Criteria

- ISO flow: valid `cdrom` + disk paths start QEMU with `-cdrom` and `-drive`; binary matches resolved guest ISA.
- `--disk-only` accepts exactly one path and boots without `-cdrom`; aarch64 **`virt`** path keeps VirtIO/SDL profile; aarch64 **`raspi*`** attaches the image as **`if=sd`** with constrained RAM/SMP tailored to that profile.
- Optional `--machine` restricts to aarch64; `raspi*` requires `--disk-only`.
- Paths whose basenames imply AArch64/Raspberry Pi OS combined with guest `x86_64` fail fast with remediation text.
- Optional `--arch` and `OSEMU_ARCH` behave as documented; unknown values error clearly. Missing QEMU binary exits with an actionable message.

## Related

- [Project Intent](project-intent.md)
- [Decision: Emulation technical approach](../decisions/003-emulation.md)
- [Reference: QEMU documentation](../knowledge/references-qemu.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Draft

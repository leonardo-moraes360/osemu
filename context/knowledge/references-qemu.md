# Reference: QEMU documentation (upstream)

## Purpose

Point agents and contributors to **official QEMU documentation** when validating flags, formats, disk image behavior, or system-emulation semantics. Prefer these sources over stale blog posts unless the upstream doc is unclear.

## Primary index

- [QEMU documentation (master)](https://www.qemu.org/docs/master/) — full manual for the rolling “master” branch; version picker is available from the QEMU doc site when you need release-specific wording.

## Sections relevant to **osemu**

| Topic | Upstream doc |
|------|----------------|
| `qemu-img`, convert/create (`qcow2.sh`) | [QEMU disk image utility (`qemu-img`)](https://www.qemu.org/docs/master/tools/qemu-img.html) |
| QEMU CLI and machine options (`emu.sh`) | [Invocation](https://www.qemu.org/docs/master/system/invocation.html) |
| Disk image concepts | [Disk images](https://www.qemu.org/docs/master/system/images.html) |
| QCOW2 format specification | [Qcow2 image file format](https://www.qemu.org/docs/master/interop/qcow2.html) |

## Status

- **Created**: 2026-05-02 (Phase: Learn / knowledge mesh)
- **Status**: Accepted (reference stub; URLs may follow minor doc renames upstream)

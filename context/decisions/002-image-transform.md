# Decision: Image transform technical approach

## Context

Implementing the image-transform feature for **osemu**: need a deterministic way to migrate raw disks into QEMU-friendly QCOW2 images.

## Decision

Use `qemu-img convert` with explicit `-f raw` and `-O qcow2`:

```text
qemu-img convert -f raw -O qcow2 "$input" "$output"
```

Naming and directories follow the calling contract implemented in `qcow2.sh` (output path under caller’s directory, basename-derived filename).

Optional **Raspberry Pi (`raspi*` / SD) sizing**: after conversion, callers may enable **`qcow2.sh --raspi-round`** or **`OSEMU_QCOW2_RASPI_ROUND=1`** to **`qemu-img resize`** the qcow up to **`ceil_pow2(virtual-bytes)`** when the converted image is **not already** a power of two bytes, satisfying QEMU **`raspi*`** SD capacity rules without manual math.

## Rationale

- Official, well-supported QEMU path for format conversion.
- QCOW2 supports features (e.g. sparseness, snapshots) useful for iterative VM work.
- Folding SD rounding into **`qcow2.sh`** keeps **`emu.sh`** focused on invocation while keeping one obvious place to prepare Raspi-compatible images.

## Alternatives Considered

- **Continue using raw images only** — Simpler but conflicts with the project goal of standardizing on QEMU’s native qcow2 workflow and documented benefits.
- **Resize only in `emu.sh`** — Works with **`OSEMU_RASPI_ROUND_SD=1`**, but users who want a persisted, correctly sized qcow2 before first boot still benefit from **`qcow2.sh --raspi-round`**.

## Outcomes

- [`qcow2.sh`](../../qcow2.sh) supports **`--raspi-round` / `--raspi-sd`**, **`--help`**, strict two-path semantics, **`log_error`** to stderr, and optional env **`OSEMU_QCOW2_RASPI_ROUND=1`**; README and AGENTS describe the Raspi sizing path beside [`emu.sh`](../../emu.sh).

## Related

- [Project Intent](../intent/project-intent.md)
- [Feature: Image transform](../intent/feature-image-transform.md)
- [Decision: Tech stack](001-tech-stack.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

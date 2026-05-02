# Decision: Image transform technical approach

## Context

Implementing the image-transform feature for **osemu**: need a deterministic way to migrate raw disks into QEMU-friendly QCOW2 images.

## Decision

Use `qemu-img convert` with explicit `-f raw` and `-O qcow2`:

```text
qemu-img convert -f raw -O qcow2 "$input" "$output"
```

Naming and directories follow the calling contract implemented in `qcow2.sh` (output path under caller’s directory, basename-derived filename).

## Rationale

- Official, well-supported QEMU path for format conversion.
- QCOW2 supports features (e.g. sparseness, snapshots) useful for iterative VM work.

## Alternatives Considered

- **Continue using raw images only** — Simpler but conflicts with the project goal of standardizing on QEMU’s native qcow2 workflow and documented benefits.

## Outcomes

To be updated after implementation in Step 3: Learn.

## Related

- [Project Intent](../intent/project-intent.md)
- [Feature: Image transform](../intent/feature-image-transform.md)
- [Decision: Tech stack](001-tech-stack.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

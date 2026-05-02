# Decision: Emulation technical approach

## Context

Implementing the emulation feature for **osemu**: boot or install from optical media against a QCOW2 backing disk using QEMU system emulators.

## Decision

- Target **two guest ISAs**: **x86_64** (`qemu-system-x86_64`) and **aarch64** (`qemu-system-aarch64`).
- **Default guest architecture** follows the **host** (`uname -m`): `x86_64`/`amd64` → x86_64 guest; `aarch64`/`arm64` → aarch64 guest.
- **Overrides**: CLI `--arch x86_64|aarch64` (aliases `amd64` / `arm64` accepted via normalizer) takes precedence over optional environment variable **`OSEMU_ARCH`**, which takes precedence over the host default when `--arch` is omitted.
- **KVM** (`-enable-kvm`, `-cpu host`): enabled only on **Linux** when `/dev/kvm` is readable **and** the selected **guest ISA matches** the normalized host ISA (`x86_64`/`aarch64` from `uname -m`; hosts mapping to neither never use KVM even if KVM is technically present). Otherwise the script uses **TCG**: x86_64 → `-cpu qemu64`; aarch64 → `-cpu cortex-a72`.
- **Machine models / boot layouts** ([`emu.sh`](../../emu.sh)):
  - **x86_64**: implicit PC: ISO installs use `-cdrom` + `-drive`; optional **`--disk-only`** drops `-cdrom` and boots one disk (`-vga virtio`, SDL, SMP/RAM defaults in script).
  - **aarch64**: default **`-machine virt`**; **`--machine <name>`** overrides (validated against [`qemu-system-aarch64 -machine help`](../../README.md)); **`raspi*`** attaches the boot image with **`if=sd`**, requires **virtual backing size to be a power of two bytes** (QEMU SD model); [`emu.sh`](../../emu.sh) preflights **`qemu-img info`** / optional **`qemu-img resize`**, uses framebuffer/SDL without the **`virt`** GPU profile, smaller SMP/RAM, and **`--disk-only`** (`raspi*` is not paired with `-cdrom` in this helper). Generic **`virt`** uses **`virtio-gpu-pci`** with SDL (no `gl=on` by default) and optional **`OSEMU_QEMU_DISPLAY` / `OSEMU_QEMU_SDL_GL`** (see [README](../../README.md)).
- **Discovery**: refuse to launch with a clear error if the chosen `qemu-system-*` binary is not on `PATH`.

## Rationale

- Same-ISA KVM matches typical desktop performance expectations; cross-ISA or missing KVM falls back to explicit TCG CPU models instead of rejecting the run outright.
- `virt` is the conventional QEMU machine type for aarch64/Linux guests where UEFI/board details are standardized for this narrow helper scope.
- Host-default architecture minimizes friction on ARM workstations while preserving deterministic overrides for CI or deliberate emulation.

## Alternatives Considered

- **Explicit UEFI / OVMF-only layout** — Deferred; current BIOS-style flow may be extended later if needed.
- **VirtIO-only block without IDE/SATA considerations** — Could be revisited for performance; current script uses a simple `-drive` attachment.
- **Single fixed ISA (x86_64 only)** — Superseded by multi-arch support documented here.
- **Always-on KVM flag** — Rejected when guest ≠ host ISA (invalid / misleading).

## Outcomes

- Implemented multi-arch-aware [`emu.sh`](../../emu.sh) with `--arch` / `OSEMU_ARCH`, KVM gating, and `qemu-system-{x86_64,aarch64}` selection; documented in [README](../../README.md), [`AGENTS.md`](../../AGENTS.md), [project intent](../intent/project-intent.md), [feature emulation](../intent/feature-emulation.md), [tech stack](001-tech-stack.md), and [changelog](../evolution/changelog.md).
- Added **`--disk-only`** and **`--machine`** for aarch64 (incl. `raspi*` SD boot paths), aarch64-vs-x86 Raspberry Pi naming guardrail, README guidance for Raspberry Pi OS `.img` workflows (see [README — Raspberry Pi OS](../../README.md#raspberry-pi-os--img-disk-images)).

## Related

- [Project Intent](../intent/project-intent.md)
- [Feature: Emulation](../intent/feature-emulation.md)
- [Decision: Tech stack](001-tech-stack.md)

## Status

- **Created**: 2026-05-02 (Phase: Intent)
- **Status**: Accepted

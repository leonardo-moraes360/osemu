# Changelog

## [Unreleased]

### Added

- Plain-text [`VERSION`](../../VERSION) at repository root holding the canonical SemVer project version; described in [README](../../README.md#versioning), [`AGENTS.md`](../../AGENTS.md) project layout, [project intent](../intent/project-intent.md), and [Decision: Tech stack](../decisions/001-tech-stack.md)
- Context Mesh [playbook selector](../agents/playbook-selector.md) plus five procedural playbooks under [`context/agents/`](../agents/) (`playbook-add-feature`, `playbook-update-feature`, `playbook-fix-bug`, `playbook-learn-update`, `playbook-create-agent`); mandatory selection when altering code/scripts or `context/` (see selector and [`AGENTS.md`](../../AGENTS.md))
- Knowledge reference [references-qemu](../knowledge/references-qemu.md) linking official [QEMU documentation (master)](https://www.qemu.org/docs/master/) for consultation on flags, formats, and emulation semantics
- Project initialized with Context Mesh
- Created project intent
- Created feature intents: image transform, emulation
- Created decisions: tech stack (`001-tech-stack.md`), image transform (`002-image-transform.md`), emulation (`003-emulation.md`)
- Created pattern: [shell-script-style-cst8177](../knowledge/patterns/shell-script-style-cst8177.md)
- Added `AGENTS.md` and `README.md` at repository root

### Changed

- **`emu.sh`**: selects `qemu-system-x86_64` or `qemu-system-aarch64` with host-default guest ISA, optional `--arch` / `OSEMU_ARCH`, aarch64 `-machine virt`, and KVM limited to Linux same-ISA hosts with TCG fallbacks documented in [`context/decisions/003-emulation.md`](../decisions/003-emulation.md). README and AGENTS prerequisites updated accordingly.
- **`emu.sh`**: **`--disk-only`** single-disk boot, **`--machine`** for aarch64 (incl. `raspi*` + `if=sd`), filename guard when paths look like raspios/arm64 vs x86 guest, README Raspberry Pi OS section.
- **`emu.sh`**: **`raspi*`** launches validate SD virtual size is a **power-of-two** bytes (`qemu-img`); suggest **`qemu-img resize`** next power-of-two or **`OSEMU_RASPI_ROUND_SD=1`** auto-grow. README Raspberry Pi subsection documents this QEMU constraint.
- **`qcow2.sh`**: optional **`--raspi-round` / `--raspi-sd`**, **`--help`**, env **`OSEMU_QCOW2_RASPI_ROUND=1`**, and post-convert **`qemu-img resize`** to next power-of-two when needed for QEMU **`raspi*`** SD (see [Decision: Image transform](../decisions/002-image-transform.md)).

### Fixed

- **`emu.sh`**: aarch64 **`virt`** display stack avoids `-vga virtio` + `sdl,gl=on` (Ubuntu “Virtio VGA not available”) by default via **`virtio-gpu-pci`** + **`OSEMU_*`** overrides; rejects obvious **`-cdrom` misuse** (`*.img` / raspios-style first argument) with a corrective example.

---

*Last Updated: 2026-05-02*

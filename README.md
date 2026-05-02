# osemu

Small Bash helpers for **QEMU**: convert **raw** disk images to **QCOW2**, then **run** a guest with **CD/ISO** media attached. The workflow favors QEMU’s native disk format and shorter, repeatable command lines than typing `qemu-img` / `qemu-system-*` by hand on **x86_64 or AArch64** hosts (guest ISA defaults to the host; optional `--arch`).

## Getting Started

These steps get a local copy ready to run the scripts on your machine.

### Prerequisites

- **Bash** (scripts use `#!/usr/bin/env bash`)
- **qemu-img** and whichever system emulator matches your workloads:
  - **x86_64 guests**: `qemu-system-x86_64` (often in `qemu-system-x86`)
  - **aarch64 guests**: `qemu-system-aarch64` (e.g. `qemu-system-arm` on Debian/Ubuntu, `qemu-system-aarch64` on Fedora)
  On hosts that are not running the chosen guest ISA, installs are optional (the script selects the binary named above).
- On Linux, **KVM** is recommended for performance when guest and host ISAs match (`/dev/kvm`); `emu.sh` enables KVM only in that situation and otherwise falls back to TCG

Examples (names vary by distro):

```bash
# Debian/Ubuntu-style (x86_64 host tooling; add arm for AArch64 emulation)
sudo apt install qemu-system-x86 qemu-utils
# Optional if you emulate AArch64 guests
sudo apt install qemu-system-arm

# Fedora-style (add qemu-system-aarch64 if you emulate AArch64 guests)
sudo dnf install qemu-kvm qemu-img qemu-system-aarch64
```

### Installing

There is no formal install step. Clone the repository and ensure the scripts are executable:

```bash
git clone https://github.com/YOUR_USERNAME/osemu.git
cd osemu
chmod +x qcow2.sh emu.sh
```

Replace the clone URL with your fork or local remote.

### Minimal usage

Convert a raw image to qcow2 (output directory must exist):

```bash
mkdir -p ./qcow2
./qcow2.sh /path/to/disk.raw ./qcow2
# produces ./qcow2/disk.raw.qcow2 (name derived from the input basename)
```

Convert and **grow the qcow2** to the next **power-of-two** virtual size (**QEMU `raspi*`** SD requirement; common for Raspberry Pi OS ~3 GiB images):

```bash
./qcow2.sh --raspi-round /path/to/pi-lite.img ./qcow2
# or: OSEMU_QCOW2_RASPI_ROUND=1 ./qcow2.sh ...
```

Boot with optical media plus a qcow2 disk:

```bash
./emu.sh /path/to/live.iso ./qcow2/disk.raw.qcow2
```

Guest architecture defaults to the host CPU family. Override explicitly when needed:

```bash
OSEMU_ARCH=aarch64 ./emu.sh /path/to/arm64-live.iso ./arm64-disk.qcow2
./emu.sh --arch x86_64 /path/to/live.iso ./disk.qcow2
```

See `./emu.sh --help` for usage.

**aarch64 `virt`** uses **`virtio-gpu-pci`** and **plain SDL by default**, so it does **not** require a working **`sdl,gl=on`** / **`Virtio VGA`** stack—even if **`qemu-system-modules-opengl`** is already installed but mismatched. Optional environment:

- **`OSEMU_QEMU_SDL_GL=1`** — try `-display sdl,gl=on`.
- **`OSEMU_QEMU_DISPLAY=gtk`** or **`none`** — use GTK instead of SDL, or headless-ish console via serial (`none` drops the virtio-GPU/SDL window path for `virt`).

On **x86**, the script still uses **`-vga virtio`** but defaults to **`-display sdl`** without `gl=on` unless **`OSEMU_QEMU_SDL_GL=1`**.

Memory, SMP, and related limits are defined in **`emu.sh`** (and differ for **`raspi*`** profiles).

### Raspberry Pi OS / `.img` disk images

A **Raspberry Pi OS** download (`.img`) is a **full SD/system disk**, not an ISO. Do **not** pass it as the first argument (that slot is for **optical** media). On an **x86_64** host you must also force the guest ISA with **`--arch aarch64`** (QEMU will use **TCG**, so it is slower than KVM).

Typical flow: convert the raw `.img` to qcow2 with **`qcow2.sh --raspi-round`** (handles the power-of-two SD size during conversion), then boot from the disk only using a **Raspberry Pi board model** your QEMU build supports (check `qemu-system-aarch64 -machine help`—many distros stop at `raspi3b`, while newer Pi OS releases may target Pi 4+ and may not boot until you use a matching machine or different image):

```bash
./qcow2.sh --raspi-round ./images/2026-04-21-raspios-trixie-arm64-lite.img ./qcow2
./emu.sh --arch aarch64 --machine raspi3b --disk-only ./qcow2/2026-04-21-raspios-trixie-arm64-lite.img.qcow2
```

**QEMU `raspi*`** models attach the backing file as SD **hardware emulation** whose virtual size must be a **power of two** in bytes (many Pi OS downloads are ~3 GiB and need growing to ~4 GiB). Prefer fixing this at **`qcow2.sh` convert time**, or **`emu.sh`** can still **`qemu-img resize`** at runtime:

```bash
OSEMU_RASPI_ROUND_SD=1 ./emu.sh --arch aarch64 --machine raspi3b --disk-only ./qcow2/your-image.qcow2
```

Growing a **qcow2** is normally **safe** (empty space appended at end of disk); shrinking can destroy data—do not pass a smaller resize target than you need.

For generic AArch64 **cloud/server** images meant for the `virt` machine and UEFI, use `--disk-only` without `raspi*` (and ensure firmware/kernel match that workflow—often not the same as Pi OS).

See also [project intent](context/intent/project-intent.md), [Context Mesh framework notes](context/.context-mesh-framework.md), and [AGENTS.md](AGENTS.md) for agent-oriented setup.

## Running the tests

There is **no automated test suite** in this repository yet. Manual checks:

```bash
qemu-img --version
qemu-system-x86_64 --version
command -v qemu-system-aarch64 >/dev/null && qemu-system-aarch64 --version
./qcow2.sh # expect error when args missing
./qcow2.sh --help
./emu.sh    # expect usage line (cdrom+disk or --disk-only)
```

When tests are added later, describe them here and link to CI if applicable.

## Deployment

This tooling is intended for **local development and experimentation**. There is no production deployment story beyond copying the scripts and ensuring QEMU/KVM prerequisites on the host.

## Built With

- [Bash](https://www.gnu.org/software/bash/)
- [QEMU](https://www.qemu.org/) — `qemu-img`, `qemu-system-x86_64`, `qemu-system-aarch64`

## Contributing

- Read [`context/intent/project-intent.md`](context/intent/project-intent.md) and matching ADRs under [`context/decisions/`](context/decisions/) before substantive changes.
- Shell style should trend toward CST8177 guidance documented in [`context/knowledge/patterns/shell-script-style-cst8177.md`](context/knowledge/patterns/shell-script-style-cst8177.md).

## Versioning

The canonical project version string is the single SemVer line in [`VERSION`](VERSION) at the repository root. Git release tags should match that value with a `v` prefix (for example file `0.1.0` → tag `v0.1.0`).

Tag releases semantically (`vMAJOR.MINOR.PATCH`) when the scripts stabilize; until then revisions are tracked via Git history and [`context/evolution/changelog.md`](context/evolution/changelog.md).

## Authors

- Leonardo Moraes

## License

This project is licensed under the **MIT License** — see [`LICENSE`](LICENSE).

## Acknowledgments

- README layout inspired by [PurpleBooth’s README template](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2).
- Shell conventions reference: [Ian Allan — Shell Script Programming Conventions and Style](https://teaching.idallen.com/cst8177/13w/notes/000_script_style.html).

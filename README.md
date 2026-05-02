# osemu

Small Bash helpers for **QEMU**: convert **raw** disk images to **QCOW2**, then **run** a guest with **CD/ISO** media attached. The workflow favors QEMU’s native disk format and shorter, repeatable command lines than typing `qemu-img` / `qemu-system-x86_64` by hand.

## Getting Started

These steps get a local copy ready to run the scripts on your machine.

### Prerequisites

- **Bash** (scripts use `#!/usr/bin/env bash`)
- **qemu-img** and **qemu-system-x86_64** (from your distro’s QEMU package)
- On Linux, **KVM** is recommended for performance (`/dev/kvm`); the emulator script enables KVM when invoked

Examples (names vary by distro):

```bash
# Debian/Ubuntu-style
sudo apt install qemu-system-x86 qemu-utils

# Fedora-style
sudo dnf install qemu-kvm qemu-img
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

Boot with optical media plus a qcow2 disk:

```bash
./emu.sh /path/to/live.iso ./qcow2/disk.raw.qcow2
```

The emulator uses the QEMU flags baked into `emu.sh` (memory, SMP, VirtIO VGA, SDL, etc.—adjust there if your host needs different hardware).

See also [project intent](context/intent/project-intent.md), [Context Mesh framework notes](context/.context-mesh-framework.md), and [AGENTS.md](AGENTS.md) for agent-oriented setup.

## Running the tests

There is **no automated test suite** in this repository yet. Manual checks:

```bash
qemu-img --version
qemu-system-x86_64 --version
./qcow2.sh # expect error explaining required image argument
./emu.sh    # expect error explaining required cdrom/image arguments
```

When tests are added later, describe them here and link to CI if applicable.

## Deployment

This tooling is intended for **local development and experimentation**. There is no production deployment story beyond copying the scripts and ensuring QEMU/KVM prerequisites on the host.

## Built With

- [Bash](https://www.gnu.org/software/bash/)
- [QEMU](https://www.qemu.org/) — `qemu-img`, `qemu-system-x86_64`

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

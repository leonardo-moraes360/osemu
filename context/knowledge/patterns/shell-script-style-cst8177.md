# Pattern: CST8177 shell script style (Ian Allan)

## Description

Conventions from Algonquin College CST8177 *Unix/Linux Shell Script Programming Conventions and Style* (Ian D. Allan). They emphasize readability, predictable environment, stderr for errors, and structured script layout—not merely “getting it to work.”

Canonical reference:

- HTML: https://teaching.idallen.com/cst8177/13w/notes/000_script_style.html  
- Plain text: https://teaching.idallen.com/cst8177/13w/notes/000_script_style.txt  

## When to Use

Whenever adding or substantially editing shell scripts in this repository, treat these notes as the **preferred style target**, especially for:

- Headers (shebang, one-line summary, synopsis, purpose).
- Environment hygiene (`PATH`, `LC_COLLATE`, `LANG`, `umask`) when portability matters.
- Validation before processing; explicit exit status.
- Error messages on **stderr** that include `$0` and echo invalid input back with hints.

Course-specific blocks (assignment labels, student metadata) are **not** required here; replicate the spirit of structured documentation instead.

## Pattern

Structural expectations (adapted):

1. Shebang appropriate to the dialect (POSIX `sh` vs Bash); Allan’s examples use Bourne features and `#!/bin/sh -u` where suitable.
2. Short title line then **Syntax**/**Purpose** commentary blocks.
3. Normalize locale/collating and PATH early when scripts must behave deterministically across machines.
4. Algorithm grouped as Input → Validate → Process → Output; end with explicit `exit` status.
5. Robustness: check important command exit statuses; avoid undefined variables when using `set -u` / `-u` shell mode.

Current scripts (`qcow2.sh`, `emu.sh`) use Bash functions and colored logging to stdout. Migrating toward CST8177 may mean shifting errors to stderr and tightening headers—do that deliberately in follow-up changes, not inconsistently inside small fixes.

## Example

Minimal header shape (illustrative; adjust shebang/policy to match deployment):

```sh
#!/usr/bin/env bash
# ------------------------------------------------------------------
# One-line summary: convert raw disk to qcow2.
# ------------------------------------------------------------------
# Syntax:
#   qcow2.sh <image> <output_dir>
# ------------------------------------------------------------------
# Purpose:
#   Wrap qemu-img conversion from raw to qcow2 ...
# ------------------------------------------------------------------

set -euo pipefail
# ... validate, process, exit 0 / non-zero ...
```

## Related

- [Project Intent](../../intent/project-intent.md)
- [Decision: Tech stack](../../decisions/001-tech-stack.md)
- [Feature: Image transform](../../intent/feature-image-transform.md)
- [Feature: Emulation](../../intent/feature-emulation.md)

## Status

- **Created**: 2026-05-02
- **Status**: Active

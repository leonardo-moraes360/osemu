#!/usr/bin/env bash

function log_error() {
    local message="$1"
    local timestamp
    timestamp=$(date +%Y-%m-%d,\ %H:%M:%S)

    echo -e "\033[31m($$) - $timestamp [ERROR] $message \033[0m" >&2
}

function log_info() {
    local message="$1"
    local timestamp
    timestamp=$(date +%Y-%m-%d,\ %H:%M:%S)

    echo -e "\033[32m($$) - $timestamp [INFO] $message \033[0m"
}

# Map uname -m or user input to guest ISA: x86_64 | aarch64. Empty stdout = invalid.
function normalize_guest_arch() {
    local raw
    raw=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
    case "$raw" in
        x86_64 | amd64) echo x86_64 ;;
        aarch64 | arm64) echo aarch64 ;;
        *) return 1 ;;
    esac
}

function host_normalized_arch() {
    local mach
    mach=$(uname -m)
    normalize_guest_arch "$mach"
}

function default_guest_arch() {
    host_normalized_arch
}

# True when paths look like AArch64/Raspberry Pi OS media (helps catch x86-default mistakes).
function paths_hint_aarch64() {
    local a b hay
    a=$(basename -- "${1:-.}" | tr '[:upper:]' '[:lower:]')
    b=$(basename -- "${2:-.}" | tr '[:upper:]' '[:lower:]')
    hay="$a$b"
    case "$hay" in
        *arm64* | *aarch64* | *raspios* | *raspi*-os-* | *raspbian*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function is_raspi_machine() {
    local m
    m=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
    case "$m" in
        raspi*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function drive_format_suffix() {
    local f="$1"
    case "${f,,}" in
        *.qcow2) echo qcow2 ;;
        *.img | *.raw) echo raw ;;
        *)
            echo auto
            ;;
    esac
}

function disk_virtual_size_bytes() {
    local f="$1"
    if ! command -v qemu-img &>/dev/null; then
        log_error "qemu-img is required on PATH to validate raspi* SD image sizing."
        return 1
    fi

    local out pv
    if command -v python3 &>/dev/null; then
        out=$(qemu-img info -U --output=json "$f" 2>/dev/null) || out=""
        if [ -n "$out" ]; then
            pv=$(echo "$out" | python3 -c "import sys,json; print(json.load(sys.stdin)['virtual-size'])" 2>/dev/null) || pv=""
            if [[ "$pv" =~ ^[0-9]+$ ]]; then
                echo "$pv"
                return 0
            fi
        fi
    fi

    pv=$(qemu-img info -U "$f" 2>/dev/null | LC_ALL=C grep -Fi 'virtual size:' | head -1 | sed -n 's/.*(\([0-9][0-9]*\) bytes).*/\1/p') || pv=""
    if [[ "$pv" =~ ^[0-9]+$ ]]; then
        echo "$pv"
        return 0
    fi

    return 1
}

function is_power_of_two_bytes() {
    local n="$1"
    [ "$n" -gt 0 ] 2>/dev/null && [ $((n & (n - 1))) -eq 0 ]
}

# Smallest power of two ≥ n (needed for QEMU raspi* SD: see "Invalid SD card size").
function ceil_pow2_bytes() {
    local n="$1"
    if [ "${n:-0}" -le 0 ] 2>/dev/null; then
        echo 0
        return 0
    fi
    local p=1
    while [ "$p" -lt "$n" ]; do
        p=$((p * 2))
    done
    echo "$p"
}

function ensure_raspi_sd_power_of_two() {
    local img="$1"
    local bytes rounded

    bytes=$(disk_virtual_size_bytes "$img") || {
        log_error "Could not read virtual size of '${img}' (qemu-img)."
        exit 1
    }

    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        log_error "Could not parse virtual size for '${img}'."
        exit 1
    fi

    if is_power_of_two_bytes "$bytes"; then
        return 0
    fi

    rounded=$(ceil_pow2_bytes "$bytes")

    if [ "${OSEMU_RASPI_ROUND_SD:-0}" = 1 ]; then
        log_info "OSEMU_RASPI_ROUND_SD=1: resizing '${img}' to next power-of-two ($bytes → $rounded bytes) for QEMU raspi* SD."
        if ! qemu-img resize "$img" "$rounded"; then
            log_error "qemu-img resize '${img}' $rounded failed."
            exit 1
        fi
        bytes=$(disk_virtual_size_bytes "$img") || exit 1
        if ! is_power_of_two_bytes "$bytes"; then
            log_error "After resize, virtual size '$bytes' is still not a power of two bytes."
            exit 1
        fi
        return 0
    fi

    log_error "QEMU raspi* models require SD media whose virtual size is a power-of-two bytes (your image reports ${bytes} bytes; many Pi OS images are about 3 GiB and fail this rule). Grow (safe) to the next power of two with:"
    log_error "  qemu-img resize '${img}' ${rounded}"
    log_error "...or rerun with OSEMU_RASPI_ROUND_SD=1 to let this script run that resize automatically."
    exit 1
}

# First positional in ISO-flow is QEMU -cdrom; SD card / Pi images belong in --disk-only.
function optical_arg_looks_like_disk_image() {
    local p
    p=$(basename -- "${1:-}" | tr '[:upper:]' '[:lower:]')
    case "$p" in
        *.img | *.raw) return 0 ;;
    esac
    case "$p" in
        *raspios* | *raspbian* | *raspberrypi*) return 0 ;;
    esac
    return 1
}

# aarch64 virt: avoid `-vga virtio` + `sdl,gl=on`, which triggers `Virtio VGA not available`
# unless every GL/SDL piece lines up—even when qemu-system-modules-opengl is installed.
# Default: virtio-gpu-pci + plain SDL. Set OSEMU_QEMU_SDL_GL=1 to try `-display sdl,gl=on`.
# Set OSEMU_QEMU_DISPLAY=gtk | none | sdl (default sdl).
function append_aarch64_virt_gpu_display_input() {
    local -n _cmd_arr=$1
    local backend="${OSEMU_QEMU_DISPLAY:-sdl}"
    local sdl_gl="${OSEMU_QEMU_SDL_GL:-0}"

    backend=$(echo "$backend" | tr '[:upper:]' '[:lower:]')
    [ -z "$backend" ] && backend=sdl

    case "$backend" in
        gtk)
            _cmd_arr+=(-vga none -device virtio-gpu-pci -device virtio-keyboard-pci -device virtio-mouse-pci -display gtk)
            ;;
        none | nographic)
            _cmd_arr+=(-vga none -display none -monitor none -serial mon:stdio)
            return 0
            ;;
        sdl)
            _cmd_arr+=(-vga none -device virtio-gpu-pci -device virtio-keyboard-pci -device virtio-mouse-pci)
            if [ "$sdl_gl" = 1 ]; then
                _cmd_arr+=(-display "sdl,gl=on")
            else
                _cmd_arr+=(-display sdl)
            fi
            ;;
        *)
            log_error "Unknown OSEMU_QEMU_DISPLAY='$OSEMU_QEMU_DISPLAY' (use sdl, gtk, or none)."
            exit 1
            ;;
    esac
}

# x86: optional GL on SDL (same env as aarch64/SDL path).
function x86_display_virtio_flags() {
    local -n _cmd_arr=$1
    local sdl_gl="${OSEMU_QEMU_SDL_GL:-0}"
    local backend="${OSEMU_QEMU_DISPLAY:-sdl}"
    backend=$(echo "$backend" | tr '[:upper:]' '[:lower:]')
    [ -z "$backend" ] && backend=sdl

    case "$backend" in
        gtk)
            _cmd_arr+=(-vga virtio -display gtk)
            ;;
        none | nographic)
            _cmd_arr+=(-vga virtio -display none -serial mon:stdio)
            ;;
        sdl)
            _cmd_arr+=(-vga virtio)
            if [ "$sdl_gl" = 1 ]; then
                _cmd_arr+=(-display "sdl,gl=on")
            else
                _cmd_arr+=(-display sdl)
            fi
            ;;
        *)
            log_error "Unknown OSEMU_QEMU_DISPLAY='$OSEMU_QEMU_DISPLAY' (use sdl, gtk, or none)."
            exit 1
            ;;
    esac
}

function parse_args_into() {
    # shellcheck disable=SC2034
    local -n __cdrom_ref=$1
    local -n __image_ref=$2
    local -n __arch_flag_ref=$3
    local -n __disk_only_ref=$4
    local -n __machine_ref=$5
    shift 5

    __arch_flag_ref=""
    __disk_only_ref=0
    __machine_ref=""
    local -a pos=()
    local arch_canon

    while [ $# -gt 0 ]; do
        case "$1" in
            --arch)
                if [ -z "${2:-}" ]; then
                    log_error "--arch requires a value (x86_64 or aarch64)"
                    return 1
                fi
                if ! arch_canon=$(normalize_guest_arch "$2"); then
                    log_error "Invalid --arch value: $2 (use x86_64 or aarch64)"
                    return 1
                fi
                __arch_flag_ref=$arch_canon
                shift 2
                ;;
            --machine)
                if [ -z "${2:-}" ]; then
                    log_error "--machine requires a QEMU machine name (try: virt, raspi3b)"
                    return 1
                fi
                __machine_ref=$2
                shift 2
                ;;
            --disk-only)
                __disk_only_ref=1
                shift
                ;;
            -h | --help)
                echo "Usage: $0 [--arch x86_64|aarch64] [--machine NAME] --disk-only <disk_image>"
                echo "       $0 [--arch …] [--machine …] <cdrom.iso> <disk_image>"
                echo ""
                echo "Examples:"
                echo "  Installer ISO + qcow2:  $0 live.iso disk.qcow2"
                echo "  Pi / SD image (qemu raspi* board — see QEMU -machine help): \\"
                echo "    $0 --arch aarch64 --machine raspi3b --disk-only disk.qcow2"
                echo "Architecture default follows host unless OSEMU_ARCH or --arch is set."
                echo "--disk-only: boot only from one disk/SD/system image (.img/.qcow2). Do not use a raw .img as -cdrom."
                echo "Graphics (optional env): OSEMU_QEMU_DISPLAY=sdl|gtk|none ; OSEMU_QEMU_SDL_GL=1 for sdl,gl=on."
                echo "Raspberry Pi QEMU SD size: OSEMU_RASPI_ROUND_SD=1 auto qemu-img resize to next power-of-two when needed."
                return 2
                ;;
            *)
                pos+=("$1")
                shift
                ;;
        esac
    done

    if [ "$__disk_only_ref" -eq 1 ]; then
        if [ ${#pos[@]} -lt 1 ]; then
            log_error "Usage: $0 [--arch ...] [--machine NAME] --disk-only <disk_image>"
            return 1
        fi
        if [ ${#pos[@]} -gt 1 ]; then
            log_error "With --disk-only, pass exactly one path (boot disk)."
            return 1
        fi
        __cdrom_ref=""
        __image_ref="${pos[0]}"
        return 0
    fi

    if [ ${#pos[@]} -lt 2 ]; then
        log_error "Usage: $0 [options] <cdrom> <disk_image>   or   ... --disk-only <disk>"
        return 1
    fi
    if [ ${#pos[@]} -gt 2 ]; then
        log_error "Too many arguments (expected cdrom and image after options, or --disk-only with one disk)"
        return 1
    fi

    __cdrom_ref="${pos[0]}"
    __image_ref="${pos[1]}"
    return 0
}

function resolve_guest_arch() {
    local from_flag="$1"

    local guest=""
    if [ -n "$from_flag" ]; then
        guest=$from_flag
    elif [ -n "${OSEMU_ARCH:-}" ]; then
        if ! guest=$(normalize_guest_arch "$OSEMU_ARCH"); then
            log_error "Invalid OSEMU_ARCH: $OSEMU_ARCH (use x86_64 or aarch64)"
            return 1
        fi
    else
        if ! guest=$(default_guest_arch); then
            log_error "Unsupported host architecture for default guest: $(uname -m)"
            return 1
        fi
    fi

    echo "$guest"
}

function qemu_binary_for_arch() {
    case "$1" in
        x86_64)
            echo qemu-system-x86_64
            return 0
            ;;
        aarch64)
            echo qemu-system-aarch64
            return 0
            ;;
        *)
            log_error "Internal error: unknown guest arch $1"
            return 1
            ;;
    esac
}

function want_kvm() {
    local guest_arch="$1"
    local host_arch="$2"

    [ "$(uname -s)" = Linux ] &&
        [ -r /dev/kvm ] &&
        [ "$guest_arch" = "$host_arch" ]
}

function aarch64_machine_name() {
    local override="$1"
    if [ -n "$override" ]; then
        echo "$override"
        return 0
    fi
    echo virt
}

function main() {
    local cdrom image arch_flag parse_status disk_only machine_override

    parse_args_into cdrom image arch_flag disk_only machine_override "$@" || {
        parse_status=$?
        if [ "$parse_status" = 2 ]; then
            exit 0
        fi
        exit 1
    }

    if [ "$disk_only" -ne 1 ]; then
        if [ -z "$cdrom" ]; then
            log_error "CDROM path is missing (installer ISO/live image). Booting a disk-only image requires --disk-only."
            exit 1
        fi
    fi

    if [ -z "$image" ]; then
        log_error "Image path is required"
        exit 1
    fi

    local guest_arch
    guest_arch=$(resolve_guest_arch "$arch_flag") || exit 1

    if paths_hint_aarch64 "$cdrom" "$image" && [ "$guest_arch" = x86_64 ]; then
        log_error 'Paths look like AArch64/Raspberry Pi OS (arm64, raspios, etc.) but guest is x86_64. Use --arch aarch64 (slow TCG when the host differs). Raspberry Pi disk images (.img/.qcow2) are meant for disk boot: use --disk-only and (for QEMU raspi boards) --machine raspi3b—not as -cdrom unless the file really is an ISO.'
        exit 1
    fi

    if [ "$disk_only" -ne 1 ] && is_raspi_machine "$(aarch64_machine_name "${machine_override:-}")"; then
        log_error "--machine rasp* expects a single SD/boot disk — use --disk-only <disk> instead of cdrom+disk args."
        exit 1
    fi

    if [ "$disk_only" -ne 1 ] && optical_arg_looks_like_disk_image "$cdrom"; then
        log_error "The first path is wired to QEMU -cdrom (optical). It looks like a disk / SD image (.img, raspios, …), which usually fails and is wrong for Raspberry Pi OS. Use a real .iso here, or boot the disk alone, e.g.: $0 --arch aarch64 --machine raspi3b --disk-only ./qcow2/your-disk.qcow2"
        exit 1
    fi

    if [ -n "$machine_override" ] && [ "$guest_arch" != aarch64 ]; then
        log_error "--machine applies to aarch64 only in this helper (guest is ${guest_arch})."
        exit 1
    fi

    local host_arch="__unknown__" normalized_host
    if normalized_host=$(host_normalized_arch); then
        host_arch=$normalized_host
    fi

    local qemu_bin
    qemu_bin=$(qemu_binary_for_arch "$guest_arch") || exit 1
    if ! command -v "$qemu_bin" &>/dev/null; then
        log_error "Emulator not found: $qemu_bin (install QEMU system package for $guest_arch)"
        exit 1
    fi

    local -a cmd=("$qemu_bin")

    local effective_machine=""
    local fmt
    fmt=$(drive_format_suffix "$image")

    if [ "$guest_arch" = aarch64 ]; then
        effective_machine=$(aarch64_machine_name "$machine_override")

        cmd+=(-machine "$effective_machine")

        if want_kvm "$guest_arch" "$host_arch"; then
            cmd+=(-enable-kvm -cpu host)
            log_info "Using KVM (guest ISA matches host: $guest_arch)"
        else
            cmd+=(-cpu cortex-a72)
            log_info "KVM not used (TCG): guest=$guest_arch host=$host_arch"
        fi

        if is_raspi_machine "$effective_machine"; then
            ensure_raspi_sd_power_of_two "$image"
            cmd+=(-smp 4 -m 1024)
            cmd+=(-display sdl)
            if [ "$fmt" != auto ]; then
                cmd+=(-drive "file=${image},if=sd,index=0,format=${fmt}")
            else
                cmd+=(-drive "file=${image},if=sd,index=0")
            fi
            if [ "$disk_only" -ne 1 ]; then
                log_error "Internal error: raspi disk-only precondition failed"
                exit 1
            fi
            log_info "Emulating Raspi-class machine ($effective_machine) from SD/disk-only $image"
            exec "${cmd[@]}"
        fi

        if [ "$disk_only" -eq 1 ]; then
            if [ "$fmt" != auto ]; then
                cmd+=(-drive "file=${image},format=${fmt}")
            else
                cmd+=(-drive "file=${image}")
            fi
            cmd+=(-boot "menu=on,strict=off,order=d")
            cmd+=(-smp 8 -m 8G)
            append_aarch64_virt_gpu_display_input cmd
            log_info "Disk-only aarch64 (${effective_machine}) boot from $image"
            exec "${cmd[@]}"
        fi

        cmd+=(
            -cdrom "$cdrom"
            -boot menu=on
            -drive "file=${image}"
            -smp 8
            -m 8G
        )
        append_aarch64_virt_gpu_display_input cmd
        log_info "Emulating $image ($guest_arch, $effective_machine) with optical $cdrom"
        exec "${cmd[@]}"
    fi

    if [ -n "$machine_override" ]; then
        log_error "--machine is only meaningful for aarch64 guests."
        exit 1
    fi

    if [ "$disk_only" -eq 1 ]; then
        if want_kvm "$guest_arch" "$host_arch"; then
            cmd+=(-enable-kvm -cpu host)
            log_info "Using KVM (guest ISA matches host: $guest_arch)"
        else
            cmd+=(-cpu qemu64)
            log_info "KVM not used (TCG): guest=$guest_arch host=$host_arch"
        fi
        fmt=$(drive_format_suffix "$image")
        if [ "$fmt" != auto ]; then
            cmd+=(-drive "file=${image},format=${fmt}")
        else
            cmd+=(-drive "file=${image}")
        fi
        cmd+=(-boot "menu=on,strict=off,order=d" -smp 8 -m 8G)
        x86_display_virtio_flags cmd
        log_info "Disk-only x86_64 boot from $image"
        exec "${cmd[@]}"
    fi

    if want_kvm "$guest_arch" "$host_arch"; then
        cmd+=(-enable-kvm -cpu host)
        log_info "Using KVM (guest ISA matches host: $guest_arch)"
    else
        cmd+=(-cpu qemu64)
        log_info "KVM not used (TCG): guest=$guest_arch host=$host_arch"
    fi

    cmd+=(
        -cdrom "$cdrom"
        -boot menu=on
        -drive "file=${image}"
        -smp 8
        -m 8G
    )
    x86_display_virtio_flags cmd

    log_info "Emulating $image ($guest_arch) with $cdrom"

    exec "${cmd[@]}"
}

main "$@"

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

function disk_virtual_size_bytes() {
    local f="$1"
    if ! command -v qemu-img &>/dev/null; then
        log_error "qemu-img is required on PATH."
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

# Smallest power of two >= n (QEMU raspi* SD hardware model).
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

function maybe_resize_output_for_raspi_sd() {
    local qcow="$1"
    local bytes rounded

    bytes=$(disk_virtual_size_bytes "$qcow") || {
        log_error "Could not read virtual size of '${qcow}'."
        exit 1
    }

    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        log_error "Could not parse virtual size for '${qcow}'."
        exit 1
    fi

    if is_power_of_two_bytes "$bytes"; then
        log_info "Virtual size ${bytes} bytes is already a power of two (OK for QEMU raspi* SD)."
        return 0
    fi

    rounded=$(ceil_pow2_bytes "$bytes")
    log_info "Rounding '${qcow}' for QEMU raspi* SD (${bytes} -> ${rounded} bytes)..."
    if ! qemu-img resize "$qcow" "$rounded"; then
        log_error "qemu-img resize '${qcow}' ${rounded} failed."
        exit 1
    fi

    bytes=$(disk_virtual_size_bytes "$qcow") || exit 1
    if ! is_power_of_two_bytes "$bytes"; then
        log_error "After resize, virtual size '${bytes}' is still not a power-of-two bytes."
        exit 1
    fi
}

function print_usage_and_exit() {
    echo "Usage: $0 [--raspi-round] <path-to-raw> <output_dir>"
    echo "       $0 --help"
    echo ""
    echo "Converts RAW to qcow2: <output_dir>/<basename(raw)>.qcow2"
    echo "--raspi-round: after convert, grow the qcow2 virtual size (if needed) to the next"
    echo "power-of-two in bytes — required by QEMU raspi* SD models (~3 GiB Pi images -> ~4 GiB)."
    echo "Same when OSEMU_QCOW2_RASPI_ROUND=1."
    exit 0
}

function main() {
    local raspi_round=0 image output_dir bn out

    while [ $# -gt 0 ]; do
        case "$1" in
            --raspi-round | --raspi-sd)
                raspi_round=1
                shift
                ;;
            --help | -h)
                print_usage_and_exit
                ;;
            -*)
                log_error "Unknown option: $1 (try --help)"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    if [ "${OSEMU_QCOW2_RASPI_ROUND:-0}" = 1 ]; then
        raspi_round=1
    fi

    if [ "$#" -ne 2 ]; then
        log_error "Expected exactly two paths after options: <path-to-raw> <output_dir> (seen $# argument(s))"
        exit 1
    fi

    image="${1:-}"
    output_dir="${2:-}"

    bn=$(basename "$image")

    log_info "Converting $image to qcow2 and saving to $output_dir"

    if ! qemu-img convert -f raw -O qcow2 "$image" "${output_dir}/${bn}.qcow2"; then
        log_error "qemu-img convert failed."
        exit 1
    fi

    out="${output_dir}/${bn}.qcow2"

    log_info "Converted $image to $out"

    if [ "$raspi_round" -eq 1 ]; then
        maybe_resize_output_for_raspi_sd "$out"
        log_info "Raspi SD size step complete for ${out}"
    fi
}

main "$@"

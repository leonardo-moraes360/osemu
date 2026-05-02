#!/usr/bin/env bash

function log_error() {
    local message="$1"
    local timestamp=$(date +%Y-%m-%d,\ %H:%M:%S)

    echo -e "\033[31m($$) - $timestamp [ERROR] $message \033[0m"        
}

function log_info() {
    local message="$1"
    local timestamp=$(date +%Y-%m-%d,\ %H:%M:%S)

    echo -e "\033[32m($$) - $timestamp [INFO] $message \033[0m"        
}

function main() {
    local cdrom="$1"
    local image="$2"

    if [ -z "$cdrom" ]; then
        log_error "CDROM is required"
        exit 1
    fi

    if [ -z "$image" ]; then
        log_error "Image is required"
        exit 1
    fi

    log_info "Emulating $image with $cdrom"

    qemu-system-x86_64 -enable-kvm \
        -cdrom "$cdrom" \
        -boot menu=on \
        -drive file="$image" \
        -m 8G
}

main "$@"

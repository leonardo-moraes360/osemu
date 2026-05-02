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
    local image="$1"
    local output_dir="$2"

    log_info "Converting $image to qcow2 and saving to $output_dir"   

    if [ -z "$image" ]; then
        log_error "Image is required to convert to qcow2"
        exit 1
    fi

    basename=$(basename "$image")
    
    qemu-img convert -f raw -O qcow2 "$image" "${output_dir}/${basename}.qcow2"

    log_info "Converted $image to qcow2"   
}

main "$@"

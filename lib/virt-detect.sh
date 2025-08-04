#!/bin/bash

# Virtual Environment Detection Utility
# This library provides functions to detect if the system is running in a virtual environment

# Check if we're running in a virtual environment
is_virtual_environment() {
    local debug_mode=${VIRT_DEBUG:-false}

    # Debug function
    debug_log() {
        if [ "$debug_mode" = "true" ]; then
            echo "DEBUG: $1" >&2
        fi
    }

    # Method 1: Use systemd-detect-virt if available (most reliable)
    if command -v systemd-detect-virt > /dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt 2>/dev/null)
        debug_log "systemd-detect-virt result: '$virt_type'"

        # Only trust systemd-detect-virt if it gives a definitive answer
        case "$virt_type" in
            none)
                debug_log "systemd-detect-virt reports: none (physical hardware)"
                ;;
            vmware|kvm|qemu|virtualbox|xen|microsoft|parallels|bhyve|openvz|lxc|docker|podman)
                echo "Virtual environment detected via systemd-detect-virt: $virt_type" >&2
                return 0
                ;;
            *)
                debug_log "systemd-detect-virt gave unexpected result: $virt_type"
                ;;
        esac
    fi

    # Method 2: Check DMI information (exclude common laptop manufacturers)
    if [ -r /sys/class/dmi/id/sys_vendor ]; then
        local vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null | tr '[:upper:]' '[:lower:]')
        local product=$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr '[:upper:]' '[:lower:]')
        debug_log "DMI vendor: '$vendor', product: '$product'"

        # Check for physical hardware vendors first (whitelist approach)
        case "$vendor" in
            *dell*|*hp*|*hewlett*|*lenovo*|*thinkpad*|*asus*|*acer*|*toshiba*|*sony*|*samsung*|*apple*|*msi*|*gigabyte*|*intel*|*supermicro*)
                debug_log "Recognized physical hardware vendor: $vendor"
                # Don't return early, continue with other checks
                ;;
            *vmware*|*virtualbox*|*qemu*|*kvm*|*xen*|*bochs*|*parallels*)
                echo "Virtual environment detected via DMI vendor: $vendor" >&2
                return 0
                ;;
            *microsoft*)
                # Microsoft could be Hyper-V or Surface hardware
                case "$product" in
                    *virtual*|*hyper-v*)
                        echo "Virtual environment detected via DMI: Microsoft virtualization" >&2
                        return 0
                        ;;
                    *)
                        debug_log "Microsoft hardware (likely Surface): $product"
                        ;;
                esac
                ;;
        esac

        # Check product names for virtualization indicators
        case "$product" in
            *vmware*|*virtualbox*|*qemu*|*kvm*|*xen*|*hyper-v*)
                echo "Virtual environment detected via DMI product: $product" >&2
                return 0
                ;;
            *virtual*machine*)
                echo "Virtual environment detected via DMI product: $product" >&2
                return 0
                ;;
        esac
    fi

    # Method 3: Check CPU flags for hypervisor (be more careful)
    if [ -r /proc/cpuinfo ]; then
        # Check if hypervisor flag exists AND we don't have other indicators of physical hardware
        if grep -q "^flags.*hypervisor" /proc/cpuinfo; then
            debug_log "CPU hypervisor flag found"

            # Additional check: if we have a recognized physical vendor, this might be a false positive
            if [ -r /sys/class/dmi/id/sys_vendor ]; then
                local vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null | tr '[:upper:]' '[:lower:]')
                case "$vendor" in
                    *dell*|*hp*|*hewlett*|*lenovo*|*thinkpad*|*asus*|*acer*|*toshiba*|*sony*|*samsung*|*apple*|*msi*|*gigabyte*|*intel*|*supermicro*)
                        debug_log "Hypervisor flag present but physical vendor detected, likely hardware virtualization support"
                        ;;
                    *)
                        echo "Virtual environment detected via CPU hypervisor flag (unknown vendor)" >&2
                        return 0
                        ;;
                esac
            else
                echo "Virtual environment detected via CPU hypervisor flag" >&2
                return 0
            fi
        fi
    fi

    # Method 4: Check for common virtualization indicators (more selective)
    local virt_indicators=(
        "/proc/xen/capabilities"  # More specific than /proc/xen
        "/proc/vz/version"        # More specific than /proc/vz  
        "/dev/vzctl"
    )

    for indicator in "${virt_indicators[@]}"; do
        if [ -e "$indicator" ]; then
            echo "Virtual environment detected via filesystem indicator: $indicator" >&2
            return 0
        fi
    done

    # Check for active Xen domain (not just Xen support)
    if [ -r /proc/xen/capabilities ] && grep -q "control_d" /proc/xen/capabilities 2>/dev/null; then
        echo "Virtual environment detected via Xen domain capabilities" >&2
        return 0
    fi

    # Method 5: Check for virtualization-specific modules (be more selective)
    if command -v lsmod > /dev/null 2>&1; then
        local virt_modules=$(lsmod 2>/dev/null | grep -E "(vmware|vboxguest|xen_)" | head -5)
        if [ -n "$virt_modules" ]; then
            echo "Virtual environment detected via kernel modules: $(echo "$virt_modules" | awk '{print $1}' | tr '\n' ' ')" >&2
            return 0
        fi

        # virtio modules can exist on physical hardware too, so be more careful
        local virtio_modules=$(lsmod 2>/dev/null | grep -E "^virtio_(net|blk|balloon|scsi|console)" | wc -l)
        if [ "$virtio_modules" -ge 2 ]; then
            debug_log "Multiple virtio modules found ($virtio_modules), likely virtual environment"
            echo "Virtual environment detected via multiple virtio modules" >&2
            return 0
        fi
    fi

    debug_log "No virtualization indicators found, assuming physical hardware"
    return 1
}

# Get the specific virtualization type
get_virtualization_type() {
    if command -v systemd-detect-virt > /dev/null 2>&1; then
        systemd-detect-virt
    else
        if is_virtual_environment; then
            echo "unknown"
        else
            echo "none"
        fi
    fi
}

# Check if running in a container (different from VM)
is_container_environment() {
    if command -v systemd-detect-virt > /dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt --container)
        if [ "$virt_type" != "none" ]; then
            return 0
        fi
    fi

    # Check for container indicators
    if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
        return 0
    fi

    # Check cgroups for container indicators
    if [ -r /proc/1/cgroup ] && grep -E "(docker|lxc|containerd)" /proc/1/cgroup > /dev/null; then
        return 0
    fi

    return 1
}

# Check if physical hardware networking features are available
has_physical_network_features() {
    # In virtual environments, advanced networking features may not be available
    if is_virtual_environment; then
        return 1
    fi

    # Check if we can create bridge interfaces
    if ! ip link add type bridge name test-bridge 2>/dev/null; then
        return 1
    else
        # Clean up test bridge
        ip link delete test-bridge 2>/dev/null || true
        return 0
    fi
}

# Print environment information
print_environment_info() {
    echo "Environment Detection Results:"
    echo "=============================="

    if is_virtual_environment; then
        echo "✓ Virtual environment detected"
        echo "  Type: $(get_virtualization_type)"
    else
        echo "✓ Physical hardware detected"
    fi

    if is_container_environment; then
        echo "✓ Container environment detected"
    fi

    if has_physical_network_features; then
        echo "✓ Physical networking features available"
    else
        echo "✗ Physical networking features not available"
    fi
}

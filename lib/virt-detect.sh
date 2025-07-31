#!/bin/bash

# Virtual Environment Detection Utility
# This library provides functions to detect if the system is running in a virtual environment

# Check if we're running in a virtual environment
is_virtual_environment() {
    # Method 1: Use systemd-detect-virt if available
    if command -v systemd-detect-virt > /dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt)
        if [ "$virt_type" != "none" ]; then
            echo "Virtual environment detected via systemd-detect-virt: $virt_type" >&2
            return 0
        fi
    fi

    # Method 2: Check DMI information
    if [ -r /sys/class/dmi/id/sys_vendor ]; then
        local vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null | tr '[:upper:]' '[:lower:]')
        local product=$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr '[:upper:]' '[:lower:]')

        case "$vendor" in
            *vmware*|*virtualbox*|*microsoft*|*qemu*|*kvm*|*xen*|*bochs*|*parallels*)
                echo "Virtual environment detected via DMI vendor: $vendor" >&2
                return 0
                ;;
        esac

        case "$product" in
            *vmware*|*virtualbox*|*virtual*machine*|*qemu*|*kvm*|*xen*)
                echo "Virtual environment detected via DMI product: $product" >&2
                return 0
                ;;
        esac
    fi

    # Method 3: Check CPU flags for hypervisor
    if [ -r /proc/cpuinfo ] && grep -q "^flags.*hypervisor" /proc/cpuinfo; then
        echo "Virtual environment detected via CPU hypervisor flag" >&2
        return 0
    fi

    # Method 4: Check for common virtualization indicators
    local virt_indicators=(
        "/proc/xen"
        "/sys/bus/xen"
        "/proc/vz"
        "/dev/vzctl"
    )

    for indicator in "${virt_indicators[@]}"; do
        if [ -e "$indicator" ]; then
            echo "Virtual environment detected via filesystem indicator: $indicator" >&2
            return 0
        fi
    done

    # Method 5: Check for virtualization-specific processes or modules
    if lsmod 2>/dev/null | grep -E "(vmware|vboxguest|virtio|xen)" > /dev/null; then
        echo "Virtual environment detected via kernel modules" >&2
        return 0
    fi

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

#!/bin/bash

# Debug Virtual Environment Detection Script
# This script helps diagnose virtual environment detection issues

set -e

echo "======================================="
echo "  Virtual Environment Detection Debug"
echo "======================================="
echo ""

# Load the detection library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/../lib/virt-detect.sh" ]; then
    # Enable debug mode
    export VIRT_DEBUG=true
    source "$SCRIPT_DIR/../lib/virt-detect.sh"
else
    echo "Error: Virtual environment detection library not found"
    exit 1
fi

echo "=== System Information ==="
echo "Kernel: $(uname -r)"
echo "OS: $(uname -o)"
echo "Architecture: $(uname -m)"
echo ""

echo "=== systemd-detect-virt ==="
if command -v systemd-detect-virt > /dev/null 2>&1; then
    echo "Available: Yes"
    echo "Result: $(systemd-detect-virt 2>/dev/null || echo 'ERROR')"
    echo "Container check: $(systemd-detect-virt --container 2>/dev/null || echo 'none')"
    echo "VM check: $(systemd-detect-virt --vm 2>/dev/null || echo 'none')"
else
    echo "Available: No"
fi
echo ""

echo "=== DMI Information ==="
if [ -r /sys/class/dmi/id/sys_vendor ]; then
    echo "Vendor: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo 'N/A')"
    echo "Product: $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'N/A')"
    echo "Version: $(cat /sys/class/dmi/id/product_version 2>/dev/null || echo 'N/A')"
    echo "BIOS Vendor: $(cat /sys/class/dmi/id/bios_vendor 2>/dev/null || echo 'N/A')"
    echo "BIOS Version: $(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo 'N/A')"
else
    echo "DMI information not accessible"
fi
echo ""

echo "=== CPU Information ==="
if [ -r /proc/cpuinfo ]; then
    echo "CPU Model: $(grep '^model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')"
    echo "Hypervisor flag: $(grep '^flags.*hypervisor' /proc/cpuinfo > /dev/null && echo 'Present' || echo 'Absent')"
    echo "Virtualization flags: $(grep '^flags' /proc/cpuinfo | head -1 | grep -o -E '(vmx|svm|hypervisor)' | tr '\n' ' ')"
else
    echo "CPU information not accessible"
fi
echo ""

echo "=== Kernel Modules ==="
if command -v lsmod > /dev/null 2>&1; then
    echo "Virtualization-related modules:"
    lsmod | grep -E "(vmware|vbox|virtio|xen|kvm)" | awk '{print "  " $1}' || echo "  None found"

    echo ""
    echo "All virtio modules:"
    lsmod | grep "^virtio" | awk '{print "  " $1}' || echo "  None found"
else
    echo "lsmod not available"
fi
echo ""

echo "=== Filesystem Indicators ==="
virt_indicators=(
    "/proc/xen"
    "/proc/xen/capabilities"
    "/sys/bus/xen"
    "/proc/vz"
    "/proc/vz/version"
    "/dev/vzctl"
    "/.dockerenv"
    "/run/.containerenv"
)

for indicator in "${virt_indicators[@]}"; do
    if [ -e "$indicator" ]; then
        echo "  ✓ $indicator (exists)"
        # Show contents for key files
        case "$indicator" in
            "/proc/xen/capabilities")
                if [ -r "$indicator" ]; then
                    echo "    Contents: $(cat "$indicator" 2>/dev/null | tr '\n' ' ')"
                fi
                ;;
        esac
    else
        echo "  ✗ $indicator (not found)"
    fi
done

echo ""
echo "=== Xen Analysis ==="
if [ -d /sys/bus/xen ]; then
    echo "  /sys/bus/xen directory exists (Xen support compiled into kernel)"
    echo "  Contents: $(ls -la /sys/bus/xen/ 2>/dev/null | wc -l) items"
    if [ -r /proc/xen/capabilities ]; then
        echo "  Xen capabilities: $(cat /proc/xen/capabilities 2>/dev/null | tr '\n' ' ')"
        if grep -q "control_d" /proc/xen/capabilities 2>/dev/null; then
            echo "  Status: Xen Dom0 (hypervisor control domain)"
        else
            echo "  Status: Xen DomU (guest domain) or inactive"
        fi
    else
        echo "  Status: Xen support present but not active (physical hardware)"
    fi
else
    echo "  No Xen support detected"
fi
echo ""

echo "=== Network Interfaces ==="
if command -v ip > /dev/null 2>&1; then
    echo "Network interfaces:"
    ip link show | grep '^[0-9]' | awk '{print "  " $2}' | sed 's/:$//'
else
    echo "ip command not available"
fi
echo ""

echo "=== Detection Test ==="
echo "Running is_virtual_environment() with debug enabled..."
echo ""

if is_virtual_environment; then
    echo ""
    echo "RESULT: Virtual environment detected"
    echo "Type: $(get_virtualization_type)"
else
    echo ""
    echo "RESULT: Physical hardware detected"
fi

echo ""
echo "=== Container Detection ==="
if is_container_environment; then
    echo "Container environment: Yes"
else
    echo "Container environment: No"
fi

echo ""
echo "=== Network Features Test ==="
if has_physical_network_features; then
    echo "Physical networking features: Available"
else
    echo "Physical networking features: Not available"
fi

echo ""
echo "======================================="
echo "  Debug Information Complete"
echo "======================================="

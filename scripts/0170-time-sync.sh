#!/bin/bash

# System Time Synchronization Setup Script for Manjaro Linux
# This script enables NTP time synchronization and ensures systemd-timesyncd service is active

set -e

echo "================================"
echo "  System Time Synchronization"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

echo "Step 1: Checking current time synchronization status..."
echo ""

# Show current time and timezone
echo "Current system time: $(date)"
echo "Current timezone: $(timedatectl show --property=Timezone --value)"
echo "Current NTP status: $(timedatectl show --property=NTP --value)"
echo ""

# Check if NTP is already enabled
if timedatectl show --property=NTP --value | grep -q "yes"; then
    echo "✓ NTP is already enabled"
    NTP_ALREADY_ENABLED=true
else
    echo "- NTP is currently disabled"
    NTP_ALREADY_ENABLED=false
fi

# Check systemd-timesyncd service status
echo ""
echo "Step 2: Checking systemd-timesyncd service status..."

if systemctl is-enabled systemd-timesyncd.service >/dev/null 2>&1; then
    echo "✓ systemd-timesyncd.service is enabled"
    TIMESYNCD_ENABLED=true
else
    echo "- systemd-timesyncd.service is not enabled"
    TIMESYNCD_ENABLED=false
fi

if systemctl is-active systemd-timesyncd.service >/dev/null 2>&1; then
    echo "✓ systemd-timesyncd.service is active"
    TIMESYNCD_ACTIVE=true
else
    echo "- systemd-timesyncd.service is not active"
    TIMESYNCD_ACTIVE=false
fi

echo ""
echo "Step 3: Configuring time synchronization..."

# Enable systemd-timesyncd service if not already enabled
if [ "$TIMESYNCD_ENABLED" = false ]; then
    echo "Enabling systemd-timesyncd.service..."
    sudo systemctl enable systemd-timesyncd.service
    echo "✓ systemd-timesyncd.service enabled"
else
    echo "✓ systemd-timesyncd.service already enabled"
fi

# Start systemd-timesyncd service if not already active
if [ "$TIMESYNCD_ACTIVE" = false ]; then
    echo "Starting systemd-timesyncd.service..."
    sudo systemctl start systemd-timesyncd.service
    echo "✓ systemd-timesyncd.service started"
else
    echo "✓ systemd-timesyncd.service already active"
fi

# Enable NTP if not already enabled
if [ "$NTP_ALREADY_ENABLED" = false ]; then
    echo "Enabling NTP time synchronization..."
    sudo timedatectl set-ntp true
    echo "✓ NTP time synchronization enabled"
else
    echo "✓ NTP time synchronization already enabled"
fi

echo ""
echo "Step 4: Verifying configuration..."

# Wait a moment for services to stabilize
sleep 2

# Verify final status
echo "Final system status:"
echo "- System time: $(date)"
echo "- Timezone: $(timedatectl show --property=Timezone --value)"
echo "- NTP enabled: $(timedatectl show --property=NTP --value)"
echo "- NTP synchronized: $(timedatectl show --property=NTPSynchronized --value)"
echo ""

# Check service status
if systemctl is-enabled systemd-timesyncd.service >/dev/null 2>&1 && \
   systemctl is-active systemd-timesyncd.service >/dev/null 2>&1; then
    echo "✓ systemd-timesyncd.service: enabled and active"
else
    echo "✗ systemd-timesyncd.service: configuration issue"
    exit 1
fi

# Check NTP status
if timedatectl show --property=NTP --value | grep -q "yes"; then
    echo "✓ NTP synchronization: enabled"
else
    echo "✗ NTP synchronization: failed to enable"
    exit 1
fi

echo ""
echo "Time synchronization setup completed successfully!"
echo ""
echo "SUMMARY:"
echo "✓ NTP time synchronization enabled"
echo "✓ systemd-timesyncd.service enabled and active"
echo "✓ System will automatically synchronize time with NTP servers"
echo ""
echo "IMPORTANT:"
echo "- Time will be automatically synchronized with internet time servers"
echo "- System clock will stay accurate even after reboots"
echo "- Use 'timedatectl status' to check synchronization status"
echo "- Use 'timedatectl list-timezones' to see available timezones"
echo "- Use 'timedatectl set-timezone <timezone>' to change timezone"
echo "================================"

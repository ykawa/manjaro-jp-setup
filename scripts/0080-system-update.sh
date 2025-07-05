#!/bin/bash

# System Update Script for Manjaro Linux
# This script updates the system packages and package database

set -e

echo "================================"
echo "  System Update Script"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# なによりも先にキーリングを更新しておく
echo "Updating archlinux-keyring..."
sudo pacman -S --noconfirm archlinux-keyring

echo "Updating package database..."
sudo pacman -Sy

echo ""
echo "Upgrading system packages..."
sudo pacman -Su --noconfirm

echo ""
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo ""
echo "setting japanese mirror..."
sudo pacman-mirrors -c Japan
sudo pacman -Syu --noconfirm

echo ""
echo "System update completed successfully!"
echo "================================"

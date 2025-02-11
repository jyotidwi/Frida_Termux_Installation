#!/usr/bin/env bash
if ! command -v termux-setup-storage &>/dev/null; then
  echo "This script can be executed only on Termux"
  exit 1
fi

# Detect architecture
case "$(uname -m)" in
    aarch64)
        arch="arm64"
        ;;
    armv7l | armv8l)
        arch="arm"
        ;;
    x86_64)
        arch="x86_64"
        ;;
    x86)
        arch="x86"
        ;;
    *)
        echo "System architecture not recognized: $(uname -m)"
        exit 1
        ;;
esac

cd $TMPDIR

# Update and install required packages
apt update && pkg upgrade -y
pkg i -y python git curl && pip install -U setuptools

# Fetch latest Frida version
FRIDA_VERSION=$(curl --silent "https://api.github.com/repos/Alexjr2/Frida_Termux_Installation/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Download Frida devkit
DEVKIT_URL="https://github.com/Alexjr2/Frida_Termux_Installation/releases/download/$FRIDA_VERSION/frida-core-devkit-android-$arch.tar.xz"
DEVKIT_FILE="frida-core-devkit-android-$arch.tar.xz"

curl -L -o "$DEVKIT_FILE" "$DEVKIT_URL"

# Extract devkit
mkdir -p devkit && tar -xJvf "$DEVKIT_FILE" -C devkit

# Clone and install Frida Python
git clone https://github.com/AbhiTheModder/frida-python frida-python-android

cd frida-python-android

FRIDA_VERSION="$FRIDA_VERSION" FRIDA_CORE_DEVKIT="$PWD/../devkit" pip install --force-reinstall .

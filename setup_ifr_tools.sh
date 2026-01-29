#!/usr/bin/env bash
# Script to download and setup required external tools for UEFI IFR analysis
# These tools allow manual extraction of BIOS modules and IFR data to find
# hidden BIOS options and key combinations

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_DIR="${SCRIPT_DIR}/external"

# Tool versions (update these when upgrading tools)
IFREXTRACTOR_VERSION="1.6.0"
UEFIFIND_VERSION="A73"
UEFIEXTRACT_VERSION="A73"

# Note: Official SHA256 checksums are not provided by LongSoft
# Consider verifying downloads manually or checking file types after download

echo "=========================================="
echo "UEFI IFR Analysis Tools Setup"
echo "=========================================="
echo ""
echo "⚠️  SECURITY NOTICE:"
echo "This script downloads prebuilt binaries from GitHub."
echo "Only run this script if you trust the source repositories:"
echo "  - https://github.com/LongSoft/IFRExtractor-RS"
echo "  - https://github.com/LongSoft/UEFITool"
echo ""

# Create external directory if it doesn't exist
mkdir -p "${EXTERNAL_DIR}"

# Download IFRExtractor-RS v1.6.0
echo "1. Downloading IFRExtractor-RS v${IFREXTRACTOR_VERSION}..."
IFREXTRACTOR_URL="https://github.com/LongSoft/IFRExtractor-RS/releases/download/v${IFREXTRACTOR_VERSION}/ifrextractor_${IFREXTRACTOR_VERSION}_linux.zip"
IFREXTRACTOR_ZIP="${EXTERNAL_DIR}/ifrextractor.zip"

if [ ! -f "${EXTERNAL_DIR}/ifrextractor" ]; then
    echo "   Downloading..."
    if ! curl -fL "${IFREXTRACTOR_URL}" -o "${IFREXTRACTOR_ZIP}"; then
        echo "   ✗ Download failed. Please check your internet connection."
        exit 1
    fi
    unzip -o "${IFREXTRACTOR_ZIP}" -d "${EXTERNAL_DIR}" > /dev/null 2>&1
    if [ -f "${EXTERNAL_DIR}/ifrextractor" ]; then
        chmod +x "${EXTERNAL_DIR}/ifrextractor"
        # Verify it's a valid ELF binary
        if file "${EXTERNAL_DIR}/ifrextractor" | grep -q "ELF"; then
            echo "   ✓ IFRExtractor installed"
        else
            echo "   ✗ Downloaded file is not a valid binary"
            rm -f "${EXTERNAL_DIR}/ifrextractor"
            exit 1
        fi
    else
        echo "   ✗ IFRExtractor installation failed"
        exit 1
    fi
    rm -f "${IFREXTRACTOR_ZIP}"
else
    echo "   ✓ IFRExtractor already installed"
fi

# Download UEFIFind NE A73
echo "2. Downloading UEFIFind NE ${UEFIFIND_VERSION}..."
UEFIFIND_URL="https://github.com/LongSoft/UEFITool/releases/download/${UEFIFIND_VERSION}/UEFIFind_NE_${UEFIFIND_VERSION}_x64_linux.zip"
UEFIFIND_ZIP="${EXTERNAL_DIR}/uefifind.zip"

if [ ! -f "${EXTERNAL_DIR}/uefifind" ]; then
    curl -fsSL "${UEFIFIND_URL}" -o "${UEFIFIND_ZIP}"
    # Note: Add checksum verification here if official checksums become available
    unzip -o "${UEFIFIND_ZIP}" -d "${EXTERNAL_DIR}"
    if [ -f "${EXTERNAL_DIR}/uefifind" ]; then
        chmod +x "${EXTERNAL_DIR}/uefifind"
        echo "   ✓ UEFIFind installed"
    else
        echo "   ✗ UEFIFind installation failed"
        exit 1
    fi
    rm -f "${UEFIFIND_ZIP}"
else
    echo "   ✓ UEFIFind already installed"
fi

# Download UEFIExtract NE A73
echo "3. Downloading UEFIExtract NE ${UEFIEXTRACT_VERSION}..."
UEFIEXTRACT_URL="https://github.com/LongSoft/UEFITool/releases/download/${UEFIEXTRACT_VERSION}/UEFIExtract_NE_${UEFIEXTRACT_VERSION}_x64_linux.zip"
UEFIEXTRACT_ZIP="${EXTERNAL_DIR}/uefiextract.zip"

if [ ! -f "${EXTERNAL_DIR}/uefiextract" ]; then
    curl -fsSL "${UEFIEXTRACT_URL}" -o "${UEFIEXTRACT_ZIP}"
    # Note: Add checksum verification here if official checksums become available
    unzip -o "${UEFIEXTRACT_ZIP}" -d "${EXTERNAL_DIR}"
    if [ -f "${EXTERNAL_DIR}/uefiextract" ]; then
        chmod +x "${EXTERNAL_DIR}/uefiextract"
        echo "   ✓ UEFIExtract installed"
    else
        echo "   ✗ UEFIExtract installation failed"
        exit 1
    fi
    rm -f "${UEFIEXTRACT_ZIP}"
else
    echo "   ✓ UEFIExtract already installed"
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installed tools in ${EXTERNAL_DIR}:"
ls -lh "${EXTERNAL_DIR}" | grep -E "(ifrextractor|uefifind|uefiextract)" || echo "No tools found"
echo ""
echo "Tool versions:"
echo "  IFRExtractor: v${IFREXTRACTOR_VERSION}"
echo "  UEFIFind:     v${UEFIFIND_VERSION}"
echo "  UEFIExtract:  v${UEFIEXTRACT_VERSION}"
echo ""
echo "Next steps:"
echo "1. Use extract_bios_ifr.sh to analyze a BIOS file"
echo "2. Or follow the manual steps in MANUAL_ANALYSIS_GUIDE.md"
echo ""

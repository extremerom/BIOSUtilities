#!/usr/bin/env bash
# Script to download and setup required external tools for UEFI IFR analysis
# These tools allow manual extraction of BIOS modules and IFR data to find
# hidden BIOS options and key combinations

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_DIR="${SCRIPT_DIR}/external"

echo "=========================================="
echo "UEFI IFR Analysis Tools Setup"
echo "=========================================="
echo ""

# Create external directory if it doesn't exist
mkdir -p "${EXTERNAL_DIR}"

# Download IFRExtractor-RS v1.6.0
echo "1. Downloading IFRExtractor-RS v1.6.0..."
IFREXTRACTOR_URL="https://github.com/LongSoft/IFRExtractor-RS/releases/download/v1.6.0/ifrextractor_1.6.0_linux.zip"
IFREXTRACTOR_ZIP="${EXTERNAL_DIR}/ifrextractor.zip"

if [ ! -f "${EXTERNAL_DIR}/ifrextractor" ]; then
    curl -L "${IFREXTRACTOR_URL}" -o "${IFREXTRACTOR_ZIP}"
    unzip -o "${IFREXTRACTOR_ZIP}" -d "${EXTERNAL_DIR}"
    chmod +x "${EXTERNAL_DIR}/ifrextractor" 2>/dev/null || true
    rm -f "${IFREXTRACTOR_ZIP}"
    echo "   ✓ IFRExtractor installed"
else
    echo "   ✓ IFRExtractor already installed"
fi

# Download UEFIFind NE A73
echo "2. Downloading UEFIFind NE A73..."
UEFIFIND_URL="https://github.com/LongSoft/UEFITool/releases/download/A73/UEFIFind_NE_A73_x64_linux.zip"
UEFIFIND_ZIP="${EXTERNAL_DIR}/uefifind.zip"

if [ ! -f "${EXTERNAL_DIR}/uefifind" ]; then
    curl -L "${UEFIFIND_URL}" -o "${UEFIFIND_ZIP}"
    unzip -o "${UEFIFIND_ZIP}" -d "${EXTERNAL_DIR}"
    chmod +x "${EXTERNAL_DIR}/uefifind" 2>/dev/null || true
    rm -f "${UEFIFIND_ZIP}"
    echo "   ✓ UEFIFind installed"
else
    echo "   ✓ UEFIFind already installed"
fi

# Download UEFIExtract NE A73
echo "3. Downloading UEFIExtract NE A73..."
UEFIEXTRACT_URL="https://github.com/LongSoft/UEFITool/releases/download/A73/UEFIExtract_NE_A73_x64_linux.zip"
UEFIEXTRACT_ZIP="${EXTERNAL_DIR}/uefiextract.zip"

if [ ! -f "${EXTERNAL_DIR}/uefiextract" ]; then
    curl -L "${UEFIEXTRACT_URL}" -o "${UEFIEXTRACT_ZIP}"
    unzip -o "${UEFIEXTRACT_ZIP}" -d "${EXTERNAL_DIR}"
    chmod +x "${EXTERNAL_DIR}/uefiextract" 2>/dev/null || true
    rm -f "${UEFIEXTRACT_ZIP}"
    echo "   ✓ UEFIExtract installed"
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
echo "Next steps:"
echo "1. Use extract_bios_ifr.sh to analyze a BIOS file"
echo "2. Or follow the manual steps in UEFI_IFR_ANALYSIS.md"
echo ""

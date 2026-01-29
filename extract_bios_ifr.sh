#!/usr/bin/env bash
# Script para extraer módulos BIOS y datos IFR para análisis de opciones avanzadas
# Extract BIOS modules and IFR data to find advanced BIOS options and key combinations

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_DIR="${SCRIPT_DIR}/external"

# Check if tools are installed
if [ ! -f "${EXTERNAL_DIR}/ifrextractor" ] || [ ! -f "${EXTERNAL_DIR}/uefifind" ] || [ ! -f "${EXTERNAL_DIR}/uefiextract" ]; then
    echo "Error: Tools not found. Please run setup_ifr_tools.sh first."
    exit 1
fi

# Check if BIOS file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <bios_file>"
    echo ""
    echo "Example: $0 mybios.bin"
    echo ""
    echo "This script will:"
    echo "  1. Extract all UEFI modules from the BIOS"
    echo "  2. Find Setup-related modules"
    echo "  3. Extract IFR data from each module"
    echo "  4. Search for key combinations in IFR data"
    exit 1
fi

BIOS_FILE="$1"

if [ ! -f "${BIOS_FILE}" ]; then
    echo "Error: BIOS file '${BIOS_FILE}' not found"
    exit 1
fi

# Create output directory
BIOS_NAME=$(basename "${BIOS_FILE}" | sed 's/\.[^.]*$//')
OUTPUT_DIR="./out/${BIOS_NAME}_analysis"
mkdir -p "${OUTPUT_DIR}"

echo "=========================================="
echo "UEFI IFR Analysis"
echo "=========================================="
echo ""
echo "BIOS file: ${BIOS_FILE}"
echo "Output directory: ${OUTPUT_DIR}"
echo ""

# Step 1: Extract all UEFI modules
echo "Step 1: Extracting UEFI modules..."
MODULES_DIR="${OUTPUT_DIR}/01_modules"
mkdir -p "${MODULES_DIR}"

"${EXTERNAL_DIR}/uefiextract" "${BIOS_FILE}" -o "${MODULES_DIR}" -m body > /dev/null 2>&1 || true
echo "   ✓ Modules extracted to ${MODULES_DIR}"
echo ""

# Step 2: Search for Setup-related modules
echo "Step 2: Searching for Setup modules..."
SEARCH_LOG="${OUTPUT_DIR}/02_setup_search.log"

echo "Searching for 'Setup' keyword..." > "${SEARCH_LOG}"
"${EXTERNAL_DIR}/uefifind" "${BIOS_FILE}" text "Setup" >> "${SEARCH_LOG}" 2>&1 || true

echo "Searching for 'Advanced' keyword..." >> "${SEARCH_LOG}"
"${EXTERNAL_DIR}/uefifind" "${BIOS_FILE}" text "Advanced" >> "${SEARCH_LOG}" 2>&1 || true

echo "Searching for 'Security' keyword..." >> "${SEARCH_LOG}"
"${EXTERNAL_DIR}/uefifind" "${BIOS_FILE}" text "Security" >> "${SEARCH_LOG}" 2>&1 || true

echo "   ✓ Search results saved to ${SEARCH_LOG}"
echo ""

# Step 3: Extract IFR data from PE32 modules
echo "Step 3: Extracting IFR data from modules..."
IFR_DIR="${OUTPUT_DIR}/03_ifr_data"
mkdir -p "${IFR_DIR}"

IFR_COUNT=0
# Find all PE32 files (check for MZ signature)
find "${MODULES_DIR}" -type f -exec sh -c '
    if head -c 2 "$1" 2>/dev/null | grep -q "MZ"; then
        echo "$1"
    fi
' sh {} \; > "${OUTPUT_DIR}/.pe_files.tmp"

while IFS= read -r PE_FILE; do
    if [ -f "${PE_FILE}" ]; then
        BASENAME=$(basename "${PE_FILE}")
        IFR_OUTPUT="${IFR_DIR}/${BASENAME}.txt"
        
        if "${EXTERNAL_DIR}/ifrextractor" "${PE_FILE}" "${IFR_OUTPUT}" > /dev/null 2>&1; then
            if [ -s "${IFR_OUTPUT}" ]; then
                IFR_COUNT=$((IFR_COUNT + 1))
            else
                rm -f "${IFR_OUTPUT}"
            fi
        fi
    fi
done < "${OUTPUT_DIR}/.pe_files.tmp"

rm -f "${OUTPUT_DIR}/.pe_files.tmp"
echo "   ✓ Extracted IFR data from ${IFR_COUNT} module(s)"
echo ""

# Step 4: Search for key combinations in IFR data
echo "Step 4: Searching for key combinations..."
KEYS_LOG="${OUTPUT_DIR}/04_key_combinations.txt"

echo "============================================" > "${KEYS_LOG}"
echo "Key Combinations and Hidden Options Found" >> "${KEYS_LOG}"
echo "============================================" >> "${KEYS_LOG}"
echo "" >> "${KEYS_LOG}"

# Search patterns for key combinations
PATTERNS=(
    "Ctrl"
    "Alt"
    "F1"
    "F2"
    "F3"
    "F4"
    "F10"
    "F11"
    "F12"
    "hotkey"
    "HotKey"
    "Key"
    "hidden"
    "Hidden"
    "suppress"
    "Suppress"
)

FOUND_KEYS=0

for PATTERN in "${PATTERNS[@]}"; do
    if grep -r -i "${PATTERN}" "${IFR_DIR}" > /dev/null 2>&1; then
        echo "Pattern '${PATTERN}' found in:" >> "${KEYS_LOG}"
        grep -r -i -H -n "${PATTERN}" "${IFR_DIR}" 2>/dev/null | head -20 >> "${KEYS_LOG}" || true
        echo "" >> "${KEYS_LOG}"
        FOUND_KEYS=1
    fi
done

if [ ${FOUND_KEYS} -eq 0 ]; then
    echo "No obvious key combinations found." >> "${KEYS_LOG}"
    echo "" >> "${KEYS_LOG}"
    echo "Manual analysis recommended:" >> "${KEYS_LOG}"
    echo "- Review IFR files in ${IFR_DIR}" >> "${KEYS_LOG}"
    echo "- Look for form definitions and question IDs" >> "${KEYS_LOG}"
    echo "- Common hidden options use Ctrl+F1, Ctrl+F2, etc." >> "${KEYS_LOG}"
fi

echo "   ✓ Key search results saved to ${KEYS_LOG}"
echo ""

# Step 5: Create summary
SUMMARY="${OUTPUT_DIR}/README.txt"

cat > "${SUMMARY}" << EOF
========================================
UEFI BIOS IFR Analysis Summary
========================================

Input File: ${BIOS_FILE}
Analysis Date: $(date)

Directory Structure:
--------------------
01_modules/           - All extracted UEFI modules
02_setup_search.log   - Search results for Setup keywords
03_ifr_data/          - IFR text files extracted from modules
04_key_combinations.txt - Potential key combinations found

Statistics:
-----------
IFR Files Extracted: ${IFR_COUNT}

How to Find Hidden BIOS Options:
---------------------------------
1. Review 04_key_combinations.txt for any found patterns
2. Manually review IFR files in 03_ifr_data/ directory
3. Look for:
   - "Suppress If" statements (hidden options)
   - "GrayOut If" statements (disabled options)
   - Key combinations (Ctrl+F1, Alt+F2, etc.)
   - QuestionId values that might be unlockable

Common Key Combinations for Advanced BIOS:
-------------------------------------------
- Ctrl + F1     (Most common for advanced menu)
- Ctrl + F2
- Alt + F1
- Alt + F2
- Shift + F1
- Right Ctrl + Right Shift + F2
- Left Alt + Right Alt + F2

Note: Key combinations are often pressed at POST screen
or in specific BIOS menus. Some require holding during boot.

Tools Used:
-----------
- UEFIExtract v${EXTERNAL_DIR}/uefiextract (for module extraction)
- UEFIFind (for keyword searching)
- IFRExtractor v1.6.0 (for IFR data extraction)

For More Information:
---------------------
See UEFI_IFR_ANALYSIS.md for detailed manual analysis steps.
See BIOS_KEY_COMBINATIONS.md for comprehensive list of known key
combinations by manufacturer and model.
EOF

echo "=========================================="
echo "Analysis Complete!"
echo "=========================================="
echo ""
echo "Results saved to: ${OUTPUT_DIR}"
echo ""
echo "Next steps:"
echo "1. Check ${KEYS_LOG}"
echo "2. Review IFR files in ${IFR_DIR}"
echo "3. Try common key combinations (Ctrl+F1, etc.) in BIOS"
echo ""
cat "${KEYS_LOG}"
echo ""

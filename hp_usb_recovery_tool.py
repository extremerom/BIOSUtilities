#!/usr/bin/env python3 -B
# coding=utf-8

"""
HP BIOS Recovery USB Organizer - Command Line Tool

Copyright (C) 2018-2025 Plato Mavropoulos

This utility organizes extracted BIOS files into a USB recovery structure
for HP laptop BIOS recovery.
"""

import sys
from pathlib import Path

# Add biosutilities to path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from biosutilities.hp_usb_recovery import organize_hp_usb_recovery


def main():
    """Main entry point for HP USB recovery organizer."""
    
    print('=' * 70)
    print('HP BIOS Recovery USB Organizer')
    print('Part of BIOSUtilities Project')
    print('=' * 70)
    print()
    
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        print('This tool organizes extracted HP BIOS files into a USB recovery structure.')
        print()
        print('Usage:')
        print('  python hp_usb_recovery_tool.py <input_directory> [output_directory]')
        print()
        print('Arguments:')
        print('  input_directory   - Directory containing extracted BIOS files')
        print('                      (usually ends with _extracted or _extracted_3rd)')
        print('  output_directory  - Optional: Where to create USB recovery structure')
        print('                      (default: HP_USB_Recovery in current directory)')
        print()
        print('Examples:')
        print('  python hp_usb_recovery_tool.py ./out/Winflash.exe_extracted_3rd')
        print('  python hp_usb_recovery_tool.py ./out/Update_extracted ./USB_Recovery')
        print()
        print('Output:')
        print('  Creates an organized folder structure ready to be copied to a USB drive')
        print('  for HP laptop BIOS recovery.')
        print()
        sys.exit(0 if len(sys.argv) >= 2 else 1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else ''
    
    # Validate input directory exists
    if not Path(input_path).exists():
        print(f'❌ Error: Input directory does not exist: {input_path}')
        sys.exit(1)
    
    if not Path(input_path).is_dir():
        print(f'❌ Error: Input path is not a directory: {input_path}')
        sys.exit(1)
    
    # Run the organizer
    success = organize_hp_usb_recovery(input_path, output_path)
    
    if success:
        print('\n' + '=' * 70)
        print('✓ SUCCESS: HP BIOS recovery USB structure created!')
        print('=' * 70)
        sys.exit(0)
    else:
        print('\n' + '=' * 70)
        print('❌ FAILED: Could not create HP BIOS recovery USB structure')
        print('=' * 70)
        sys.exit(1)


if __name__ == '__main__':
    main()

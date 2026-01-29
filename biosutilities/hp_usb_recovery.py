#!/usr/bin/env python3 -B
# coding=utf-8

"""
HP BIOS Recovery USB Organizer

Copyright (C) 2018-2025 Plato Mavropoulos
"""

import os
import shutil
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from biosutilities.common.paths import runtime_root


class HpUsbRecoveryOrganizer:
    """
    Organizes extracted HP BIOS files into a USB recovery structure.
    
    This utility takes extracted BIOS files and organizes them into the
    proper folder structure for creating a bootable USB drive for HP
    laptop BIOS recovery.
    """
    
    def __init__(self, input_path: str = '', output_path: str = ''):
        """
        Initialize the HP USB Recovery Organizer.
        
        Args:
            input_path: Path to the extracted BIOS files directory
            output_path: Path where the organized USB structure will be created
        """
        self.input_path = Path(input_path) if input_path else Path(runtime_root())
        self.output_path = Path(output_path) if output_path else Path(runtime_root()) / 'HP_USB_Recovery'
    
    def organize_structure(self) -> bool:
        """
        Organize the extracted files into HP BIOS recovery USB structure.
        
        Returns:
            bool: True if organization was successful, False otherwise
        """
        try:
            # Create output directory if it doesn't exist
            self.output_path.mkdir(parents=True, exist_ok=True)
            
            print(f'Organizing HP BIOS recovery USB structure...')
            print(f'Input: {self.input_path}')
            print(f'Output: {self.output_path}')
            
            # Find and copy BIOS binary files to root
            self._organize_bios_files()
            
            # Organize HP utilities and EFI files
            self._organize_hp_folder()
            
            # Copy signature files
            self._organize_signature_files()
            
            # Create README with instructions
            self._create_readme()
            
            print(f'\nHP BIOS recovery USB structure created successfully!')
            print(f'Location: {self.output_path}')
            print(f'\nTo use:')
            print(f'1. Format a USB drive as FAT32')
            print(f'2. Copy all contents from {self.output_path} to the USB drive root')
            print(f'3. Boot the HP laptop with the USB drive inserted')
            print(f'4. Follow HP BIOS recovery procedure (usually Win+B or Fn+B at startup)')
            
            return True
            
        except Exception as error:
            print(f'Error organizing HP USB recovery structure: {error}')
            return False
    
    def _organize_bios_files(self):
        """Find and copy BIOS binary files to the HP BIOS recovery structure."""
        print('\n[1/4] Organizing BIOS binary files...')
        
        # Create the official HP BIOS recovery folder structure
        # USB/Hewlett-Packard/BIOS/Current/
        hp_bios_path = self.output_path / 'Hewlett-Packard' / 'BIOS' / 'Current'
        hp_bios_path.mkdir(parents=True, exist_ok=True)
        
        # Look for BIOS binary files (typically BIOS_XX.bin)
        bios_files = list(self.input_path.glob('BIOS_*.bin'))
        sig_files = list(self.input_path.glob('BIOS_*.sig'))
        
        if bios_files:
            # Copy ALL BIOS binary files to the Current folder
            # HP recovery process needs all components
            for bios_file in bios_files:
                dest = hp_bios_path / bios_file.name
                shutil.copy2(bios_file, dest)
                print(f'  ✓ Copied {bios_file.name} to Hewlett-Packard/BIOS/Current/ ({bios_file.stat().st_size:,} bytes)')
            
            # Copy signature files
            for sig_file in sig_files:
                dest = hp_bios_path / sig_file.name
                shutil.copy2(sig_file, dest)
                print(f'  ✓ Copied {sig_file.name} to Hewlett-Packard/BIOS/Current/')
            
            # Also create a backup directory at root for reference
            bios_backup_dir = self.output_path / 'BIOS_Backup'
            bios_backup_dir.mkdir(exist_ok=True)
            
            for bios_file in bios_files:
                dest = bios_backup_dir / bios_file.name
                shutil.copy2(bios_file, dest)
        else:
            print('  ⚠ No BIOS binary files found')
    
    def _organize_hp_folder(self):
        """Organize HP utilities and EFI files."""
        print('\n[2/4] Organizing HP utilities and EFI files...')
        
        # Look for HP folder in input
        hp_source = self.input_path / 'HP'
        
        if hp_source.exists() and hp_source.is_dir():
            hp_dest = self.output_path / 'HP'
            
            # Copy entire HP folder structure
            if hp_dest.exists():
                shutil.rmtree(hp_dest)
            shutil.copytree(hp_source, hp_dest)
            
            # Count files copied
            file_count = sum(1 for _ in hp_dest.rglob('*') if _.is_file())
            print(f'  ✓ Copied HP folder structure ({file_count} files)')
            
            # Also copy EFI files to root for easier access during recovery
            efi_root = self.output_path / 'EFI_Tools'
            efi_root.mkdir(exist_ok=True)
            
            # Find and copy key EFI files
            for efi_file in hp_dest.rglob('*.efi'):
                if 'HpBiosUpdate' in efi_file.name or 'HpBiosMgmt' in efi_file.name:
                    dest = efi_root / efi_file.name
                    shutil.copy2(efi_file, dest)
                    print(f'  ✓ Copied {efi_file.name} to EFI_Tools/')
        else:
            print('  ⚠ HP folder not found in input directory')
    
    def _organize_signature_files(self):
        """Signature files are already copied with BIOS files to Current folder."""
        print('\n[3/4] Organizing signature files...')
        print('  ✓ Signature files copied to Hewlett-Packard/BIOS/Current/')
    
    def _create_readme(self):
        """Create a README file with instructions."""
        print('\n[4/4] Creating README with instructions...')
        
        readme_content = """# HP BIOS Recovery USB Drive

This USB drive contains the necessary files for HP laptop BIOS recovery.

## ⚠️ CRITICAL: Folder Structure

HP BIOS recovery requires files to be in a SPECIFIC folder structure:

```
USB Drive (Root)
└── Hewlett-Packard/
    └── BIOS/
        └── Current/
            ├── BIOS_00.bin
            ├── BIOS_00.sig
            ├── BIOS_01.bin
            ├── BIOS_01.sig
            ├── BIOS_02.bin
            └── BIOS_02.sig
```

⚠️ **DO NOT CHANGE** this folder structure! The HP BIOS recovery process specifically looks for files in the `Hewlett-Packard/BIOS/Current/` directory.

## Contents

- **Hewlett-Packard/BIOS/Current/**: Official HP BIOS recovery folder
  - Contains all BIOS binary files (*.bin) and signature files (*.sig)
- **HP/**: HP utilities and EFI files
- **EFI_Tools/**: Key EFI recovery tools  
- **BIOS_Backup/**: Backup copy of all extracted BIOS files

## How to Use

### Preparation
1. Format a USB drive as FAT32 (recommended: 8GB or larger)
2. Copy ALL contents of this folder to the root of the USB drive
3. Verify that the folder structure is: `[USB Drive]/Hewlett-Packard/BIOS/Current/`
4. Safely eject the USB drive

### BIOS Recovery Process
1. **Turn off** the HP laptop completely
2. **Insert** the prepared USB drive into the laptop
3. **Press and hold** Win+B (or Fn+B on some models) keys
4. While holding the keys, **press the Power button**
5. Keep holding Win+B (or Fn+B) for about 10-15 seconds
6. The laptop should detect the USB and start the recovery process
7. **Wait** for the process to complete (may take several minutes)
8. The laptop will restart automatically when done

### Important Notes

⚠️ **WARNING**: 
- Do NOT interrupt the BIOS recovery process
- Keep the laptop connected to AC power during recovery
- Do NOT remove the USB drive until the process is complete
- The laptop may restart multiple times - this is normal
- DO NOT modify the Hewlett-Packard/BIOS/Current/ folder structure

ℹ️ **Compatibility**:
- This recovery structure is designed for HP laptops
- Different HP models may have different key combinations
- Some models use Win+V instead of Win+B
- Consult your laptop's documentation for specific recovery instructions

ℹ️ **Alternative Recovery Methods**:
- If Win+B doesn't work, try Win+V
- Some HP models require Fn+Esc, then Fn+B
- Check HP support website for model-specific recovery instructions

## File Information

The BIOS files in this structure were extracted using BIOSUtilities.
For more information, visit: https://github.com/platomav/BIOSUtilities

## Troubleshooting

**Recovery doesn't start:**
- Ensure USB is formatted as FAT32 (not exFAT or NTFS)
- Verify the folder structure is exactly: Hewlett-Packard/BIOS/Current/
- Try different USB ports (prefer USB 2.0 ports)
- Verify the key combination for your specific HP model
- Some models require Fn+Esc, then Fn+B

**Recovery fails:**
- Ensure BIOS file matches your exact laptop model
- Check HP support for model-specific recovery files
- Battery should be charged or AC adapter connected

**For more help:**
- Visit HP Support: https://support.hp.com
- Search for "HP BIOS recovery" + your model number

---
Generated by BIOSUtilities HP USB Recovery Organizer
"""
        
        readme_path = self.output_path / 'README_BIOS_RECOVERY.txt'
        readme_path.write_text(readme_content, encoding='utf-8')
        print(f'  ✓ Created README_BIOS_RECOVERY.txt')


def organize_hp_usb_recovery(input_dir: str, output_dir: str = '') -> bool:
    """
    Convenience function to organize HP BIOS recovery USB structure.
    
    Args:
        input_dir: Path to the extracted BIOS files directory
        output_dir: Optional path for organized USB structure output
        
    Returns:
        bool: True if successful, False otherwise
    """
    organizer = HpUsbRecoveryOrganizer(input_dir, output_dir)
    return organizer.organize_structure()


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print('HP BIOS Recovery USB Organizer')
        print('Usage: python hp_usb_recovery.py <input_directory> [output_directory]')
        print('\nExample:')
        print('  python hp_usb_recovery.py ./out/Winflash.exe_extracted_3rd')
        print('  python hp_usb_recovery.py ./out/Winflash.exe_extracted_3rd ./USB_Recovery')
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else ''
    
    success = organize_hp_usb_recovery(input_path, output_path)
    sys.exit(0 if success else 1)

# Example Workflow: Creating HP BIOS Recovery USB

This example demonstrates the complete workflow from extracting a BIOS file to creating a USB recovery structure.

## Scenario

You have downloaded an HP BIOS update file (e.g., `sp123456.exe` or `Winflash.exe`) and want to create a bootable USB drive for BIOS recovery.

## Steps

### 1. Extract the BIOS Files

First, use BIOSUtilities to extract the BIOS files:

```bash
python main.py /path/to/sp123456.exe -o ./out
```

This will create an output folder like `./out/sp123456.exe_extracted_3rd/` containing:
- BIOS binary files (BIOS_00.bin, BIOS_01.bin, etc.)
- HP utilities folder structure
- Signature files
- Configuration files

### 2. Organize for USB Recovery

Run the HP USB Recovery Organizer:

```bash
python hp_usb_recovery_tool.py ./out/sp123456.exe_extracted_3rd ./USB_Recovery
```

Output:
```
======================================================================
HP BIOS Recovery USB Organizer
Part of BIOSUtilities Project
======================================================================

Organizing HP BIOS recovery USB structure...
Input: ./out/sp123456.exe_extracted_3rd
Output: ./USB_Recovery

[1/4] Organizing BIOS binary files...
  ✓ Copied BIOS_02.bin → HPBIOS.bin (16,777,216 bytes)
  ✓ Backed up BIOS_00.bin (8,388,608 bytes)
  ✓ Backed up BIOS_02.bin (16,777,216 bytes)
  ✓ Backed up BIOS_01.bin (16,777,216 bytes)

[2/4] Organizing HP utilities and EFI files...
  ✓ Copied HP folder structure (32 files)
  ✓ Copied HpBiosMgmt32.efi to EFI_Tools/
  ✓ Copied HpBiosUpdate.efi to EFI_Tools/
  ✓ Copied HpBiosMgmt.efi to EFI_Tools/
  ✓ Copied HpBiosUpdate32.efi to EFI_Tools/

[3/4] Organizing signature files...
  ✓ Copied BIOS_01.sig
  ✓ Copied BIOS_00.sig
  ✓ Copied BIOS_02.sig

[4/4] Creating README with instructions...
  ✓ Created README_BIOS_RECOVERY.txt

HP BIOS recovery USB structure created successfully!
Location: ./USB_Recovery
```

### 3. Create the USB Drive

Now you have a folder `./USB_Recovery/` with this structure:

```
USB_Recovery/
├── HPBIOS.bin                    # Main BIOS recovery file
├── README_BIOS_RECOVERY.txt      # Detailed instructions
├── HP/                           # HP utilities
│   └── HPWINGUI/
├── EFI_Tools/                    # EFI recovery tools
│   ├── HpBiosUpdate.efi
│   ├── HpBiosMgmt.efi
│   └── ...
├── BIOS_Backup/                  # Backup of all BIOS files
│   ├── BIOS_00.bin
│   ├── BIOS_01.bin
│   └── BIOS_02.bin
└── Signatures/                   # Digital signatures
    ├── BIOS_00.sig
    ├── BIOS_01.sig
    └── BIOS_02.sig
```

### 4. Prepare the USB Drive

1. **Format a USB drive** as FAT32:
   - Windows: Right-click USB drive → Format → Select FAT32
   - Linux: `sudo mkfs.vfat -F 32 /dev/sdX` (replace sdX with your USB device)
   - macOS: Disk Utility → Erase → MS-DOS (FAT)

2. **Copy all files** from `./USB_Recovery/` to the USB drive root:
   ```bash
   cp -r ./USB_Recovery/* /media/usb/
   ```
   Or drag and drop all contents in your file manager.

3. **Safely eject** the USB drive

### 5. Perform BIOS Recovery

1. **Turn off** your HP laptop completely
2. **Insert** the prepared USB drive
3. **Press and hold** Win+B (or Fn+B on some models)
4. While holding the keys, **press the Power button**
5. Keep holding Win+B for 10-15 seconds
6. The laptop will detect the USB and start recovery
7. **Wait** for the process to complete (may take 5-15 minutes)
8. The laptop will restart automatically when done

## Troubleshooting

### USB Not Recognized

**Problem**: Laptop doesn't detect the USB drive during recovery

**Solutions**:
- Ensure USB is formatted as FAT32 (not exFAT or NTFS)
- Try a different USB port (prefer USB 2.0 ports)
- Use a smaller USB drive (4-8GB)
- Try a different USB drive brand

### Recovery Doesn't Start

**Problem**: Pressing Win+B doesn't trigger recovery

**Solutions**:
- Try Fn+B instead of Win+B
- Try Fn+Esc, then Fn+B
- Verify your specific HP model's key combination on HP support site
- Ensure the BIOS file matches your exact laptop model

### Recovery Fails Mid-Process

**Problem**: Recovery starts but fails with an error

**Solutions**:
- Ensure laptop is connected to AC power
- Verify BIOS file is correct for your model
- Try re-downloading the BIOS update file
- Check battery is at least 50% charged

## Alternative Methods

Some HP models support different recovery methods:

### Method 1: EFI/HP/BIOS/ Structure

Some newer HP laptops look for BIOS files in a specific EFI folder structure:

```
USB_Drive/
└── EFI/
    └── HP/
        └── BIOS/
            └── New/
                └── HPBIOS.bin
```

### Method 2: Using HP BIOS Update Utility

For Windows-based recovery:
1. Extract BIOS files
2. Run the HP BIOS Update utility from the extracted files
3. Follow on-screen instructions

## Notes

- Always download BIOS updates from official HP support website
- Verify the BIOS version matches your laptop model exactly
- Never interrupt the BIOS recovery process
- Keep AC adapter connected throughout the process

## References

- HP Support: https://support.hp.com
- BIOSUtilities: https://github.com/platomav/BIOSUtilities
- HP BIOS Recovery Guide: See `HP_BIOS_RECOVERY_GUIDE.md`

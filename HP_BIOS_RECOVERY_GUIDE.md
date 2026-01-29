# HP BIOS Recovery USB Guide

Esta guía explica cómo organizar archivos BIOS extraídos para crear un USB de recuperación para laptops HP.
(This guide explains how to organize extracted BIOS files to create a recovery USB for HP laptops.)

## Descripción General / Overview

El script `hp_usb_recovery_tool.py` organiza automáticamente los archivos BIOS extraídos en la estructura correcta para crear un USB de recuperación de BIOS para laptops HP.

The `hp_usb_recovery_tool.py` script automatically organizes extracted BIOS files into the correct structure to create a BIOS recovery USB for HP laptops.

## Requisitos / Requirements

1. Python 3.10 o superior / Python 3.10 or higher
2. Archivos BIOS extraídos usando BIOSUtilities / BIOS files extracted using BIOSUtilities
3. Un USB formateado en FAT32 (8GB o más recomendado) / A USB drive formatted as FAT32 (8GB or larger recommended)

## Uso / Usage

### Paso 1: Extraer archivos BIOS / Step 1: Extract BIOS files

Primero, extrae los archivos BIOS usando el script principal de BIOSUtilities:

First, extract the BIOS files using the main BIOSUtilities script:

```bash
python main.py /ruta/al/archivo/BIOS.exe
```

Esto creará una carpeta con archivos extraídos, por ejemplo: `BIOS.exe_extracted_3rd`

This will create a folder with extracted files, for example: `BIOS.exe_extracted_3rd`

### Paso 2: Organizar para USB de recuperación / Step 2: Organize for recovery USB

Ejecuta el organizador de USB de recuperación HP:

Run the HP recovery USB organizer:

```bash
python hp_usb_recovery_tool.py ./out/BIOS.exe_extracted_3rd
```

O especifica una carpeta de salida personalizada:

Or specify a custom output folder:

```bash
python hp_usb_recovery_tool.py ./out/BIOS.exe_extracted_3rd ./Mi_USB_HP
```

### Paso 3: Copiar al USB / Step 3: Copy to USB

1. **Formatea el USB como FAT32** (importante: no exFAT ni NTFS)
2. **Copia TODO el contenido** de la carpeta `HP_USB_Recovery` a la raíz del USB
3. **Expulsa el USB de forma segura**

1. **Format the USB as FAT32** (important: not exFAT or NTFS)
2. **Copy ALL contents** from the `HP_USB_Recovery` folder to the USB root
3. **Safely eject the USB**

## Estructura de salida / Output Structure

El script crea la siguiente estructura:

The script creates the following structure:

```
HP_USB_Recovery/
├── HPBIOS.bin                    # Archivo principal de BIOS / Main BIOS file
├── README_BIOS_RECOVERY.txt      # Instrucciones detalladas / Detailed instructions
├── HP/                           # Utilidades HP originales / Original HP utilities
│   └── HPWINGUI/
│       └── HPWINGUI_x.xx/
│           └── Package/
├── EFI_Tools/                    # Herramientas EFI para recuperación / EFI recovery tools
│   ├── HpBiosUpdate.efi
│   ├── HpBiosMgmt.efi
│   └── ...
├── BIOS_Backup/                  # Respaldo de todos los archivos BIOS / Backup of all BIOS files
│   ├── BIOS_00.bin
│   ├── BIOS_01.bin
│   └── BIOS_02.bin
└── Signatures/                   # Archivos de firma digital / Digital signature files
    ├── BIOS_00.sig
    ├── BIOS_01.sig
    └── BIOS_02.sig
```

## Procedimiento de recuperación / Recovery Procedure

### Para laptops HP / For HP laptops:

1. **Apaga** la laptop completamente / **Turn off** the laptop completely
2. **Inserta** el USB preparado / **Insert** the prepared USB
3. **Mantén presionado** Win+B (o Fn+B en algunos modelos) / **Press and hold** Win+B (or Fn+B on some models)
4. Mientras mantienes las teclas, **presiona el botón de encendido** / While holding the keys, **press the power button**
5. **Mantén presionado** Win+B por 10-15 segundos / **Keep holding** Win+B for 10-15 seconds
6. La laptop detectará el USB e iniciará la recuperación / The laptop will detect the USB and start recovery
7. **Espera** a que complete (puede tomar varios minutos) / **Wait** for completion (may take several minutes)
8. La laptop se reiniciará automáticamente / The laptop will restart automatically

## Combinaciones de teclas alternativas / Alternative key combinations

Dependiendo del modelo de HP, prueba estas combinaciones:

Depending on the HP model, try these combinations:

- **Win + B** (más común / most common)
- **Fn + B**
- **Fn + Esc**, luego / then **Fn + B**

## Notas importantes / Important Notes

⚠️ **ADVERTENCIAS / WARNINGS**:

- NO interrumpas el proceso de recuperación / DO NOT interrupt the recovery process
- Mantén la laptop conectada a la corriente eléctrica / Keep the laptop connected to AC power
- NO remuevas el USB hasta que complete / DO NOT remove the USB until completion
- La laptop puede reiniciarse varias veces - esto es normal / The laptop may restart multiple times - this is normal

ℹ️ **Compatibilidad / Compatibility**:

- Esta estructura funciona con la mayoría de laptops HP modernas / This structure works with most modern HP laptops
- Algunos modelos HP más antiguos pueden requerir nombres de archivo diferentes / Some older HP models may require different filenames
- Verifica el sitio de soporte de HP para tu modelo específico / Check HP support site for your specific model

## Solución de problemas / Troubleshooting

### La recuperación no inicia / Recovery doesn't start:

- Verifica que el USB esté formateado como FAT32 / Ensure USB is formatted as FAT32
- Intenta diferentes puertos USB (prefiere USB 2.0) / Try different USB ports (prefer USB 2.0)
- Verifica la combinación de teclas para tu modelo / Verify the key combination for your model
- Algunos modelos requieren: Fn+Esc, luego Fn+B / Some models require: Fn+Esc, then Fn+B

### La recuperación falla / Recovery fails:

- Asegúrate que el archivo BIOS corresponde a tu modelo exacto / Ensure BIOS file matches your exact model
- Verifica el sitio de HP para archivos específicos de tu modelo / Check HP site for model-specific files
- La batería debe estar cargada o conectada a AC / Battery should be charged or connected to AC

### El USB no es reconocido / USB not recognized:

- Usa un USB diferente / Use a different USB drive
- Reformatea el USB como FAT32 / Reformat USB as FAT32
- Asegúrate de copiar TODO el contenido / Make sure to copy ALL contents
- Intenta usar un USB más pequeño (4-8GB) / Try using a smaller USB (4-8GB)

## Referencias / References

- **Sitio de soporte HP**: https://support.hp.com
- **BIOSUtilities GitHub**: https://github.com/platomav/BIOSUtilities
- Busca "HP BIOS recovery" + número de modelo de tu laptop para instrucciones específicas

- **HP Support Site**: https://support.hp.com
- **BIOSUtilities GitHub**: https://github.com/platomav/BIOSUtilities
- Search for "HP BIOS recovery" + your laptop model number for specific instructions

## Ejemplos / Examples

### Ejemplo 1: Uso básico / Basic usage

```bash
# Extraer BIOS
python main.py /descargas/sp123456.exe

# Organizar para USB
python hp_usb_recovery_tool.py ./out/sp123456.exe_extracted_3rd

# El resultado estará en: ./HP_USB_Recovery/
```

### Ejemplo 2: Con carpeta de salida personalizada / With custom output folder

```bash
# Extraer BIOS
python main.py /descargas/Winflash.exe

# Organizar para USB con nombre personalizado
python hp_usb_recovery_tool.py ./out/Winflash.exe_extracted_3rd ./USB_HP_EliteBook

# El resultado estará en: ./USB_HP_EliteBook/
```

## Licencia / License

Parte del proyecto BIOSUtilities
Copyright (C) 2018-2025 Plato Mavropoulos

Part of BIOSUtilities project
Copyright (C) 2018-2025 Plato Mavropoulos

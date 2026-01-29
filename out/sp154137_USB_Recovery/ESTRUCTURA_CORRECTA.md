# Estructura USB de Recuperación BIOS HP - sp154137

## ✅ Estructura Correcta Creada

La carpeta `out/sp154137_USB_Recovery/` ahora contiene la estructura **OFICIAL** requerida por HP para la recuperación de BIOS.

## 📁 Estructura de Carpetas

```
sp154137_USB_Recovery/  (95 MB total)
│
├── Hewlett-Packard/                    ⭐ ESTRUCTURA OFICIAL HP
│   └── BIOS/
│       └── Current/
│           ├── BIOS_00.bin (8 MB)
│           ├── BIOS_00.sig (256 bytes)
│           ├── BIOS_01.bin (16 MB)
│           ├── BIOS_01.sig (256 bytes)
│           ├── BIOS_02.bin (16 MB)
│           └── BIOS_02.sig (256 bytes)
│
├── BIOS_Backup/                        (Copia de respaldo)
│   ├── BIOS_00.bin
│   ├── BIOS_01.bin
│   └── BIOS_02.bin
│
├── HP/                                  (Utilidades originales HP)
│   └── HPWINGUI/
│       └── HPWINGUI_3.56/
│           └── Package/
│               ├── HPBU3941/           (HP BIOS Update utilities)
│               ├── DEVFW1100/          (Device Firmware Update)
│               ├── DRIVER40/           (AMI Flash Driver)
│               └── DRIVER56/           (AMI Generic Driver)
│
├── EFI_Tools/                          (Herramientas EFI)
│   ├── HpBiosUpdate.efi
│   ├── HpBiosUpdate32.efi
│   ├── HpBiosMgmt.efi
│   └── HpBiosMgmt32.efi
│
└── README_BIOS_RECOVERY.txt            (Instrucciones completas)
```

## ⚠️ IMPORTANTE: No Modificar la Estructura

La carpeta `Hewlett-Packard/BIOS/Current/` es la ubicación **OFICIAL** donde HP busca los archivos de recuperación BIOS. **NO CAMBIAR** esta estructura.

## 📝 Cómo Usar

### 1. Preparar USB
```bash
# Formatear USB como FAT32 (8GB o mayor)
# En Linux:
sudo mkfs.vfat -F 32 /dev/sdX

# En Windows:
# Click derecho en USB → Formatear → FAT32
```

### 2. Copiar Archivos
```bash
# Copiar TODO el contenido de sp154137_USB_Recovery/ a la raíz del USB
cp -r out/sp154137_USB_Recovery/* /media/usb/

# O arrastrar y soltar en el explorador de archivos
```

### 3. Verificar Estructura en USB
Después de copiar, el USB debe tener:
```
USB:/
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

### 4. Recuperar BIOS

1. **Apagar** la laptop HP completamente
2. **Insertar** el USB
3. **Mantener presionado** Win+B (o Fn+B)
4. Mientras se mantienen las teclas, **presionar el botón de encendido**
5. **Mantener** Win+B por 10-15 segundos
6. La laptop detectará el USB e iniciará la recuperación
7. **Esperar** a que complete (puede tomar 5-15 minutos)
8. La laptop se reiniciará automáticamente cuando termine

## 🔍 Verificación

Para verificar que la estructura es correcta:

```bash
# Ver estructura
tree -L 4 /media/usb/

# Verificar que existe la carpeta correcta
ls -la /media/usb/Hewlett-Packard/BIOS/Current/

# Debe mostrar:
# BIOS_00.bin, BIOS_00.sig
# BIOS_01.bin, BIOS_01.sig  
# BIOS_02.bin, BIOS_02.sig
```

## 📊 Información del Archivo

- **Archivo original**: sp154137.exe
- **Fuente**: https://github.com/extremerom/ExtremeROM/releases/download/V1/sp154137.exe
- **Descripción**: HP Notebook System BIOS Update (AMD Processors)
- **Versión BIOS**: F.73
- **Fabricante**: HP Inc.
- **Tamaño USB necesario**: Mínimo 512 MB (recomendado 8 GB)
- **Formato USB**: FAT32 obligatorio

## ✅ Cambios Implementados

### Versión 1 (Incorrecta - Corregida)
❌ Estructura anterior tenía archivos en la raíz:
```
- HPBIOS.bin (raíz)
- Signatures/ (carpeta separada)
```

### Versión 2 (Correcta - Actual) ✅
✅ Estructura actual usa la ubicación oficial de HP:
```
Hewlett-Packard/BIOS/Current/
├── BIOS_*.bin
└── BIOS_*.sig
```

## 🔗 Referencias

- **Herramienta**: BIOSUtilities HP USB Recovery Organizer
- **Documentación**: [HP_BIOS_RECOVERY_GUIDE.md](../../HP_BIOS_RECOVERY_GUIDE.md)
- **Ejemplo**: [EXAMPLE_HP_USB_RECOVERY.md](../../EXAMPLE_HP_USB_RECOVERY.md)
- **HP Support**: https://support.hp.com
- **Estructura oficial HP**: https://h30434.www3.hp.com/t5/Notebook-Boot-and-Lockup/BIOS-RECOVERY-FOLDER-FILE-STRUCTURE/td-p/9405793

## 📅 Información de Generación

- **Fecha**: 2026-01-29
- **Herramienta**: BIOSUtilities v25.07.01
- **Script**: hp_usb_recovery_tool.py
- **Estructura**: Hewlett-Packard/BIOS/Current/ (Oficial HP)

---

**¡La estructura USB de recuperación está lista para usar!**

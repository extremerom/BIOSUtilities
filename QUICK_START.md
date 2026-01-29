# Quick Start - HP BIOS Recovery USB

## 🚀 Comandos Rápidos (5 minutos)

```bash
# 1. Clonar repo
git clone https://github.com/extremerom/BIOSUtilities.git
cd BIOSUtilities

# 2. Instalar dependencias
python -m pip install -r requirements.txt

# 3. Descargar BIOS
wget -O sp154137.exe https://github.com/extremerom/ExtremeROM/releases/download/V1/sp154137.exe

# 4. Extraer con 7z
7z x sp154137.exe -oout/sp154137_manual

# 5. Procesar con BIOSUtilities
python main.py out/sp154137_manual/Winflash.exe -o out -e

# 6. Crear USB de recuperación
python hp_usb_recovery_tool.py out/Winflash.exe_extracted_3rd out/sp154137_USB_Recovery

# 7. Copiar a USB (formatear como FAT32 primero)
cp -r out/sp154137_USB_Recovery/* /media/usb/
```

## 📁 Resultado

```
USB/
├── Hewlett-Packard/BIOS/Current/  ← BIOS files (Win+B recovery)
├── EFI/BOOT/BOOTx64.efi          ← UEFI boot
└── README_BIOS_RECOVERY.txt       ← Instructions
```

## 💾 Usar USB

1. **Insertar USB** en laptop HP
2. **Apagar** laptop
3. **Win+B** + **Power** (mantener 15 seg)
4. **Esperar** recuperación automática

## 🔗 Documentación Completa

Ver: `COMO_RECREAR_USB.md`

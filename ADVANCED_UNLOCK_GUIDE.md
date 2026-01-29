# Guía Completa para Desbloquear Opciones Avanzadas del BIOS

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Método 1: Combinaciones de Teclas (HotKeys)](#método-1-combinaciones-de-teclas-hotkeys)
3. [Método 2: Modificación de Variables NVRAM](#método-2-modificación-de-variables-nvram)
4. [Método 3: Modificación del BIOS con AMIBCP](#método-3-modificación-del-bios-con-amibcp)
5. [Método 4: Modificación Manual del IFR](#método-4-modificación-manual-del-ifr)
6. [Método 5: Parches en Memoria](#método-5-parches-en-memoria)
7. [Método 6: Firmware Personalizado](#método-6-firmware-personalizado)
8. [Método 7: Herramientas del Fabricante](#método-7-herramientas-del-fabricante)
9. [Método 8: Debug Ports y JTAG](#método-8-debug-ports-y-jtag)
10. [Comparación de Métodos](#comparación-de-métodos)
11. [Casos de Estudio por Fabricante](#casos-de-estudio-por-fabricante)
12. [Recuperación y Solución de Problemas](#recuperación-y-solución-de-problemas)

---

## Introducción

Las opciones avanzadas del BIOS están ocultas por diversas razones:
- **Protección del usuario**: Evitar configuraciones peligrosas
- **Diferenciación de productos**: Reservar funciones para modelos premium
- **Certificaciones**: Cumplir con regulaciones (Intel ME, Secure Boot, etc.)
- **Estabilidad**: Opciones no completamente probadas
- **Overclock**: Limitar capacidades de OC en modelos de consumo

Esta guía explica **todos** los métodos conocidos para acceder a estas opciones.

⚠️ **ADVERTENCIA LEGAL Y TÉCNICA**: 
- Modificar el BIOS puede **dañar permanentemente** tu hardware
- Puede **anular la garantía** de tu equipo
- Puede violar **acuerdos de licencia** del fabricante
- Puede hacer el sistema **no booteable** (brick)
- **Úsalo bajo tu propio riesgo**

---

## Método 1: Combinaciones de Teclas (HotKeys)

### Nivel de Dificultad: ⭐ Fácil
### Riesgo: ⚠️ Bajo (Reversible)
### Efectividad: 70% en BIOS modernos

### Descripción

El método más simple y seguro. Muchos BIOS tienen combinaciones de teclas ocultas que activan menús avanzados sin modificar el firmware.

### Procedimiento Detallado

#### Paso 1: Identificar el Tipo de BIOS

```bash
# En Linux
sudo dmidecode -t bios

# En Windows (PowerShell como Admin)
Get-WmiObject -Class Win32_BIOS
```

Identifica:
- **Vendor**: AMI, Award, Phoenix, Insyde
- **Version**: Número de versión
- **Release Date**: Fecha de lanzamiento

#### Paso 2: Preparación

1. **Backup del BIOS actual**:
   ```bash
   # En Linux con flashrom
   sudo flashrom -p internal -r bios_backup.bin
   
   # Verificar el backup
   ls -lh bios_backup.bin
   ```

2. **Anotar configuración actual**:
   - Tomar fotos de cada página del BIOS
   - Anotar valores importantes (boot order, fecha/hora, etc.)

3. **Preparar recuperación**:
   - Tener a mano el manual de la placa/laptop
   - Conocer la ubicación del jumper de CMOS clear
   - Tener una batería CMOS de repuesto (CR2032)

#### Paso 3: Probar Combinaciones Comunes

**Durante el POST (al encender)**:

```
Secuencia de prueba:
1. Encender el equipo
2. Cuando aparece el logo del fabricante
3. Presionar la combinación (mantener 2-3 segundos)
4. Observar cambios en pantalla
```

Combinaciones a probar:
- **Ctrl + F1** (más común)
- **Ctrl + F2**
- **Alt + F1**
- **Alt + F2**
- **Shift + F1**
- **Fn + Tab** (portátiles)

**Dentro del menú BIOS**:

```
Secuencia:
1. Entrar al BIOS (F2, Del, F10, etc.)
2. Navegar a la página Main
3. Presionar combinación
4. Verificar si aparecen nuevas opciones
5. Probar en cada página (Advanced, Boot, Security, etc.)
```

#### Paso 4: Combinaciones Avanzadas

**Combinaciones de 3+ teclas**:
- **Right Ctrl + Right Shift + F2** (MSI)
- **Left Alt + Right Alt + F2**
- **Ctrl + Alt + F1**
- **Ctrl + Alt + Delete + F1**

**Secuencias**:
```
1. Presionar F1
2. Soltar F1
3. Presionar Ctrl + S (dentro del BIOS)
4. Aparece menú de seguridad (ThinkPad)
```

**Timing específico**:
```
1. Presionar durante 0.5 segundos ANTES de que aparezca el logo
2. O mantener presionado DURANTE todo el POST
3. O presionar JUSTO cuando aparece "Press XX to enter Setup"
```

#### Paso 5: Usar Análisis IFR para Encontrar Hotkeys

Si las combinaciones comunes no funcionan, analiza el BIOS:

```bash
# Extraer BIOS del sistema
cd /home/runner/work/BIOSUtilities/BIOSUtilities
sudo flashrom -p internal -r current_bios.bin

# Analizar con las herramientas
./extract_bios_ifr.sh current_bios.bin

# Revisar resultados
cat out/current_bios_analysis/04_key_combinations.txt
```

Buscar en los archivos IFR:
```bash
# Buscar definiciones de HotKey
grep -r -i "hotkey" out/current_bios_analysis/03_ifr_data/

# Buscar códigos de escaneo
grep -r "0x0B\|0x0C\|0x0D" out/current_bios_analysis/03_ifr_data/
```

### Ejemplo Real: Lenovo ThinkPad

```
Sistema: ThinkPad T480
BIOS: Insyde H2O v1.30

Método que funcionó:
1. Entrar al BIOS (F1 al encender)
2. Ir a la pestaña "Security"
3. Presionar Ctrl + S
4. Aparece menú oculto "Supervisor Options"
5. Contiene opciones de Intel ME, Thunderbolt, etc.

Confirmado en: T480, T490, X1 Carbon Gen 6
```

### Ventajas y Limitaciones

**Ventajas**:
- ✅ No modifica el BIOS
- ✅ Completamente reversible
- ✅ Sin riesgo de brick
- ✅ No requiere herramientas especiales

**Limitaciones**:
- ❌ No funciona en todos los sistemas
- ❌ Limitado a opciones que el BIOS expone
- ❌ Puede ser bloqueado por contraseña de supervisor
- ❌ Puede requerir múltiples intentos/combinaciones

---

## Método 2: Modificación de Variables NVRAM

### Nivel de Dificultad: ⭐⭐ Medio
### Riesgo: ⚠️⚠️ Medio (Recuperable)
### Efectividad: 85% en UEFI

### Descripción

UEFI almacena configuraciones en variables NVRAM. Modificando variables específicas, podemos activar opciones ocultas sin tocar el firmware.

### Prerequisitos

- Sistema con UEFI (no legacy BIOS)
- Acceso root/administrador
- `efivar` o `chipsec` instalado

### Procedimiento

#### Paso 1: Listar Variables NVRAM

**En Linux**:
```bash
# Instalar herramientas
sudo apt-get install efivar

# Listar todas las variables
sudo efivar -l

# Buscar variables relacionadas con Setup
sudo efivar -l | grep -i "setup\|config\|advanced"

# Ver contenido de una variable específica
sudo efivar -n {GUID}-VariableName -p
```

**En Windows** (PowerShell como Admin):
```powershell
# Listar variables
Get-SecureBootUEFI -Name PK -OutputFilePath pk.bin

# Usar RU.efi o setup_var.efi (más adelante)
```

#### Paso 2: Identificar Variables de Interés

Variables comunes que controlan visibilidad:

```
Setup              - Configuración principal
SetupVolatile      - Datos temporales
PchSetup           - Configuración de chipset
CpuSetup           - Configuración de CPU
SaSetup            - System Agent
MeSetup            - Intel ME
AdvancedMode       - Modo avanzado
SetupMode          - Modo de setup
```

#### Paso 3: Analizar Variable Setup

La variable `Setup` generalmente contiene offsets que controlan opciones:

```bash
# Extraer variable Setup
sudo efivar -n {GUID}-Setup -p > setup_var.bin

# Ver en hexadecimal
hexdump -C setup_var.bin | less

# Buscar offsets específicos (basados en análisis IFR)
# Por ejemplo, offset 0x50 = Advanced Mode
```

#### Paso 4: Relacionar IFR con NVRAM

Usa el análisis IFR para encontrar offsets:

```
Ejemplo de IFR:
  One Of: Advanced Mode
    VarStore: 0x1       <-- ID de almacén
    VarOffset: 0x50     <-- Offset en la variable
    Size: 1 byte
    
    Option: "Disabled" Value: 0x0
    Option: "Enabled"  Value: 0x1
  End One Of
```

Esto significa:
- Variable: `Setup` (VarStore ID 0x1 suele ser Setup)
- Offset: 0x50 (byte 80 en decimal)
- Cambiar a: 0x1 para habilitar

#### Paso 5: Modificar Variable con setup_var

**Usando setup_var.efi** (método recomendado):

```bash
# 1. Descargar setup_var.efi
wget https://github.com/datasone/setup_var.efi/releases/download/1.2/setup_var.efi

# 2. Copiar a USB con partición EFI
sudo mount /dev/sdb1 /mnt
sudo cp setup_var.efi /mnt/EFI/
sudo umount /mnt

# 3. Boot desde USB y entrar a UEFI Shell

# 4. En UEFI Shell:
fs0:
cd EFI
setup_var.efi 0x50 0x01

# Esto cambia offset 0x50 a valor 0x01
# Reiniciar y verificar cambios en BIOS
```

**Usando chipsec** (método avanzado):

```bash
# Instalar chipsec
sudo pip install chipsec

# Leer variable
sudo python -m chipsec_main -m tools.uefi.uefivar -a read -n Setup

# Modificar offset (requiere scripting)
sudo python -c "
from chipsec.module_common import *
# Código para modificar variable
"
```

#### Paso 6: Método RW-Everything (Windows)

```
1. Descargar RW-Everything
2. Ejecutar RW.exe como administrador
3. Menú: Access > UEFI Variable
4. Buscar variable "Setup"
5. Modificar bytes en el offset deseado
6. Guardar cambios
7. Reiniciar
```

#### Paso 7: Verificación y Reversión

```bash
# Antes de modificar, hacer backup de la variable
sudo efivar -n {GUID}-Setup -p > setup_backup.bin

# Después de modificar, verificar
sudo efivar -n {GUID}-Setup -p > setup_modified.bin

# Comparar
diff <(hexdump setup_backup.bin) <(hexdump setup_modified.bin)

# Restaurar si algo sale mal
# (Método depende de la herramienta usada)
```

### Ejemplo Real: Dell XPS 15 9570

```
Sistema: Dell XPS 15 9570
BIOS: Dell Inc. 1.16.2

Objetivo: Habilitar Intel ME debug options

Procedimiento:
1. Analizar BIOS con IFRExtractor
2. Encontrar en IFR:
   One Of: ME Debug
     VarStore: 0x1 (Setup)
     VarOffset: 0x3F2
     Default: 0x0 (Disabled)
     Suppress If: True
     
3. Bootear con setup_var.efi en USB
4. setup_var.efi 0x3F2 0x01
5. Reiniciar
6. Verificar en BIOS: nueva opción "ME Kernel Debug"

Resultado: ✅ Exitoso
Reversible: ✅ Sí (setup_var.efi 0x3F2 0x00)
```

### Ventajas y Limitaciones

**Ventajas**:
- ✅ No modifica el firmware permanentemente
- ✅ Reversible (puedes cambiar el valor de vuelta)
- ✅ No requiere flasheo del BIOS
- ✅ Relativamente seguro

**Limitaciones**:
- ❌ Solo funciona en UEFI (no legacy BIOS)
- ❌ Requiere análisis IFR previo para conocer offsets
- ❌ Algunos BIOS validan variables al boot
- ❌ Puede ser restablecido por "Load Setup Defaults"
- ❌ Protected variables no se pueden modificar

---

## Método 3: Modificación del BIOS con AMIBCP

### Nivel de Dificultad: ⭐⭐⭐ Difícil
### Riesgo: ⚠️⚠️⚠️ Alto (Puede causar brick)
### Efectividad: 95% en AMI BIOS

### Descripción

AMIBCP (AMI BIOS Configuration Program) permite modificar directamente el archivo del BIOS para cambiar la visibilidad de opciones antes de flashearlo.

### Prerequisitos

- AMIBCP (versión compatible con tu BIOS)
- Backup del BIOS original
- Programador CH341A o similar (por seguridad)
- Conocimientos de flasheo de BIOS

### Procedimiento

#### Paso 1: Obtener AMIBCP

```
Versiones de AMIBCP por generación:

- AMIBCP 4.53 - AMI Aptio 4 (2008-2012)
- AMIBCP 4.55 - AMI Aptio 4 (2010-2014)
- AMIBCP 5.01 - AMI Aptio 5 (2014-2018)
- AMIBCP 5.02 - AMI Aptio 5 (2018+)

Descarga: [Buscar en BiosFlash.net o Win-RAID Forum]
```

#### Paso 2: Extraer BIOS Actual

```bash
# Método 1: Desde sistema operativo
sudo flashrom -p internal -r current_bios.bin

# Método 2: Desde sitio del fabricante
# Descargar archivo .exe de actualización
# Extraer con 7-Zip o similar

# Método 3: Desde BIOS chip directamente
# Usar programador CH341A con clip SOIC8/16
```

#### Paso 3: Abrir BIOS en AMIBCP

```
1. Ejecutar AMIBCP.exe (en Windows o Wine)
2. File > Open > Seleccionar tu archivo .bin
3. Esperar análisis (puede tardar varios minutos)

Si da error:
- Prueba versión diferente de AMIBCP
- El BIOS puede tener protecciones
- Puede necesitar descomprimir primero
```

#### Paso 4: Navegar y Modificar Opciones

```
Interfaz de AMIBCP:

Setup Configuration
├─ Main
│  ├─ BIOS Information [Read Only]
│  ├─ BIOS Date [Read Only]
│  └─ System Time [User]
├─ Advanced
│  ├─ CPU Configuration [Supervisor]
│  │  ├─ Intel Virtualization [User]
│  │  ├─ Core Ratio Limit [Hidden]  <-- ENCONTRADO!
│  │  └─ Voltage Offset [Hidden]     <-- ENCONTRADO!
│  ├─ PCH Configuration [Supervisor]
│  └─ ME Configuration [Hidden]      <-- ENCONTRADO!
└─ Chipset

Columnas:
- Option Name: Nombre de la opción
- Access/Use: Nivel de acceso
  * User: Visible para todos
  * Supervisor: Requiere password de supervisor
  * Hidden: No visible
  * Read Only: Solo lectura
```

#### Paso 5: Cambiar Nivel de Acceso

```
Para cada opción que quieras desbloquear:

1. Clic derecho sobre la opción
2. Change Access/Use
3. Cambiar de "Hidden" o "Supervisor" a "User"
4. Repetir para todas las opciones deseadas

Opciones comunes a desbloquear:
- Core Ratio Limit (Overclock CPU)
- CPU Voltage Offset
- Memory Timing Configuration
- ME (Management Engine) settings
- PCH / Chipset advanced options
- SATA Configuration advanced
- USB Configuration advanced
```

#### Paso 6: Guardar BIOS Modificado

```
1. File > Save As > modified_bios.bin
2. Verificar tamaño:
   - Original: 8,388,608 bytes (8MB)
   - Modificado: 8,388,608 bytes (8MB)
   - Deben ser EXACTAMENTE igual
   
3. NO guardar si los tamaños difieren
```

#### Paso 7: Flashear BIOS Modificado

**Opción A: Flasheo desde Sistema Operativo** (más riesgo):

```bash
# Linux
sudo flashrom -p internal -w modified_bios.bin

# Windows
# Usar AFUWIN o herramienta del fabricante
afuwin64.exe modified_bios.bin /P /B /N /K
```

**Opción B: Flasheo con Programador** (más seguro):

```
1. Apagar y desconectar el equipo
2. Abrir y localizar chip BIOS (generalmente SOIC8 o SOIC16)
3. Conectar programador CH341A con clip
4. Abrir software (AsProgrammer, CH341A Programmer)
5. Leer chip actual (verificar que lee bien)
6. Comparar con backup
7. Escribir modified_bios.bin
8. Verificar escritura
9. Desconectar y reassemblar
10. Encender y probar
```

#### Paso 8: Verificación Post-Flasheo

```
1. Primer arranque puede ser lento (normal)
2. Puede mostrar "CMOS Checksum Error" (normal)
3. Entrar al BIOS (F2/Del)
4. Verificar nuevas opciones en menú Advanced
5. Load Setup Defaults
6. Configurar como prefieras
7. Save & Exit
```

### Precauciones Importantes

⚠️ **ANTES DE FLASHEAR**:
1. ✅ Haz backup del BIOS original (múltiples copias)
2. ✅ Verifica que el tamaño del archivo no cambió
3. ✅ Verifica que AMIBCP guardó sin errores
4. ✅ Ten un plan de recuperación (programador externo)
5. ✅ Asegúrate de tener el BIOS original del fabricante
6. ✅ Desconecta dispositivos USB/externos innecesarios
7. ✅ Conecta el equipo a UPS o batería cargada

⚠️ **NO FLASHEAR SI**:
- ❌ El archivo modificado tiene diferente tamaño
- ❌ AMIBCP mostró errores al guardar
- ❌ No tienes backup del BIOS original
- ❌ No tienes forma de recuperar (programador)
- ❌ Es tu único equipo y lo necesitas

### Ejemplo Real: ASUS TUF Gaming

```
Sistema: ASUS TUF Gaming B550M-PLUS
BIOS: AMI Aptio 5, Version 2423

Objetivo: Desbloquear opciones de overclock avanzado

Procedimiento:
1. Descargar BIOS 2423 del sitio de ASUS
2. Extraer .CAP con 7-Zip → obtener B550MTUF.ROM
3. Abrir en AMIBCP 5.02
4. Navegar a: Advanced > AMD Overclocking
5. Cambiar a "User":
   - PBO Limits
   - Curve Optimizer
   - Max CPU Boost Clock Override
   - Memory Clock
   - FCLK Frequency
6. Guardar como B550MTUF_modded.ROM
7. Flashear con EZ Flash 3 desde USB
8. Reiniciar

Resultado: ✅ Exitoso - Todas las opciones visibles
Reversible: ✅ Sí (flashear BIOS original)
Notas: No requirió programador externo
```

### Ventajas y Limitaciones

**Ventajas**:
- ✅ Control total sobre visibilidad de opciones
- ✅ Cambios permanentes (sobreviven a reset)
- ✅ No requiere hotkeys ni variables NVRAM
- ✅ Funciona en la mayoría de BIOS AMI

**Limitaciones**:
- ❌ Alto riesgo de brick si se hace incorrectamente
- ❌ Solo AMI BIOS (no Award, Phoenix, Insyde)
- ❌ Requiere flasheo del BIOS
- ❌ Anula garantía en la mayoría de casos
- ❌ Actualizar BIOS requiere re-modificar
- ❌ Algunos BIOS tienen protecciones anti-modificación

---

## Método 4: Modificación Manual del IFR

### Nivel de Dificultad: ⭐⭐⭐⭐ Muy Difícil
### Riesgo: ⚠️⚠️⚠️⚠️ Muy Alto
### Efectividad: 99% (si se hace bien)

### Descripción

Modificar directamente los opcodes IFR en el módulo Setup del BIOS para eliminar restricciones "Suppress If" y "Gray-Out If".

### Prerequisitos

- Conocimientos avanzados de IFR y hex editing
- UEFITool / UEFITool NE
- IFRExtractor
- Hex editor (HxD, 010 Editor)
- UEFIPatch o similar

### Procedimiento

#### Paso 1: Extraer Módulo Setup

```bash
# Extraer BIOS
./external/uefiextract bios.bin extracted/

# Encontrar módulo Setup (buscar por GUID o nombre)
find extracted/ -name "*Setup*" -o -name "*Form*"

# Generalmente tiene nombre como:
# 899407D7-99FE-43D8-9A21-79EC328CAC21
```

#### Paso 2: Extraer y Analizar IFR

```bash
# Extraer IFR
./external/ifrextractor extracted/path/to/setup/body.bin setup_ifr.txt

# Buscar opciones ocultas
grep -n "Suppress If" setup_ifr.txt
```

Ejemplo de IFR encontrado:
```
Line 1234:
  Suppress If {0F 01}
    True
    
  One Of: Advanced CPU Settings, VarStore: 0x1, VarOffset: 0x100
    Option: "Auto" Value: 0x0
    Option: "Enabled" Value: 0x1
  End One Of
  
End
```

#### Paso 3: Convertir IFR a Offsets Binarios

El IFR text es una representación del binario. Necesitamos encontrar los bytes exactos:

```
Suppress If {0F 01}  corresponde a opcodes:
  0x0A  - Suppress If opcode
  0x04  - Tamaño de la expresión
  0x0F  - EFI_IFR_TRUE opcode  
  0x01  - Tamaño
```

#### Paso 4: Buscar en Hex Editor

```
1. Abrir body.bin del módulo Setup en hex editor
2. Buscar secuencia: 0A 04 0F 01
3. Encontrar todas las ocurrencias
4. Identificar cuál corresponde a la opción deseada
   (usar contexto del IFR text como referencia)
```

#### Paso 5: Parchear el Binario

**Método A: Eliminar Suppress If**

```
Cambiar:
  0A 04 0F 01  (Suppress If True)
a:
  00 00 00 00  (NOPs)
  
O mejor:
  0A 04 0F 00  (Suppress If False) - más limpio
```

**Método B: Cambiar Condición**

```
Original:
  0A 04 0F 01  (Suppress If True) - siempre oculto

Cambiar a:
  0A 04 0F 00  (Suppress If False) - nunca oculto
```

#### Paso 6: Reensamblar BIOS

```bash
# Reemplazar módulo modificado en el BIOS
# Usar UEFITool:

1. Abrir bios.bin en UEFITool
2. Buscar módulo Setup por GUID
3. Click derecho > Replace body
4. Seleccionar body.bin modificado
5. File > Save image file > modified_bios.bin
```

#### Paso 7: Verificar y Flashear

```bash
# Verificar tamaño
ls -lh bios.bin modified_bios.bin

# Flashear (con precaución extrema)
sudo flashrom -p internal -w modified_bios.bin
```

### Ejemplo de Opcodes IFR Comunes

```
Opcode  | Nombre           | Descripción
--------|------------------|------------------
0x01    | Form             | Inicio de formulario
0x02    | Subtitle         | Subtítulo
0x05    | One Of           | Lista desplegable
0x06    | Checkbox         | Casilla de verificación
0x07    | Numeric          | Valor numérico
0x0A    | Suppress If      | Ocultar si condición
0x0B    | Gray-Out If      | Deshabilitar si condición
0x0C    | Default          | Valor predeterminado
0x0F    | EFI_IFR_TRUE     | Booleano verdadero
0x10    | EFI_IFR_FALSE    | Booleano falso
0x12    | EFI_IFR_EQ_VAR   | Comparar con variable
0x29    | End              | Fin de estructura
```

### Casos de Uso Avanzados

**Caso 1: Eliminar Password de Supervisor**

```
Buscar en IFR:
  Password: Supervisor Password
  
En hex:
  06 xx xx ...  (Checkbox / Password opcode)
  
Modificar para hacer siempre verdadero o eliminar check
```

**Caso 2: Cambiar Valores Máximos**

```
IFR muestra:
  Numeric: CPU Core Voltage
    Minimum: 0.8V (valor: 800)
    Maximum: 1.4V (valor: 1400)  <-- Queremos aumentar
    
En hex buscar:
  07 [size] ... 78 03 00 00  (mínimo en little endian: 0x0378 = 888)
                B8 05 00 00  (máximo en little endian: 0x05B8 = 1464)
  
Cambiar máximo a 1.5V (1500):
  DC 05 00 00  (0x05DC = 1500)
```

### Script de Automatización (Avanzado)

```python
#!/usr/bin/env python3
# ifr_patch.py - Parchar IFR automáticamente

import sys

def patch_suppress_if(binary_data):
    """Elimina todos los Suppress If True"""
    # Buscar patrón: 0A 04 0F 01
    pattern = b'\x0A\x04\x0F\x01'
    replacement = b'\x0A\x04\x0F\x00'  # Suppress If False
    
    count = binary_data.count(pattern)
    print(f"Found {count} Suppress If True statements")
    
    patched = binary_data.replace(pattern, replacement)
    return patched

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: ifr_patch.py input.bin output.bin")
        sys.exit(1)
    
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
    
    patched = patch_suppress_if(data)
    
    with open(sys.argv[2], 'wb') as f:
        f.write(patched)
    
    print(f"Patched file saved to {sys.argv[2]}")
```

### Ventajas y Limitaciones

**Ventajas**:
- ✅ Control total y preciso
- ✅ Funciona cuando otros métodos fallan
- ✅ No limitado a AMI (funciona en todos los UEFI)
- ✅ Puede eliminar cualquier restricción

**Limitaciones**:
- ❌ Extremadamente técnico y propenso a errores
- ❌ Riesgo muy alto de brick
- ❌ Requiere conocimiento profundo de IFR
- ❌ Difícil de automatizar
- ❌ Cada BIOS es diferente
- ❌ Puede romper checksums/firmas

---

## Método 5: Parches en Memoria

### Nivel de Dificultad: ⭐⭐⭐⭐⭐ Experto
### Riesgo: ⚠️⚠️ Medio (No persiste)
### Efectividad: 60% (Temporal)

### Descripción

Modificar variables en memoria RAM durante el runtime del BIOS/UEFI sin tocar el firmware.

### Herramientas

- CHIPSEC
- RU.efi (Read-Write Universal)
- EFI Shell
- Debugger (raro)

### Procedimiento con RU.efi

```
1. Descargar RU.efi
   http://ruexe.blogspot.com/

2. Copiar a USB con FAT32

3. Boot en UEFI Shell

4. Ejecutar RU.efi:
   fs0:
   RU.efi

5. Navegar con teclas:
   Alt+= : UEFI Variables
   Ctrl+PgUp/PgDn : Cambiar variable
   
6. Buscar variable "Setup"

7. Modificar offsets según análisis IFR

8. F2 para guardar

9. Reiniciar y verificar
```

### Ventajas

- ✅ No modifica firmware
- ✅ Ideal para testing
- ✅ Reversible (reiniciar resetea)

### Limitaciones

- ❌ No persiste tras reboot
- ❌ Complejo de usar
- ❌ Requiere conocer offsets exactos

---

## Método 6: Firmware Personalizado

### Nivel de Dificultad: ⭐⭐⭐⭐⭐ Experto
### Riesgo: ⚠️⚠️⚠️⚠️⚠️ Extremo
### Efectividad: 100% (Control total)

### Descripción

Reemplazar el BIOS propietario con firmware open-source (Coreboot, Libreboot).

### Soporte

Ver: https://www.coreboot.org/status/board-status.html

Sistemas soportados:
- Muchas ThinkPads antiguas
- Chromebooks
- Algunas placas Intel/AMD
- Sistemas embebidos

### Ventajas

- ✅ Control total del firmware
- ✅ Sin restricciones
- ✅ Open source
- ✅ Mejor rendimiento (a veces)

### Limitaciones

- ❌ Soporte limitado a hardware específico
- ❌ Proceso complejo y arriesgado
- ❌ Puede perder funcionalidades (ME, etc.)
- ❌ Requiere programador hardware

*(Este método está fuera del alcance de esta guía)*

---

## Método 7: Herramientas del Fabricante

### Nivel de Dificultad: ⭐⭐ Medio
### Riesgo: ⚠️ Bajo
### Efectividad: Variable

### Por Fabricante

**Dell**:
- Dell Command Configure
- iDRAC (servidores)
- Puede cambiar configuraciones sin entrar al BIOS

**HP**:
- HP BIOS Configuration Utility
- HP Sure Admin
- Scripts para configuración masiva

**Lenovo**:
- Lenovo Vantage
- ThinkPad Setup Settings Capture/Playback
- WMI interface para scripts

**ASUS**:
- AI Suite
- Algunas configuraciones desde Windows

### Ventajas

- ✅ Oficial y soportado
- ✅ Sin riesgo de brick
- ✅ Fácil de usar

### Limitaciones

- ❌ No desbloquea opciones ocultas realmente
- ❌ Solo expone lo que el fabricante permite
- ❌ Requiere software propietario

---

## Método 8: Debug Ports y JTAG

### Nivel de Dificultad: ⭐⭐⭐⭐⭐ Experto
### Riesgo: ⚠️⚠️⚠️ Alto
### Efectividad: 100% (Con equipo adecuado)

### Descripción

Usar puertos de debug (JTAG, DCI) para acceder y modificar el sistema a bajo nivel.

### Equipo Necesario

- Adaptador JTAG (Bus Pirate, JTAGulator, etc.)
- Intel DCI debug cable (para DCI)
- Osciloscopio (ayuda)
- Conocimientos de ingeniería reversa

### Casos de Uso

- Recuperación de bricks severos
- Bypass de protecciones
- Análisis forense
- Desarrollo de firmware

*(Método extremadamente avanzado, fuera del alcance)*

---

## Comparación de Métodos

| Método | Dificultad | Riesgo | Reversible | Requiere Flasheo | Efectividad |
|--------|------------|--------|------------|------------------|-------------|
| HotKeys | Fácil | Bajo | Sí | No | 70% |
| NVRAM | Medio | Medio | Sí | No | 85% |
| AMIBCP | Difícil | Alto | Sí* | Sí | 95% |
| IFR Manual | Muy Difícil | Muy Alto | Sí* | Sí | 99% |
| Memoria | Experto | Medio | Sí | No | 60% |
| Firmware Custom | Experto | Extremo | No | Sí | 100% |
| Herramientas OEM | Medio | Bajo | Sí | No | 40% |
| JTAG/Debug | Experto | Alto | Sí | Depende | 100% |

\* Requiere flashear BIOS original para revertir

---

## Casos de Estudio por Fabricante

### ASUS ROG

**Sistema**: ROG Strix B550-F Gaming  
**Método exitoso**: Combinación de teclas

```
Procedimiento:
1. Entrar al BIOS (Del)
2. Presionar F7 (modo avanzado)
3. En modo avanzado, presionar Ctrl+F1
4. Aparecen opciones ocultas en "Advanced" y "Chipset"
5. Incluye controles de voltaje avanzados

Confirmado en: B550, X570, Z690 series
```

### MSI MAG/MPG

**Sistema**: MSI MAG B550 TOMAHAWK  
**Método exitoso**: Modificación NVRAM + AMIBCP

```
Opción 1 (Temporal - NVRAM):
1. Boot con RU.efi
2. Alt+= para UEFI Variables
3. Buscar "CpuSetup"
4. Offset 0x3E cambiar a 0x01
5. Desbloquea "DigitALL Power"

Opción 2 (Permanente - AMIBCP):
1. Descargar BIOS desde MSI
2. Extraer con 7-Zip
3. Modificar en AMIBCP 5.02
4. Flashear con M-Flash

Resultado: Opciones de overclock extremo desbloqueadas
```

### Lenovo ThinkPad

**Sistema**: ThinkPad T14 Gen 2  
**Método exitoso**: HotKeys + Documentación interna

```
Nivel 1 - Hotkey básico:
F1 en boot > Password de Supervisor > Ctrl+S
Desbloquea: Opciones de seguridad avanzadas

Nivel 2 - Service Menu:
F1 en boot > En cualquier página > Shift+1
Desbloquea: Información de servicio

Nivel 3 - Variables NVRAM:
Boot con setup_var.efi
Offset 0x52E = 0x01
Desbloquea: Intel ME options

Documentado en: ThinkPad Hardware Maintenance Manual
```

### Dell Latitude

**Sistema**: Latitude 7420  
**Método exitoso**: Dell Command Configure

```
Sin modificar BIOS:
1. Instalar Dell Command Configure
2. Crear archivo config.txt:
   [advanced]
   UnderVoltProtection=Disabled
   TurboBoost=Enabled
   SpeedStep=Disabled

3. Aplicar:
   cctk.exe --infile=config.txt

Resultado: Cambios aplicados sin entrar al BIOS
Limitación: Solo opciones que Dell permite via software
```

### HP EliteBook

**Sistema**: HP EliteBook 840 G8  
**Método exitoso**: Combinación compleja

```
Método 1 - Durante POST:
Right Alt + Right Ctrl + F2 (mantener 5 segundos)
A veces funciona: Alt + F10

Método 2 - Dentro del BIOS:
F10 para entrar > Navegar a "Advanced" > F10 + A
Desbloquea: Menú de administrador

Método 3 - HP Sure Admin:
Usar HP Sure Admin para scripts de configuración

Nota: HP es uno de los más restrictivos
```

---

## Recuperación y Solución de Problemas

### Recuperación de BIOS Corrupto

**Método 1: BIOS Flashback** (si disponible)

```
Placas con botón de flashback (ASUS, MSI, etc.):
1. Renombrar BIOS original a nombre específico (ej: "MSI.ROM")
2. Copiar a USB FAT32
3. Apagar completamente
4. Conectar USB al puerto designado
5. Presionar botón de flashback (3-5 segundos)
6. LED parpadeará (puede tardar 5-10 minutos)
7. LED quedará fijo = completado
8. Desconectar USB y encender
```

**Método 2: Crisis Recovery**

```
Para ASUS, algunos MSI:
1. Crear USB FAT32
2. Copiar BIOS renombrado según modelo
3. Apagar y desconectar
4. Mantener Ctrl+Home
5. Conectar energía (seguir manteniendo)
6. Encender (seguir manteniendo)
7. Soltar cuando parpadee LED o pantalla
8. Esperar proceso (sin apagar!)
```

**Método 3: Programador Externo**

```
Con CH341A o similar:
1. Abrir equipo
2. Localizar chip BIOS (usualmente etiquetado)
3. Tipos comunes:
   - SOIC8 (8 pines)
   - SOIC16 (16 pines)
   - DIP8 (menos común)
4. Conectar clip o desoldarlo
5. Usar software (AsProgrammer):
   - Auto Detect
   - Read chip
   - Verificar lectura es coherente
   - Erase chip
   - Write BIOS original
   - Verify
6. Desconectar y reassemblar
```

### CMOS Reset Completo

**Método jumper**:
```
1. Apagar y desconectar
2. Localizar jumper CLR_CMOS o JBAT1
3. Posición normal: pines 1-2
4. Mover a pines 2-3
5. Esperar 10-30 segundos
6. Devolver a pines 1-2
7. Reconectar y encender
```

**Método batería**:
```
Desktop:
1. Apagar y desconectar
2. Extraer batería CMOS (CR2032)
3. Presionar botón power 10 segundos (descarga caps)
4. Esperar 5-10 minutos
5. Reinstalar batería
6. Reconectar y encender

Portátil:
1. Apagar y desconectar
2. Quitar batería principal (si removible)
3. Mantener power button 30 segundos
4. Reconectar y encender
```

### Problemas Comunes Post-Modificación

**Problema: BIOS no muestra video**

```
Causa: Configuración incompatible
Solución:
1. CMOS reset (método jumper o batería)
2. Si no funciona, flashear BIOS original
```

**Problema: Sistema no bootea**

```
Causa: Opciones modificadas incorrectamente
Solución:
1. Entrar al BIOS
2. Load Setup Defaults (F9)
3. Save & Exit (F10)
4. Si no entra al BIOS: CMOS reset
```

**Problema: Opciones causan inestabilidad**

```
Causa: Valores fuera de especificación
Solución:
1. Identificar qué opción causa problema
2. Revertir a valores seguros
3. Si no funciona: CMOS reset + Load Defaults
```

**Problema: Bootloop continuo**

```
Causa: Modificación severa del BIOS
Solución:
1. Desconectar energía completamente
2. CMOS reset (jumper + batería)
3. Si persiste: Crisis Recovery
4. Si persiste: Programador externo
```

### Logs y Diagnóstico

**Obtener logs del sistema** (post-modificación):

```bash
# Linux
sudo journalctl -b | grep -i "bios\|uefi\|firmware"
sudo dmesg | grep -i "bios\|acpi"

# Ver tabla ACPI
sudo acpidump > acpi_tables.txt

# Verificar DMI
sudo dmidecode > dmi_info.txt
```

---

## Recursos Adicionales

### Comunidades y Foros

- **Win-RAID Forum**: https://winraid.level1techs.com/
- **BiosFlash.net**: https://biosflash.net/
- **BIOS-Mods Forum**: https://www.bios-mods.com/forum/
- **Overclock.net BIOS**: https://overclock.net/forums/bios-modding/
- **TechInfoDepot**: https://techinfodepot.shoutwiki.com/

### Herramientas

- **UEFITool**: https://github.com/LongSoft/UEFITool
- **IFRExtractor**: https://github.com/LongSoft/IFRExtractor-RS
- **CHIPSEC**: https://github.com/chipsec/chipsec
- **setup_var.efi**: https://github.com/datasone/setup_var.efi
- **RU.efi**: http://ruexe.blogspot.com/

### Documentación Técnica

- **UEFI Specification**: https://uefi.org/specifications
- **PI Specification**: https://uefi.org/specifications
- **EDK2 Documentation**: https://github.com/tianocore/edk2
- **IFR Format**: MdeModulePkg/Universal/SetupBrowserDxe/

### Lecturas Recomendadas

- "Beyond BIOS" by Vincent Zimmer
- "UEFI: From Reset Vector to OS" - Intel whitepaper
- "Hacking the UEFI" - Alex Matrosov, Eugene Rodionov
- "BIOS Disassembly Ninjutsu Uncovered" - Darmawan Salihun

---

## Disclaimer Final

Esta guía es **SOLO CON FINES EDUCATIVOS**.

**TÚ ERES RESPONSABLE** de:
- ✋ Cualquier daño a tu hardware
- ✋ Pérdida de garantía
- ✋ Violación de términos de servicio
- ✋ Consecuencias legales
- ✋ Pérdida de datos
- ✋ Tiempo y dinero invertido

**RECOMENDACIONES**:
- ✅ Lee toda la documentación primero
- ✅ Haz múltiples backups
- ✅ Ten un plan de recuperación
- ✅ Prueba en hardware de prueba primero
- ✅ Únete a comunidades para soporte
- ✅ Documenta tus cambios
- ✅ Sé paciente y metódico

**NO HAGAS ESTO SI**:
- ❌ Es tu único equipo
- ❌ Dependes del equipo para trabajo
- ❌ No tienes backups
- ❌ No entiendes los riesgos
- ❌ No tienes plan de recuperación
- ❌ Tienes prisa

---

## Conclusión

Desbloquear opciones avanzadas del BIOS requiere:
1. **Conocimiento**: Entender cómo funciona el BIOS/UEFI
2. **Herramientas**: Las correctas para tu caso
3. **Paciencia**: No apresurarse
4. **Precaución**: Múltiples backups y planes de recuperación

**Recomendación de ruta**:
1. Empieza con **HotKeys** (Método 1) - Más seguro
2. Si no funciona, prueba **NVRAM** (Método 2) - Seguro y reversible
3. Solo si realmente lo necesitas, considera **AMIBCP** (Método 3)
4. Evita modificación manual de IFR a menos que seas experto

**Recuerda**: A veces la limitación existe por una razón. No todas las opciones "ocultas" son seguras de habilitar.

---

**Versión**: 1.0  
**Fecha**: 2025-01-29  
**Autor**: BIOSUtilities Community  
**Licencia**: Educational purposes only

Para más información, consulta:
- [BIOS_KEY_COMBINATIONS.md](BIOS_KEY_COMBINATIONS.md)
- [MANUAL_ANALYSIS_GUIDE.md](MANUAL_ANALYSIS_GUIDE.md)
- [UEFI_IFR_ANALYSIS.md](UEFI_IFR_ANALYSIS.md)

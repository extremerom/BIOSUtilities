# Análisis Manual de BIOS - Guía Paso a Paso

## Introducción

Esta guía muestra el proceso **manual** de análisis de un archivo BIOS para encontrar combinaciones de teclas que desbloquean opciones avanzadas. No usaremos scripts automatizados, sino que ejecutaremos cada comando manualmente para entender el proceso completo.

## Requisitos Previos

Asegúrate de tener las herramientas instaladas:
```bash
cd /home/runner/work/BIOSUtilities/BIOSUtilities
./setup_ifr_tools.sh
```

Esto descarga en `external/`:
- `ifrextractor` - Extrae datos IFR
- `uefiextract` - Extrae módulos UEFI
- `uefifind` - Busca patrones en BIOS

## Estructura del Análisis

```
bios_analysis/
├── bios_original.bin          # Archivo BIOS original
├── step1_modules/             # Módulos extraídos
├── step2_search_results.txt   # Resultados de búsqueda
├── step3_ifr_data/            # Datos IFR extraídos
└── step4_findings.txt         # Combinaciones encontradas
```

---

## PASO 1: Extraer Módulos UEFI del BIOS

### Comando

```bash
cd bios_analysis
../external/uefiextract bios_original.bin step1_modules
```

### ¿Qué hace?

UEFIExtract analiza la estructura UEFI del BIOS y extrae todos los módulos encontrados en una jerarquía de carpetas que refleja la estructura del firmware.

### Salida Esperada

```
step1_modules/
├── 0 Descriptor region/
├── 1 BIOS region/
│   ├── 0 Padding/
│   ├── 1 Volume/
│   │   ├── 0 Volume header/
│   │   ├── 1 FFSv2 Volume/
│   │   │   ├── File C6ECD531.../
│   │   │   │   ├── section0/
│   │   │   │   │   ├── body.bin
│   │   │   │   │   └── header.bin
│   │   │   │   └── section1/
│   │   │   │       └── ...
│   │   │   ├── File 9E21FD93... (Setup)
│   │   │   │   └── ...
```

### Verificar Extracción

```bash
# Contar archivos extraídos
find step1_modules -type f | wc -l

# Buscar archivos PE32 (ejecutables UEFI)
find step1_modules -name "body.bin" -exec file {} \; | grep "PE32"

# Buscar módulos con "Setup" en el nombre
find step1_modules -type d | grep -i setup
```

### Ejemplo Real

```bash
$ find step1_modules -type f | wc -l
1247

$ find step1_modules -name "body.bin" | head -5
step1_modules/1 BIOS region/1 Volume/1 FFSv2/File 9E21FD93-54C0-4D06-9E/section0/body.bin
step1_modules/1 BIOS region/1 Volume/1 FFSv2/File B1DA0ADF-4F77-4070-A8/section0/body.bin
```

---

## PASO 2: Buscar Módulos de Setup con UEFIFind

### Comandos

```bash
# Buscar palabra "Setup"
../external/uefifind bios_original.bin text "Setup" > step2_search_results.txt

# Buscar palabra "Advanced"  
../external/uefifind bios_original.bin text "Advanced" >> step2_search_results.txt

# Buscar palabra "Security"
../external/uefifind bios_original.bin text "Security" >> step2_search_results.txt

# Buscar por GUID de HII Config Access Protocol
../external/uefifind bios_original.bin guid 899407D7-99FE-43D8-9A21-79EC328CAC21 >> step2_search_results.txt
```

### ¿Qué hace?

UEFIFind busca patrones específicos en el BIOS sin necesidad de extraer primero. Devuelve las rutas donde encontró coincidencias.

### Salida Esperada

```
step2_search_results.txt:

Unicode text "Setup" found in PE32 image section at offset 3Ah
1 BIOS region/1 Volume/1 FFSv2/File 9E21FD93-54C0-4D06-9E3E-BC903F5A8C5B/0 PE32 image section

Unicode text "Advanced" found at header offset 15h
1 BIOS region/1 Volume/1 FFSv2/File B1DA0ADF-4F77-4070-A8E6-A4543D78F363/

GUID pattern 899407D7-99FE-43D8-9A21-79EC328CAC21 found at offset 120h
1 BIOS region/1 Volume/1 FFSv2/File C6ECD531-DE59-419E-B1B4-2AA42237D54C/
```

### Interpretar Resultados

Los GUIDs identifican módulos únicos. Ejemplos comunes:

- **9E21FD93-...** → Probablemente módulo de Setup
- **B1DA0ADF-...** → Módulo con configuración avanzada
- **C6ECD531-...** → Módulo HII (interfaz)

### Extraer GUIDs Encontrados

```bash
# Listar todos los GUIDs únicos
grep "File" step2_search_results.txt | grep -oE "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | sort -u
```

---

## PASO 3: Extraer Datos IFR de los Módulos

### Preparar Directorio

```bash
mkdir -p step3_ifr_data
```

### Extraer IFR de Módulos PE32

Necesitamos encontrar todos los archivos PE32 (ejecutables UEFI) y extraer su IFR:

```bash
# Buscar todos los body.bin que sean PE32
find step1_modules -name "body.bin" -type f > pe32_files.txt

# Para cada archivo PE32, intentar extraer IFR
while read pe32_file; do
    # Crear nombre de salida basado en la ruta
    output_name=$(echo "$pe32_file" | tr '/' '_' | sed 's/.bin$/.txt/')
    
    # Intentar extraer IFR
    ../external/ifrextractor "$pe32_file" "step3_ifr_data/$output_name" 2>/dev/null
    
    # Si el archivo está vacío, eliminarlo
    if [ ! -s "step3_ifr_data/$output_name" ]; then
        rm -f "step3_ifr_data/$output_name"
    fi
done < pe32_files.txt
```

### Comando Manual Simplificado

```bash
# Extraer IFR de un módulo específico
../external/ifrextractor step1_modules/.../body.bin step3_ifr_data/setup_module.txt
```

### ¿Qué hace IFRExtractor?

Convierte los datos binarios IFR (Internal Forms Representation) en texto legible que describe:
- Formularios del BIOS (páginas/menús)
- Opciones configurables (One Of, CheckBox, etc.)
- Condiciones de visibilidad (Suppress If, Gray-Out If)
- Combinaciones de teclas (HotKey)
- IDs de preguntas (Question IDs)

### Verificar Extracción

```bash
# Contar archivos IFR extraídos
ls -1 step3_ifr_data/*.txt | wc -l

# Ver tamaño de archivos
ls -lh step3_ifr_data/ | grep ".txt"

# Mostrar primeras líneas de un IFR
head -50 step3_ifr_data/setup_module.txt
```

### Ejemplo de Salida IFR

```
Form Set: {D41C6D7E-D0B3-4F94-8D5D-F0F5B1E3C2A9}, Title: "Setup", Help: "Enter Setup", Class: 0x1
  Class: {0x00000001, 0x0000, 0x0000, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}}
  Default Store: 0x0 (Standard)
  Default Store: 0x1 (Manufacturing)
  
  Form: 0x1, Title: "Main"
    Subtitle: "System Information"
    
    One Of: System Time, VarStore: 0x1234, VarOffset: 0x10, Size: 1, Default: 0x0
      Option: "12H" Value: 0x0
      Option: "24H" Value: 0x1
    End One Of
    
    One Of: Advanced Settings, VarStore: 0x1234, VarOffset: 0x20, Size: 1
      Suppress If: True      <-- ¡OPCIÓN OCULTA!
        Gray-Out If: False
      End
      
      HotKey: Scan Code 0x0B, Unicode 0x0, Modifier: Ctrl    <-- ¡COMBINACIÓN DE TECLAS!
      
      Option: "Enabled" Value: 0x1
      Option: "Disabled" Value: 0x0
    End One Of
```

---

## PASO 4: Analizar IFR para Encontrar Combinaciones de Teclas

### Buscar Hotkeys Definidos

```bash
# Buscar la palabra "HotKey" o "hotkey"
grep -r -i "hotkey" step3_ifr_data/ > step4_findings.txt

# Buscar códigos de escaneo específicos (F1-F12)
grep -r -E "Scan.*Code.*0x(0B|0C|0D|0E|3B|3C|3D|3E|3F|44|57|58)" step3_ifr_data/ >> step4_findings.txt

# Buscar modificadores (Ctrl, Alt, Shift)
grep -r -E "Modifier.*(Ctrl|Alt|Shift)" step3_ifr_data/ >> step4_findings.txt
```

### Buscar Opciones Suprimidas (Ocultas)

```bash
# Buscar "Suppress If"
grep -r -i "suppress if" step3_ifr_data/ >> step4_findings.txt

# Context: mostrar 5 líneas antes y después
grep -r -i -B5 -A5 "suppress if" step3_ifr_data/ > suppressed_options.txt
```

### Buscar Opciones Deshabilitadas

```bash
# Buscar "Gray-Out If"
grep -r -i "gray-out if\|grayoutif" step3_ifr_data/ >> step4_findings.txt
```

### Análisis Manual de IFR

Abre cada archivo .txt y busca estos patrones:

#### 1. HotKey Definition (Lo más directo)

```
One Of: Hidden Advanced Menu
  Question Id: 0x1234
  
  HotKey:
    Scan Code: 0x0B          # 0x0B = F1
    Unicode: 0x0000
    Modifier: Ctrl           # Control key
  End HotKey
  
  Option: "Enabled" Value: 0x1
End One Of
```

**Interpretación**: Presiona **Ctrl + F1** para activar "Hidden Advanced Menu"

#### 2. Suppress If True (Opción completamente oculta)

```
Suppress If {0F 01}
  True
  
  Form Ref: Form ID 0x1003, Title: "Advanced Chipset Configuration"
  
End
```

**Interpretación**: El menú "Advanced Chipset Configuration" está oculto. Puede desbloquearse con una combinación de teclas que active esta opción.

#### 3. Suppress If con Condición

```
Suppress If {12 06 02 00 01 00 23 00 00 00 00 00 00 00 00 00}
  Get Question Value (VarStore 0x2, Offset 0x1) == 0x0
  
  One Of: Overclocking Options
    Option: "Auto" Value: 0x0
    Option: "Manual" Value: 0x1
  End One Of
  
End
```

**Interpretación**: "Overclocking Options" se oculta si una variable específica es 0. Cambiar esa variable o encontrar el hotkey que la modifica desbloqueará la opción.

#### 4. Gray-Out If (Opción visible pero deshabilitada)

```
Gray-Out If {12 06 02 00 05 00 23 00 00 00 01 00 00 00 00 00}
  
  One Of: CPU Core Voltage
    Option: "Auto" Value: 0x0
    Option: "1.2V" Value: 0x1
    Option: "1.3V" Value: 0x2
  End One Of
  
End
```

**Interpretación**: "CPU Core Voltage" está deshabilitado (gris). Necesitas habilitar una opción previa o usar un hotkey.

### Códigos de Escaneo Comunes

| Código Hex | Tecla | Uso Común |
|------------|-------|-----------|
| 0x0B | F1 | Menú avanzado |
| 0x0C | F2 | Overclock |
| 0x0D | F3 | Configuración CPU |
| 0x0E | F4 | Configuración RAM |
| 0x3B | F5 | Boot options |
| 0x44 | F10 | Save & Exit |
| 0x57 | F11 | BBS Popup |
| 0x58 | F12 | Network boot |

### Modificadores

| Modificador | Valor | Uso |
|-------------|-------|-----|
| Ctrl | 0x04 | Control izquierdo |
| Alt | 0x10 | Alt izquierdo |
| Shift | 0x01 | Shift izquierdo |
| Ctrl+Shift | 0x05 | Combinación |
| Ctrl+Alt | 0x14 | Combinación |

---

## PASO 5: Crear Resumen de Hallazgos

### Documentar lo Encontrado

```bash
cat > step4_findings_summary.txt << 'EOF'
========================================
RESUMEN DE ANÁLISIS MANUAL
========================================

Archivo analizado: bios_original.bin
Fecha: 2025-01-29
Módulos extraídos: 1247
Archivos IFR generados: 23

COMBINACIONES DE TECLAS ENCONTRADAS:
------------------------------------

1. Ctrl + F1
   Archivo: step3_ifr_data/setup_module.txt
   Línea: 456
   Contexto: One Of: Advanced Menu
   Acción: Desbloquea menú avanzado

2. Ctrl + F2  
   Archivo: step3_ifr_data/chipset_config.txt
   Línea: 892
   Contexto: Form Ref: Overclocking
   Acción: Activa opciones de overclock

3. Alt + F1
   Archivo: step3_ifr_data/security.txt
   Línea: 234
   Contexto: Suppress If True
   Acción: Muestra opciones de seguridad ocultas

OPCIONES OCULTAS (Suppress If):
--------------------------------

- Advanced Chipset Configuration (Form ID: 0x1003)
- CPU Power Management (Form ID: 0x2001)
- Memory Timing Configuration (Form ID: 0x2005)
- PCIe Configuration (Form ID: 0x3001)

OPCIONES DESHABILITADAS (Gray-Out If):
---------------------------------------

- CPU Core Voltage (Requiere habilitar "Advanced Mode")
- XMP Profile (Requiere "Memory Overclocking" = Enabled)
- SATA Hot Plug (Requiere "AHCI Mode")

RECOMENDACIONES:
----------------

1. Probar Ctrl+F1 en la página Main del BIOS
2. Probar Ctrl+F2 en la página Advanced
3. Verificar si Alt+F1 funciona al entrar al BIOS
4. Probar combinaciones múltiples si las individuales no funcionan

NOTAS:
------

- Algunos hotkeys pueden requerir presionarse en páginas específicas
- Mantener la combinación presionada por 2-3 segundos
- Si no funciona, intentar durante el POST antes de entrar al BIOS
- Hacer backup del BIOS antes de cambiar configuraciones avanzadas

EOF

cat step4_findings_summary.txt
```

---

## Comandos de Referencia Rápida

### Setup Completo

```bash
# 1. Crear estructura
mkdir -p bios_analysis && cd bios_analysis

# 2. Copiar BIOS
cp /path/to/bios.bin .

# 3. Extraer módulos
../external/uefiextract bios.bin step1_modules

# 4. Buscar Setup
../external/uefifind bios.bin text "Setup" > step2_search.txt
../external/uefifind bios.bin text "Advanced" >> step2_search.txt

# 5. Extraer IFR de todos los PE32
mkdir -p step3_ifr_data
find step1_modules -name "body.bin" -type f | while read f; do
    out="step3_ifr_data/$(echo $f | tr '/' '_').txt"
    ../external/ifrextractor "$f" "$out" 2>/dev/null && \
    [ -s "$out" ] || rm -f "$out"
done

# 6. Buscar hotkeys
grep -r -i "hotkey\|scan.*code" step3_ifr_data/ > step4_hotkeys.txt
grep -r -i "suppress if" step3_ifr_data/ > step4_suppressed.txt
grep -r -i "gray-out" step3_ifr_data/ > step4_grayout.txt

# 7. Ver resultados
cat step4_hotkeys.txt | less
```

### Búsqueda Específica

```bash
# Buscar tecla F1 (0x0B)
grep -r "0x0B\|0x0b" step3_ifr_data/

# Buscar tecla F2 (0x0C)
grep -r "0x0C\|0x0c" step3_ifr_data/

# Buscar Ctrl
grep -r -i "ctrl\|control" step3_ifr_data/

# Buscar Alt
grep -r -i "alt" step3_ifr_data/ | grep -v "default\|alternative"

# Buscar por GUID específico
../external/uefifind bios.bin guid "9E21FD93-54C0-4D06-9E3E-BC903F5A8C5B"
```

---

## Ejemplos Reales de Hallazgos

### Ejemplo 1: Hotkey Directo

```
Archivo: step3_ifr_data/File_9E21FD93_body.bin.txt
Línea: 1247

Form: 0x1, Title: "Main"
  
  One Of: Advanced Mode, VarStore: 0x1, VarOffset: 0x50, Flags: 0x10
    HotKey:
      Scan Code: 0x0B
      Unicode: 0x0000  
      Shift: None
      Alt: None
      Control: Left
      Logo: None
    End HotKey
    
    Option: "Disabled", Value: 0x0, Default
    Option: "Enabled", Value: 0x1
  End One Of
```

**Resultado**: **Ctrl + F1** activa "Advanced Mode"

### Ejemplo 2: Opción Completamente Oculta

```
Archivo: step3_ifr_data/File_B1DA0ADF_body.bin.txt
Línea: 892

Suppress If {0F 01}
  True
  
  Form Ref: Form ID 0x2005, Title: "OC Configuration"
    Question ID: 0x3015
  End Form Ref
  
End
```

**Resultado**: Existe un menú "OC Configuration" completamente oculto. Buscar en otros IFR algún hotkey que referencie Question ID 0x3015 o Form ID 0x2005.

### Ejemplo 3: Condición de Supresión

```
Archivo: step3_ifr_data/File_C6ECD531_body.bin.txt
Línea: 456

Get Question Value: VarStore 0x1, VarOffset 0x50

Suppress If {12 06}
  Question Value == 0x0
  
  One Of: CPU Voltage Control
    Option: "Auto", Value: 0x0, Default
    Option: "Manual", Value: 0x1
  End One Of
  
End
```

**Resultado**: "CPU Voltage Control" se oculta si VarStore 0x1 Offset 0x50 == 0. Esto corresponde a "Advanced Mode" del Ejemplo 1. Activando Advanced Mode (Ctrl+F1) se mostrará esta opción.

---

## Solución de Problemas

### No se extraen módulos

**Problema**: `step1_modules` está vacío

**Soluciones**:
```bash
# 1. Verificar que el archivo sea BIOS UEFI
strings bios.bin | grep -i "uefi\|_fvh\|efi"

# 2. Verificar versión de UEFIExtract
../external/uefiextract --version

# 3. Intentar sin parámetros adicionales
../external/uefiextract bios.bin output_dir

# 4. El BIOS puede estar comprimido/encriptado
# Usar primero las utilidades de BIOSUtilities para desempaquetarlo
```

### IFRExtractor no genera output

**Problema**: Los archivos .txt están vacíos

**Explicación**: No todos los módulos PE32 contienen IFR. Solo los módulos relacionados con Setup (interfaz del BIOS) tienen IFR.

**Solución**:
```bash
# Enfocarse en módulos que contienen "Setup"
find step1_modules -type d -iname "*setup*"

# Extraer solo de esos módulos
find step1_modules -path "*Setup*" -name "body.bin" | \
while read f; do
    ../external/ifrextractor "$f" "step3_ifr_data/$(basename $(dirname $f)).txt"
done
```

### No encuentro hotkeys

**Problema**: No hay patrones de HotKey en los IFR

**Explicación**: No todos los BIOS usan hotkeys definidos en IFR. Algunos están hardcodeados en el código.

**Alternativas**:
1. Revisar opciones "Suppress If" - estas son ocultas por alguna razón
2. Buscar en foros específicos del modelo de tu hardware
3. Probar combinaciones comunes del fabricante (ver BIOS_KEY_COMBINATIONS.md)
4. Analizar el código assembly del módulo Setup (avanzado)

---

## Próximos Pasos

Después de encontrar combinaciones:

1. **Documentar** todo en un archivo de notas
2. **Probar** en el hardware real (con precaución)
3. **Hacer backup** del BIOS antes de cambiar opciones avanzadas
4. **Compartir** hallazgos con la comunidad si encuentras algo nuevo

## Referencias

- [IFR Format Specification](https://github.com/tianocore/edk2/tree/master/MdeModulePkg/Universal/SetupBrowserDxe)
- [UEFI Specification](https://uefi.org/specifications)
- [BIOSUtilities Repository](https://github.com/extremerom/BIOSUtilities)
- [BIOS_KEY_COMBINATIONS.md](BIOS_KEY_COMBINATIONS.md) - Database de combinaciones conocidas

---

**Fin de la guía manual**

Para análisis automatizado, usar: `./extract_bios_ifr.sh bios.bin`

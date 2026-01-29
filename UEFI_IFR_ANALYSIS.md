# Análisis UEFI IFR para Encontrar Opciones Avanzadas del BIOS

## Descripción

Este documento explica cómo usar las herramientas prebuilt de LongSoft para extraer módulos UEFI y datos IFR (Internal Forms Representation) de archivos BIOS, con el objetivo de encontrar combinaciones de teclas que activen opciones avanzadas ocultas en el BIOS.

## Herramientas Utilizadas

Las siguientes herramientas prebuilt se descargan automáticamente:

1. **IFRExtractor-RS v1.6.0** ([GitHub](https://github.com/LongSoft/IFRExtractor-RS))
   - Extrae datos IFR de módulos UEFI
   - Versión: https://github.com/LongSoft/IFRExtractor-RS/releases/download/v1.6.0/ifrextractor_1.6.0_linux.zip

2. **UEFIFind NE A73** ([GitHub](https://github.com/LongSoft/UEFITool))
   - Busca patrones y texto en imágenes UEFI
   - Versión: https://github.com/LongSoft/UEFITool/releases/download/A73/UEFIFind_NE_A73_x64_linux.zip

3. **UEFIExtract NE A73** ([GitHub](https://github.com/LongSoft/UEFITool))
   - Extrae módulos de imágenes UEFI
   - Versión: https://github.com/LongSoft/UEFITool/releases/download/A73/UEFIExtract_NE_A73_x64_linux.zip

## Instalación Rápida

```bash
# Descargar e instalar las herramientas
chmod +x setup_ifr_tools.sh
./setup_ifr_tools.sh
```

Las herramientas se instalarán en el directorio `external/`.

## Uso Rápido (Automático)

Para análisis rápido de un archivo BIOS:

```bash
chmod +x extract_bios_ifr.sh
./extract_bios_ifr.sh mi_bios.bin
```

Esto creará un directorio `out/mi_bios_analysis/` con:
- `01_modules/` - Módulos UEFI extraídos
- `02_setup_search.log` - Resultados de búsqueda de módulos Setup
- `03_ifr_data/` - Archivos IFR en formato texto
- `04_key_combinations.txt` - Combinaciones de teclas encontradas
- `README.txt` - Resumen del análisis

## Uso Manual (Paso a Paso)

### Paso 1: Extraer Módulos UEFI

```bash
./external/uefiextract bios.bin -o modules/ -m body
```

Esto extrae todos los módulos del BIOS en la carpeta `modules/`.

### Paso 2: Buscar Módulos de Setup

```bash
# Buscar por palabra clave "Setup"
./external/uefifind bios.bin text "Setup"

# Buscar por palabra clave "Advanced"
./external/uefifind bios.bin text "Advanced"

# Buscar por GUID de protocolo HII Config Access
./external/uefifind bios.bin guid 899407D7-99FE-43D8-9A21-79EC328CAC21
```

Esto identifica qué módulos contienen la configuración del BIOS.

### Paso 3: Extraer Datos IFR

Para cada archivo PE32 encontrado en los módulos extraídos:

```bash
./external/ifrextractor modules/xxx/yyy.efi output.txt
```

Esto convierte los datos IFR binarios en formato texto legible.

### Paso 4: Analizar los Archivos IFR

Busca en los archivos `.txt` generados por:

#### A. Combinaciones de Teclas (HotKeys)

```bash
grep -i "hotkey\|key\|ctrl\|alt\|f1\|f2\|f10" *.txt
```

Patrones comunes:
- `Key: Scan Code 0x0B` → F1
- `Key: Scan Code 0x0C` → F2
- Modificadores: Ctrl, Alt, Shift

#### B. Opciones Ocultas (Suppress If)

```bash
grep -i "suppress if\|gray-out if" *.txt
```

Las sentencias `Suppress If` indican opciones que están ocultas bajo ciertas condiciones.

Ejemplo:
```
Suppress If: True
  One Of: Security Option, ...
End
```

#### C. Opciones Avanzadas

```bash
grep -i "advanced\|hidden\|debug\|overclock" *.txt
```

### Paso 5: Interpretar los Resultados

#### Códigos de Escaneo de Teclas Comunes

| Código | Tecla |
|--------|-------|
| 0x0B   | F1    |
| 0x0C   | F2    |
| 0x0D   | F3    |
| 0x0E   | F4    |
| 0x44   | F10   |
| 0x57   | F11   |
| 0x58   | F12   |

#### Modificadores

- **Ctrl**: Control key
- **Alt**: Alt key  
- **Shift**: Shift key

#### Combinaciones Comunes

Las combinaciones de teclas más comunes para activar menús avanzados:

1. **Ctrl + F1** - La más común
2. **Ctrl + F2**
3. **Alt + F1**
4. **Alt + F2**
5. **Shift + F1**
6. **Ctrl derecho + Shift derecho + F2**
7. **Alt izquierdo + Alt derecho + F2**

### Paso 6: Probar las Combinaciones

1. Reinicia y entra al BIOS
2. Una vez en el menú BIOS, prueba las combinaciones encontradas
3. Algunas requieren presionarse durante el POST (antes del BIOS)
4. Otras funcionan dentro de menús específicos del BIOS

## Ejemplo de Análisis

```bash
# 1. Instalar herramientas
./setup_ifr_tools.sh

# 2. Extraer módulos
./external/uefiextract mybios.bin -o analysis/modules -m body

# 3. Buscar módulos Setup
./external/uefifind mybios.bin text "Setup" > analysis/setup_modules.txt

# 4. Extraer IFR de todos los PE32
find analysis/modules -type f -exec sh -c '
    if file "$1" | grep -q "PE32"; then
        ./external/ifrextractor "$1" "analysis/ifr/$(basename $1).txt"
    fi
' sh {} \;

# 5. Buscar combinaciones de teclas
grep -r -i "hotkey\|ctrl\|alt" analysis/ifr/ > analysis/keys.txt

# 6. Revisar resultados
cat analysis/keys.txt
```

## Patrones IFR Importantes

### 1. Definición de Hotkey

```
One Of: My Hidden Option
  Question Id: 0x1234
  HotKey: 
    Scan Code: 0x0B    # F1
    Unicode: 0x0
    Modifier: Ctrl     # Control key
```

### 2. Opción Suprimida (Oculta)

```
Suppress If {0F 01}
  True
  One Of: Advanced Settings
    ...
  End One Of
End
```

Esto significa que "Advanced Settings" está oculto si la condición es True.

### 3. Opción Deshabilitada (Gris)

```
Gray-Out If {0F 01}
  ...
  One Of: Overclocking
    ...
  End One Of
End
```

## Información Adicional

### ¿Qué es IFR?

IFR (Internal Forms Representation) es el formato que usa UEFI para definir la interfaz del BIOS Setup. Contiene:
- Definiciones de formularios (pantallas del BIOS)
- Opciones configurables
- Valores predeterminados
- Condiciones de visibilidad
- Combinaciones de teclas (hotkeys)

### ¿Por qué algunas opciones están ocultas?

Los fabricantes ocultan opciones por varias razones:
- Opciones peligrosas para usuarios normales
- Configuraciones de overclock/voltaje
- Opciones de depuración
- Configuraciones OEM específicas
- Opciones no completamente probadas

### Seguridad

⚠️ **ADVERTENCIA**: Modificar opciones avanzadas del BIOS puede:
- Dañar el hardware
- Causar inestabilidad del sistema
- Invalidar la garantía
- Hacer el sistema no booteable

Usa estas opciones bajo tu propio riesgo y solo si sabes lo que estás haciendo.

## Recursos

- [IFRExtractor-RS GitHub](https://github.com/LongSoft/IFRExtractor-RS)
- [UEFITool GitHub](https://github.com/LongSoft/UEFITool)
- [UEFI Specification](https://uefi.org/specifications)
- [IFR Format Documentation](https://github.com/tianocore/edk2/tree/master/MdeModulePkg/Universal/SetupBrowserDxe)

## Solución de Problemas

### Error: "Tools not found"
Ejecuta `./setup_ifr_tools.sh` primero para descargar las herramientas.

### UEFIExtract no extrae nada
- Verifica que el archivo sea una imagen BIOS/UEFI válida
- Algunos BIOS tienen protecciones o están encriptados
- Prueba primero con herramientas de BIOSUtilities para desempaquetar

### IFRExtractor no genera output
- No todos los módulos PE32 contienen datos IFR
- Solo los módulos relacionados con Setup tienen IFR
- Es normal que muchos módulos no generen output

### No encuentro combinaciones de teclas
- No todos los BIOS tienen hotkeys definidos
- Algunas combinaciones están hardcodeadas en el código (no en IFR)
- Revisa manualmente los archivos IFR para patrones de "Question" y "Suppress"

## Contribuciones

Este método usa herramientas de código abierto mantenidas por la comunidad. Para reportar problemas o mejoras:
- IFRExtractor: https://github.com/LongSoft/IFRExtractor-RS/issues
- UEFITool: https://github.com/LongSoft/UEFITool/issues

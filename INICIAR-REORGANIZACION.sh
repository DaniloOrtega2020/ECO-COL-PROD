#!/bin/bash

################################################################################
# SCRIPT DE INICIALIZACIÓN Y EJECUCIÓN - ECO-COL
# Reorganización Profesional Automatizada
# 
# Este script:
# 1. Verifica la ubicación de los archivos
# 2. Hace ejecutable el reorganizador
# 3. Lo ejecuta automáticamente
# 4. Muestra los resultados
################################################################################

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin Color

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}║     INICIALIZADOR ECO-COL REORGANIZACIÓN PROFESIONAL     ║${NC}"
echo -e "${CYAN}║                    Versión 1.0                            ║${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# PASO 1: DEFINIR UBICACIONES
# ============================================================================

# Ubicación de los archivos descargados (según su captura de pantalla)
UBICACION_DESCARGADOS="$HOME/Descargas/ECO-COL"

# Ubicación del script reorganizador
SCRIPT_REORGANIZADOR="${UBICACION_DESCARGADOS}/reorganizador-profesional-eco-col.sh"

# Ubicación de los archivos fuente de ECO-COL (NECESITA CONFIGURAR ESTO)
# Esta es la carpeta que contiene sus 26 archivos HTML originales
UBICACION_FUENTE_ECOCOL="$HOME/Descargas/ECO-COL-ORIGINAL"

# Ubicación donde se creará la nueva estructura
UBICACION_DESTINO="$HOME/Documentos/ECO-COL-FINAL"

echo -e "${BLUE}📍 Configuración de Ubicaciones:${NC}"
echo "   Descargados: ${UBICACION_DESCARGADOS}"
echo "   Script: ${SCRIPT_REORGANIZADOR}"
echo "   Fuente ECO-COL: ${UBICACION_FUENTE_ECOCOL}"
echo "   Destino: ${UBICACION_DESTINO}"
echo ""

# ============================================================================
# PASO 2: VERIFICAR QUE LOS ARCHIVOS EXISTEN
# ============================================================================

echo -e "${BLUE}🔍 Verificando archivos...${NC}"

# Verificar que la carpeta de descargados existe
if [ ! -d "$UBICACION_DESCARGADOS" ]; then
    echo -e "${RED}✗ Error: No se encuentra la carpeta ${UBICACION_DESCARGADOS}${NC}"
    echo -e "${YELLOW}💡 Solución: Verifique que los archivos estén descargados en Descargas/ECO-COL${NC}"
    exit 1
fi

# Verificar que el script existe
if [ ! -f "$SCRIPT_REORGANIZADOR" ]; then
    echo -e "${RED}✗ Error: No se encuentra el script reorganizador${NC}"
    echo -e "${YELLOW}💡 Ubicación esperada: ${SCRIPT_REORGANIZADOR}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Script reorganizador encontrado${NC}"

# ============================================================================
# PASO 3: PREGUNTAR POR LA UBICACIÓN DE LOS ARCHIVOS FUENTE
# ============================================================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  CONFIGURACIÓN REQUERIDA${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Necesito saber dónde están sus archivos ECO-COL originales"
echo "(Los 26 archivos HTML, scripts .sh, etc.)"
echo ""
echo -e "${BLUE}Opciones comunes:${NC}"
echo "  1. Carpeta de Descargas"
echo "  2. Carpeta de Documentos"
echo "  3. Escritorio"
echo "  4. Otra ubicación"
echo ""

# Mostrar algunas opciones comunes
echo -e "${CYAN}Buscando carpetas ECO-COL en ubicaciones comunes...${NC}"

OPCIONES_ENCONTRADAS=()
CONTADOR=1

# Buscar en Descargas
if [ -d "$HOME/Descargas/DOCUMENTOS ADICIONALES ECO COL V2-3-4" ]; then
    OPCIONES_ENCONTRADAS+=("$HOME/Descargas/DOCUMENTOS ADICIONALES ECO COL V2-3-4")
    echo "  [$CONTADOR] $HOME/Descargas/DOCUMENTOS ADICIONALES ECO COL V2-3-4"
    ((CONTADOR++))
fi

if [ -d "$HOME/Descargas/ECO-COL VERSION FINAL V5" ]; then
    OPCIONES_ENCONTRADAS+=("$HOME/Descargas/ECO-COL VERSION FINAL V5")
    echo "  [$CONTADOR] $HOME/Descargas/ECO-COL VERSION FINAL V5"
    ((CONTADOR++))
fi

# Buscar en Documentos
if [ -d "$HOME/Documentos/ECO-COL" ]; then
    OPCIONES_ENCONTRADAS+=("$HOME/Documentos/ECO-COL")
    echo "  [$CONTADOR] $HOME/Documentos/ECO-COL"
    ((CONTADOR++))
fi

# Buscar en Desktop
if [ -d "$HOME/Desktop/ECO-COL" ]; then
    OPCIONES_ENCONTRADAS+=("$HOME/Desktop/ECO-COL")
    echo "  [$CONTADOR] $HOME/Desktop/ECO-COL"
    ((CONTADOR++))
fi

echo ""
echo -e "${YELLOW}Ingrese el número de la opción O escriba la ruta completa:${NC}"
read -r RESPUESTA

# Procesar respuesta
if [[ "$RESPUESTA" =~ ^[0-9]+$ ]] && [ "$RESPUESTA" -ge 1 ] && [ "$RESPUESTA" -lt "$CONTADOR" ]; then
    # Es un número - usar opción predefinida
    INDICE=$((RESPUESTA - 1))
    UBICACION_FUENTE_ECOCOL="${OPCIONES_ENCONTRADAS[$INDICE]}"
    echo -e "${GREEN}✓ Usando: ${UBICACION_FUENTE_ECOCOL}${NC}"
else
    # Es una ruta - usarla directamente
    UBICACION_FUENTE_ECOCOL="$RESPUESTA"
    echo -e "${GREEN}✓ Usando ruta personalizada: ${UBICACION_FUENTE_ECOCOL}${NC}"
fi

# Verificar que la ubicación fuente existe
if [ ! -d "$UBICACION_FUENTE_ECOCOL" ]; then
    echo -e "${RED}✗ Error: La ubicación no existe: ${UBICACION_FUENTE_ECOCOL}${NC}"
    echo ""
    echo -e "${YELLOW}💡 Soluciones:${NC}"
    echo "   1. Verifique la ruta completa"
    echo "   2. Use 'ls' para listar las carpetas"
    echo "   3. Arrastre la carpeta a la terminal para obtener la ruta exacta"
    exit 1
fi

echo -e "${GREEN}✓ Ubicación fuente verificada${NC}"

# ============================================================================
# PASO 4: HACER EJECUTABLE EL SCRIPT
# ============================================================================

echo ""
echo -e "${BLUE}🔧 Haciendo el script ejecutable...${NC}"

chmod +x "$SCRIPT_REORGANIZADOR"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script ahora es ejecutable${NC}"
else
    echo -e "${RED}✗ Error al hacer el script ejecutable${NC}"
    exit 1
fi

# ============================================================================
# PASO 5: MOSTRAR RESUMEN Y CONFIRMAR
# ============================================================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}📋 RESUMEN DE LA REORGANIZACIÓN${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Origen:${NC}  ${UBICACION_FUENTE_ECOCOL}"
echo -e "${BLUE}Destino:${NC} ${UBICACION_DESTINO}"
echo ""
echo -e "${YELLOW}Qué va a suceder:${NC}"
echo "  1. Se creará respaldo completo en:"
echo "     ${UBICACION_DESTINO}-RESPALDO-[fecha]"
echo "  2. Se analizarán todos los archivos HTML, .sh, .txt, .md"
echo "  3. Se creará nueva estructura en 9 capas"
echo "  4. Se migrará el archivo de producción"
echo "  5. Se archivarán versiones antiguas"
echo "  6. Se generará documentación automática"
echo ""
echo -e "${GREEN}Tiempo estimado: 1-2 minutos${NC}"
echo ""

read -p "¿Proceder con la reorganización? (si/no): " -r CONFIRMAR

if [[ ! $CONFIRMAR =~ ^[Ss][Ii]$ ]]; then
    echo -e "${YELLOW}⚠️  Operación cancelada por el usuario${NC}"
    exit 0
fi

# ============================================================================
# PASO 6: EJECUTAR EL SCRIPT REORGANIZADOR
# ============================================================================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}║           INICIANDO REORGANIZACIÓN PROFESIONAL            ║${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Cambiar al directorio donde está el script
cd "$UBICACION_DESCARGADOS" || exit 1

# Ejecutar el script pasándole el directorio fuente
# El script preguntará por el directorio, así que lo pasamos automáticamente
echo "$UBICACION_FUENTE_ECOCOL" | "$SCRIPT_REORGANIZADOR"

RESULTADO=$?

# ============================================================================
# PASO 7: VERIFICAR RESULTADOS
# ============================================================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}📊 VERIFICACIÓN DE RESULTADOS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $RESULTADO -eq 0 ]; then
    echo -e "${GREEN}✓ ¡REORGANIZACIÓN COMPLETADA EXITOSAMENTE!${NC}"
    echo ""
    
    # Verificar que se creó el directorio destino
    if [ -d "$UBICACION_DESTINO" ]; then
        echo -e "${GREEN}✓ Nueva estructura creada en: ${UBICACION_DESTINO}${NC}"
        
        # Verificar archivo de producción
        if [ -f "$UBICACION_DESTINO/ECO-COL-PRODUCCION.html" ]; then
            echo -e "${GREEN}✓ Archivo de producción creado${NC}"
        fi
        
        # Contar archivos migrados
        NUM_ARCHIVOS=$(find "$UBICACION_DESTINO" -type f | wc -l)
        echo -e "${GREEN}✓ Total de archivos en nueva estructura: ${NUM_ARCHIVOS}${NC}"
        
        # Mostrar estructura de directorios
        echo ""
        echo -e "${BLUE}📁 Nueva estructura de directorios:${NC}"
        ls -la "$UBICACION_DESTINO" | grep "^d" | awk '{print "   " $9}' | grep -v "^\.$\|^\.\.$"
        
    else
        echo -e "${YELLOW}⚠️  Advertencia: No se encontró el directorio destino${NC}"
    fi
    
else
    echo -e "${RED}✗ Error durante la reorganización (código: ${RESULTADO})${NC}"
    echo -e "${YELLOW}💡 Revise el archivo de registro para más detalles${NC}"
fi

# ============================================================================
# PASO 8: PRÓXIMOS PASOS
# ============================================================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🚀 PRÓXIMOS PASOS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Navegar a la nueva estructura:"
echo -e "   ${BLUE}cd \"${UBICACION_DESTINO}\"${NC}"
echo ""
echo "2. Ver el README principal:"
echo -e "   ${BLUE}cat README.md${NC}"
echo ""
echo "3. Ver el reporte de migración:"
echo -e "   ${BLUE}cat REPORTE-MIGRACION-*.md${NC}"
echo ""
echo "4. Abrir el archivo de producción en navegador:"
echo -e "   ${BLUE}open ECO-COL-PRODUCCION.html${NC}"
echo ""
echo "5. Explorar la estructura:"
echo -e "   ${BLUE}ls -la${NC}"
echo ""
echo -e "${GREEN}¡Todo listo para empezar a trabajar con ECO-COL profesional!${NC}"
echo ""

# ============================================================================
# PASO 9: ABRIR AUTOMÁTICAMENTE (OPCIONAL)
# ============================================================================

echo ""
read -p "¿Desea abrir el archivo de producción ahora? (si/no): " -r ABRIR

if [[ $ABRIR =~ ^[Ss][Ii]$ ]]; then
    if [ -f "$UBICACION_DESTINO/ECO-COL-PRODUCCION.html" ]; then
        echo -e "${BLUE}🌐 Abriendo en navegador...${NC}"
        open "$UBICACION_DESTINO/ECO-COL-PRODUCCION.html" 2>/dev/null || \
        xdg-open "$UBICACION_DESTINO/ECO-COL-PRODUCCION.html" 2>/dev/null || \
        echo -e "${YELLOW}⚠️  No se pudo abrir automáticamente. Abra manualmente el archivo.${NC}"
    fi
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}       ✨ REORGANIZACIÓN ECO-COL COMPLETADA ✨${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

exit 0

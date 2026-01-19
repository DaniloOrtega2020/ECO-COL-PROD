#!/bin/bash

################################################################################
# 🔍 ECO-COL DEEP CODE AUDITOR
# Analiza toda la carpeta ECO-COL y determina qué archivos están activos
# Identifica código obsoleto vs código en producción
# Mapea dependencias y estructura del proyecto
################################################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       🔍 ECO-COL DEEP CODE AUDITOR v1.0                  ║${NC}"
echo -e "${CYAN}║       Análisis Completo de Código y Dependencias         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que estamos en la carpeta correcta
if [ ! -d "ECO-COL" ] && [ "$(basename "$PWD")" != "ECO-COL" ]; then
    echo -e "${RED}❌ Error: No se encuentra la carpeta ECO-COL${NC}"
    echo -e "${YELLOW}Por favor ejecuta este script desde la carpeta padre de ECO-COL o dentro de ECO-COL${NC}"
    exit 1
fi

# Navegar a ECO-COL si no estamos ahí
if [ "$(basename "$PWD")" != "ECO-COL" ]; then
    cd ECO-COL
fi

REPORT_FILE="ECO-COL-AUDIT-REPORT-$(date +%Y%m%d-%H%M%S).txt"

echo -e "${BLUE}📊 Generando reporte: ${REPORT_FILE}${NC}\n"

# Inicializar reporte
cat > "$REPORT_FILE" << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                  🔍 ECO-COL CODE AUDIT REPORT                             ║
║                  Generated: $(date)                                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF

################################################################################
# 1. ESCANEO DE ESTRUCTURA DE CARPETAS
################################################################################
echo -e "${CYAN}[1/8] 📁 Escaneando estructura de carpetas...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. ESTRUCTURA DE CARPETAS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    tree -L 3 -d 2>/dev/null || find . -type d -maxdepth 3 | sort
    echo ""
} >> "$REPORT_FILE"

################################################################################
# 2. INVENTARIO DE ARCHIVOS HTML
################################################################################
echo -e "${CYAN}[2/8] 📄 Analizando archivos HTML...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2. ARCHIVOS HTML ENCONTRADOS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    HTML_COUNT=0
    find . -name "*.html" -type f | while read -r file; do
        HTML_COUNT=$((HTML_COUNT + 1))
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1-2)
        
        echo "📄 Archivo #$HTML_COUNT: $file"
        echo "   └─ Líneas: $SIZE"
        echo "   └─ Modificado: $MODIFIED"
        
        # Detectar librerías DICOM
        if grep -q "cornerstone" "$file" 2>/dev/null; then
            echo "   └─ 🔬 Usa Cornerstone.js"
        fi
        if grep -q "dicom-parser" "$file" 2>/dev/null; then
            echo "   └─ 🔬 Usa dicom-parser"
        fi
        if grep -q "IndexedDB" "$file" 2>/dev/null; then
            echo "   └─ 💾 Usa IndexedDB"
        fi
        if grep -q "localStorage" "$file" 2>/dev/null; then
            echo "   └─ 💾 Usa localStorage"
        fi
        
        # Detectar funciones clave
        if grep -q "function.*login\|onclick.*login" "$file" 2>/dev/null; then
            echo "   └─ 🔐 Tiene sistema de login"
        fi
        if grep -q "function.*DICOM\|loadDICOM\|uploadDICOM" "$file" 2>/dev/null; then
            echo "   └─ 🏥 Tiene carga de DICOM"
        fi
        if grep -q "function.*playPause\|cine.*control" "$file" 2>/dev/null; then
            echo "   └─ 🎬 Tiene controles de cine"
        fi
        
        echo ""
    done
    
    echo "Total archivos HTML: $(find . -name "*.html" -type f | wc -l)"
    echo ""
} >> "$REPORT_FILE"

################################################################################
# 3. ANÁLISIS DE ARCHIVOS .SH (Scripts Bash)
################################################################################
echo -e "${CYAN}[3/8] 🔧 Analizando scripts Bash...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "3. SCRIPTS BASH (.sh)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    find . -name "*.sh" -type f | while read -r file; do
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        EXECUTABLE=$([ -x "$file" ] && echo "✅ Ejecutable" || echo "⚠️  No ejecutable")
        
        echo "🔧 $file"
        echo "   └─ Líneas: $SIZE"
        echo "   └─ $EXECUTABLE"
        
        # Detectar qué hace el script
        if grep -q "FASE" "$file" 2>/dev/null; then
            FASE=$(grep -o "FASE [0-9]\+" "$file" | head -1)
            echo "   └─ 📦 Instalador de $FASE"
        fi
        if grep -q "cargo build\|rustc" "$file" 2>/dev/null; then
            echo "   └─ 🦀 Compila código Rust"
        fi
        if grep -q "notification\|server\|client" "$file" 2>/dev/null; then
            echo "   └─ 🔔 Sistema de notificaciones"
        fi
        
        echo ""
    done
    
    echo "Total scripts Bash: $(find . -name "*.sh" -type f | wc -l)"
    echo ""
} >> "$REPORT_FILE"

################################################################################
# 4. ANÁLISIS DE ARCHIVOS .TXT (Documentación)
################################################################################
echo -e "${CYAN}[4/8] 📝 Analizando documentación (.txt)...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "4. ARCHIVOS DE DOCUMENTACIÓN (.txt)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    find . -name "*.txt" -type f | while read -r file; do
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        
        echo "📝 $file"
        echo "   └─ Líneas: $SIZE"
        
        # Detectar tipo de documentación
        if grep -q "Análisis\|ANÁLISIS" "$file" 2>/dev/null; then
            echo "   └─ 📊 Documento de análisis"
        fi
        if grep -q "Script\|SCRIPT" "$file" 2>/dev/null; then
            echo "   └─ 💻 Documentación de script"
        fi
        if grep -q "README\|Instrucciones" "$file" 2>/dev/null; then
            echo "   └─ 📖 Manual de usuario"
        fi
        
        echo ""
    done
    
    echo "Total archivos TXT: $(find . -name "*.txt" -type f | wc -l)"
    echo ""
} >> "$REPORT_FILE"

################################################################################
# 5. DETECCIÓN DE ARCHIVOS EN PRODUCCIÓN
################################################################################
echo -e "${CYAN}[5/8] 🚀 Identificando archivos en producción...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "5. ARCHIVOS EN PRODUCCIÓN (Funcionales)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Criterios: Archivos con mayor líneas de código, funciones completas,"
    echo "           librerías modernas (Cornerstone), IndexedDB, y fecha reciente"
    echo ""
    
    # Buscar el HTML más completo
    BEST_HTML=""
    BEST_SIZE=0
    
    find . -name "*.html" -type f | while read -r file; do
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        
        # Calcular score
        SCORE=0
        
        # +100 puntos por cada 100 líneas
        SCORE=$((SCORE + SIZE / 100))
        
        # +50 puntos por Cornerstone
        if grep -q "cornerstone" "$file" 2>/dev/null; then
            SCORE=$((SCORE + 50))
        fi
        
        # +30 puntos por IndexedDB
        if grep -q "IndexedDB" "$file" 2>/dev/null; then
            SCORE=$((SCORE + 30))
        fi
        
        # +20 puntos por sistema de login
        if grep -q "function.*login" "$file" 2>/dev/null; then
            SCORE=$((SCORE + 20))
        fi
        
        # +20 puntos por controles de cine
        if grep -q "playPause\|cineControl" "$file" 2>/dev/null; then
            SCORE=$((SCORE + 20))
        fi
        
        # +10 puntos si tiene "ULTIMATE" o "V6" en el nombre
        if echo "$file" | grep -q -i "ultimate\|v6\|final\|fusion"; then
            SCORE=$((SCORE + 10))
        fi
        
        echo "📊 SCORE: $SCORE - $file"
        echo "   └─ Líneas: $SIZE"
        
        if [ $SCORE -gt 100 ]; then
            echo "   └─ ✅ CANDIDATO A PRODUCCIÓN"
        elif [ $SCORE -gt 50 ]; then
            echo "   └─ ⚠️  CANDIDATO SECUNDARIO"
        else
            echo "   └─ ❌ PROBABLEMENTE OBSOLETO"
        fi
        
        echo ""
    done
    
} >> "$REPORT_FILE"

################################################################################
# 6. DETECCIÓN DE ARCHIVOS OBSOLETOS
################################################################################
echo -e "${CYAN}[6/8] 🗑️  Identificando archivos obsoletos...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "6. ARCHIVOS OBSOLETOS (Candidatos a eliminación)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Criterios: Pocas líneas (<500), sin Cornerstone, sin IndexedDB,"
    echo "           nombres como 'test', 'demo', 'old', versiones antiguas"
    echo ""
    
    find . -name "*.html" -type f | while read -r file; do
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        
        IS_OBSOLETE=false
        REASONS=""
        
        # Razón 1: Muy pequeño
        if [ "$SIZE" -lt 500 ]; then
            IS_OBSOLETE=true
            REASONS="$REASONS\n      - Muy pequeño (<500 líneas)"
        fi
        
        # Razón 2: No usa Cornerstone
        if ! grep -q "cornerstone" "$file" 2>/dev/null; then
            IS_OBSOLETE=true
            REASONS="$REASONS\n      - No usa Cornerstone.js"
        fi
        
        # Razón 3: Nombre sospechoso
        if echo "$file" | grep -q -i "test\|demo\|old\|backup\|copy\|v[0-4]"; then
            IS_OBSOLETE=true
            REASONS="$REASONS\n      - Nombre indica versión antigua"
        fi
        
        if [ "$IS_OBSOLETE" = true ]; then
            echo "🗑️  OBSOLETO: $file"
            echo "   └─ Líneas: $SIZE"
            echo -e "   └─ Razones:$REASONS"
            echo ""
        fi
    done
    
} >> "$REPORT_FILE"

################################################################################
# 7. MAPA DE DEPENDENCIAS
################################################################################
echo -e "${CYAN}[7/8] 🔗 Generando mapa de dependencias...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "7. MAPA DE DEPENDENCIAS EXTERNAS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    echo "Librerías DICOM encontradas:"
    echo ""
    
    if grep -r "cornerstone-core" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ Cornerstone Core (Motor de renderizado DICOM)"
    fi
    
    if grep -r "cornerstone-tools" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ Cornerstone Tools (Herramientas de medición)"
    fi
    
    if grep -r "dicom-parser" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ DICOM Parser (Parser de archivos DICOM)"
    fi
    
    if grep -r "cornerstoneWADOImageLoader" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ WADO Image Loader (Carga de imágenes)"
    fi
    
    if grep -r "hammer.js\|Hammer" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ Hammer.js (Gestos táctiles)"
    fi
    
    echo ""
    echo "Almacenamiento de datos:"
    echo ""
    
    if grep -r "IndexedDB\|indexedDB" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ IndexedDB (Base de datos del navegador)"
    fi
    
    if grep -r "localStorage" . 2>/dev/null | head -1 > /dev/null; then
        echo "✅ localStorage (Almacenamiento simple)"
    fi
    
    echo ""
    
} >> "$REPORT_FILE"

################################################################################
# 8. RECOMENDACIONES FINALES
################################################################################
echo -e "${CYAN}[8/8] 💡 Generando recomendaciones...${NC}"

{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "8. RECOMENDACIONES DEL AUDITOR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    echo "✅ ARCHIVOS QUE DEBES MANTENER:"
    echo ""
    echo "   1. El archivo HTML con mayor score (probablemente *ULTIMATE*V6*.html)"
    echo "      → Este es tu visor DICOM en producción"
    echo ""
    echo "   2. Scripts de instalación (install-*.sh)"
    echo "      → Para deployment y configuración"
    echo ""
    echo "   3. Documentación de análisis (📊 Análisis*.txt)"
    echo "      → Historial y especificaciones"
    echo ""
    
    echo "🗑️  ARCHIVOS QUE PUEDES ELIMINAR:"
    echo ""
    echo "   1. Versiones antiguas (v0-1, v2-3, etc.)"
    echo "   2. Archivos 'demo', 'test', 'backup'"
    echo "   3. HTMLs con <500 líneas sin Cornerstone"
    echo "   4. Copias duplicadas"
    echo ""
    
    echo "📁 ESTRUCTURA RECOMENDADA:"
    echo ""
    echo "   ECO-COL/"
    echo "   ├── ECO-COL-ULTIMATE-V6-FUSION.html  ← PRODUCCIÓN"
    echo "   ├── install-fase-*.sh                ← Instaladores"
    echo "   ├── docs/"
    echo "   │   ├── Análisis*.txt"
    echo "   │   └── README.md"
    echo "   ├── archive/                         ← Versiones antiguas"
    echo "   │   ├── v1/"
    echo "   │   ├── v2/"
    echo "   │   └── ..."
    echo "   └── scripts/"
    echo "       └── auditor.sh                   ← Este script"
    echo ""
    
    echo "🔥 PRÓXIMOS PASOS:"
    echo ""
    echo "   1. Revisar este reporte completo"
    echo "   2. Hacer backup de TODA la carpeta"
    echo "   3. Mover archivos obsoletos a carpeta 'archive/'"
    echo "   4. Mantener solo el archivo HTML de producción"
    echo "   5. Documentar la versión final"
    echo ""
    
} >> "$REPORT_FILE"

################################################################################
# RESUMEN FINAL
################################################################################

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ AUDITORÍA COMPLETADA                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Estadísticas finales
TOTAL_HTML=$(find . -name "*.html" -type f | wc -l)
TOTAL_SH=$(find . -name "*.sh" -type f | wc -l)
TOTAL_TXT=$(find . -name "*.txt" -type f | wc -l)
TOTAL_FILES=$((TOTAL_HTML + TOTAL_SH + TOTAL_TXT))

echo -e "${CYAN}📊 Estadísticas:${NC}"
echo -e "   • Total archivos analizados: ${YELLOW}$TOTAL_FILES${NC}"
echo -e "   • Archivos HTML: ${YELLOW}$TOTAL_HTML${NC}"
echo -e "   • Scripts Bash: ${YELLOW}$TOTAL_SH${NC}"
echo -e "   • Documentación: ${YELLOW}$TOTAL_TXT${NC}"
echo ""

echo -e "${GREEN}📄 Reporte generado: ${YELLOW}$REPORT_FILE${NC}"
echo ""

# Mostrar archivo con mayor score (candidato a producción)
echo -e "${CYAN}🏆 ARCHIVO PRINCIPAL DETECTADO:${NC}"
echo ""

BEST_FILE=""
BEST_SCORE=0

find . -name "*.html" -type f | while read -r file; do
    SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
    SCORE=0
    
    SCORE=$((SCORE + SIZE / 100))
    grep -q "cornerstone" "$file" 2>/dev/null && SCORE=$((SCORE + 50))
    grep -q "IndexedDB" "$file" 2>/dev/null && SCORE=$((SCORE + 30))
    grep -q "function.*login" "$file" 2>/dev/null && SCORE=$((SCORE + 20))
    grep -q "playPause" "$file" 2>/dev/null && SCORE=$((SCORE + 20))
    echo "$file" | grep -q -i "ultimate\|v6\|final\|fusion" && SCORE=$((SCORE + 10))
    
    if [ $SCORE -gt $BEST_SCORE ]; then
        BEST_SCORE=$SCORE
        BEST_FILE=$file
    fi
done

if [ -n "$BEST_FILE" ]; then
    echo -e "   ${GREEN}✅ $BEST_FILE${NC}"
    echo -e "   ${YELLOW}Score: $BEST_SCORE puntos${NC}"
    echo -e "   ${CYAN}→ Este es tu visor DICOM en producción${NC}"
else
    echo -e "   ${YELLOW}⚠️  No se pudo determinar automáticamente${NC}"
    echo -e "   ${CYAN}→ Revisa el reporte para más detalles${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Para ver el reporte completo:${NC}"
echo -e "${YELLOW}cat $REPORT_FILE${NC}"
echo ""
echo -e "${GREEN}Para abrirlo en un editor:${NC}"
echo -e "${YELLOW}nano $REPORT_FILE${NC}"
echo -e "${YELLOW}# o${NC}"
echo -e "${YELLOW}open $REPORT_FILE${NC}"
echo ""

# Preguntar si desea ver el reporte ahora
read -p "¿Deseas ver el reporte completo ahora? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    less "$REPORT_FILE" || cat "$REPORT_FILE"
fi

echo ""
echo -e "${GREEN}✅ Auditoría completada exitosamente${NC}"
echo ""

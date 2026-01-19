#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ECO-COL PRO V4.2 - INSTALADOR DE FIX DEFINITIVO          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Ir a la carpeta de descargas
cd ~/Downloads 2>/dev/null || cd ~/Descargas 2>/dev/null || cd ~

echo "📍 Ubicación actual: $(pwd)"
echo ""

# Buscar el archivo
if [ -f "ECO-COL-PRO-V4.1-FIXED.html" ]; then
    echo "✅ Archivo encontrado: ECO-COL-PRO-V4.1-FIXED.html"
else
    echo "❌ ERROR: No se encontró ECO-COL-PRO-V4.1-FIXED.html"
    echo "   Por favor descarga el archivo primero"
    exit 1
fi

echo ""
echo "🔧 Aplicando correcciones..."
echo ""

# Crear versión V4.2 corregida
python3 << 'PYCODE'
import re

# Leer archivo
with open('ECO-COL-PRO-V4.1-FIXED.html', 'r', encoding='utf-8') as f:
    html = f.read()

# CORRECCIÓN 1: Frame separator
html = html.replace('?frame=', '&frame=')
print("✅ Corrección 1: Frame separator (?frame= → &frame=)")

# CORRECCIÓN 2: Asegurar que h2ImageIds se copia correctamente
# Buscar y reemplazar la línea problemática en openStudyH2
old_line = 'h2ImageIds = [...dicomData.imageIds];'
if old_line not in html:
    # Intentar con espacios diferentes
    old_patterns = [
        'h2ImageIds = [...dicomData.imageIds];',
        'h2ImageIds=[...dicomData.imageIds];',
        'h2ImageIds = [ ...dicomData.imageIds ];'
    ]
    for pattern in old_patterns:
        if pattern in html:
            html = html.replace(pattern, 'h2ImageIds = Array.from(dicomData.imageIds);')
            print(f"✅ Corrección 2: Array copy mejorado")
            break
else:
    html = html.replace(old_line, 'h2ImageIds = Array.from(dicomData.imageIds);')
    print("✅ Corrección 2: Array copy mejorado")

# Guardar como V4.2
with open('ECO-COL-PRO-V4.2-FINAL.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("✅ Archivo V4.2 creado exitosamente")
PYCODE

if [ $? -eq 0 ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  ✅ INSTALACIÓN COMPLETADA                                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📄 Archivo creado: ECO-COL-PRO-V4.2-FINAL.html"
    echo "📍 Ubicación: $(pwd)/ECO-COL-PRO-V4.2-FINAL.html"
    echo ""
    echo "🚀 Para abrir el sistema:"
    echo "   open ECO-COL-PRO-V4.2-FINAL.html"
    echo ""
    echo "🔍 Para verificar en consola (F12):"
    echo "   debugStorage()"
    echo ""
else
    echo ""
    echo "❌ ERROR durante la instalación"
    exit 1
fi

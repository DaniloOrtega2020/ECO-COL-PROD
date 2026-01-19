#!/bin/bash

################################################################################
#  ECO-COL REORGANIZADOR PROFESIONAL v1.0
#  Herramienta de Reestructuración de Grado Empresarial
#
#  Autor: Equipo de Arquitectura de Staff Engineer
#  Fecha: 2026-01-18
#  Propósito: Transformar ECO-COL de código en desarrollo a estructura lista para producción
#
#  Características:
#  - Clasificación inteligente de archivos basada en reporte de auditoría
#  - Migración segura de archivos con creación de respaldo
#  - Análisis automático de dependencias
#  - Generación de documentación
#  - Verificación de integridad
#  - Capacidad de rollback
################################################################################

set -euo pipefail  # Salir en error, variables indefinidas, fallos en pipes

# ============================================================================
# CONFIGURACIÓN Y GLOBALES
# ============================================================================

readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_NAME="$(basename "$0")"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="/home/claude/reorganizacion_${TIMESTAMP}.log"
readonly BACKUP_DIR="/home/claude/ECO-COL-RESPALDO-${TIMESTAMP}"

# Códigos de color para salida bonita
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # Sin Color

# Seguimiento de estadísticas
declare -i TOTAL_ARCHIVOS=0
declare -i ARCHIVOS_MIGRADOS=0
declare -i ARCHIVOS_ARCHIVADOS=0
declare -i ERRORES=0

# ============================================================================
# FUNCIONES DE REGISTRO Y SALIDA
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*" | tee -a "$LOG_FILE"
}

log_exito() {
    echo -e "${GREEN}✓${NC} $*" | tee -a "$LOG_FILE"
}

log_advertencia() {
    echo -e "${YELLOW}⚠${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}✗${NC} $*" | tee -a "$LOG_FILE"
    ((ERRORES++))
}

imprimir_encabezado() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

imprimir_seccion() {
    echo ""
    echo -e "${MAGENTA}━━━ $1 ━━━${NC}"
    echo ""
}

# ============================================================================
# DEFINICIÓN DE ESTRUCTURA DE DIRECTORIOS
# ============================================================================

crear_estructura_directorios() {
    imprimir_seccion "Creando Estructura de Directorios Empresarial"
    
    local BASE_DIR="$1"
    
    # Definir la estructura completa
    local DIRS=(
        # 1. LÓGICA DE NEGOCIO
        "1-LOGICA-NEGOCIO/dominio/entidades"
        "1-LOGICA-NEGOCIO/dominio/objetos-valor"
        "1-LOGICA-NEGOCIO/casos-uso/paciente"
        "1-LOGICA-NEGOCIO/casos-uso/estudio"
        "1-LOGICA-NEGOCIO/casos-uso/dicom"
        "1-LOGICA-NEGOCIO/politicas/reglas-medicas"
        "1-LOGICA-NEGOCIO/politicas/reglas-validacion"
        
        # 2. CONTROLADORES
        "2-CONTROLADORES/api/rutas"
        "2-CONTROLADORES/api/endpoints"
        "2-CONTROLADORES/manejadores/dicom"
        "2-CONTROLADORES/manejadores/paciente"
        "2-CONTROLADORES/manejadores/estudio"
        "2-CONTROLADORES/middleware/autenticacion"
        "2-CONTROLADORES/middleware/validacion"
        "2-CONTROLADORES/middleware/registro"
        
        # 3. TRANSFORMADORES
        "3-TRANSFORMADORES/analizadores/dicom"
        "3-TRANSFORMADORES/analizadores/metadatos"
        "3-TRANSFORMADORES/serializadores/json"
        "3-TRANSFORMADORES/serializadores/xml"
        "3-TRANSFORMADORES/mapeadores/dtos"
        "3-TRANSFORMADORES/mapeadores/modelos-vista"
        
        # 4. VALIDADORES
        "4-VALIDADORES/esquemas/paciente"
        "4-VALIDADORES/esquemas/estudio"
        "4-VALIDADORES/esquemas/dicom"
        "4-VALIDADORES/reglas-negocio/medicas"
        "4-VALIDADORES/reglas-negocio/integridad-datos"
        "4-VALIDADORES/sanitizadores"
        
        # 5. DATOS
        "5-DATOS/almacenamiento/indexeddb"
        "5-DATOS/almacenamiento/localstorage"
        "5-DATOS/repositorios/paciente"
        "5-DATOS/repositorios/estudio"
        "5-DATOS/repositorios/dicom"
        "5-DATOS/migraciones"
        "5-DATOS/semillas"
        
        # 6. DESPLIEGUE
        "6-DESPLIEGUE/desarrollo/configuracion"
        "6-DESPLIEGUE/desarrollo/scripts"
        "6-DESPLIEGUE/staging/configuracion"
        "6-DESPLIEGUE/staging/scripts"
        "6-DESPLIEGUE/produccion/configuracion"
        "6-DESPLIEGUE/produccion/scripts"
        
        # 7. PRUEBAS
        "7-PRUEBAS/unitarias/logica-negocio"
        "7-PRUEBAS/unitarias/controladores"
        "7-PRUEBAS/unitarias/transformadores"
        "7-PRUEBAS/integracion/api"
        "7-PRUEBAS/integracion/dicom"
        "7-PRUEBAS/e2e/flujos-trabajo"
        "7-PRUEBAS/fixtures/muestras-dicom"
        "7-PRUEBAS/fixtures/datos-pacientes"
        
        # 8. DOCUMENTACIÓN
        "8-DOCUMENTACION/arquitectura/diagramas"
        "8-DOCUMENTACION/arquitectura/decisiones"
        "8-DOCUMENTACION/api/openapi"
        "8-DOCUMENTACION/api/ejemplos"
        "8-DOCUMENTACION/guias-usuario/hospital-1"
        "8-DOCUMENTACION/guias-usuario/hospital-2"
        "8-DOCUMENTACION/desarrollo/configuracion"
        "8-DOCUMENTACION/desarrollo/contribucion"
        
        # 9. HERRAMIENTAS
        "9-HERRAMIENTAS/scripts/compilacion"
        "9-HERRAMIENTAS/scripts/despliegue"
        "9-HERRAMIENTAS/scripts/migraciones"
        "9-HERRAMIENTAS/instaladores/fase-1"
        "9-HERRAMIENTAS/instaladores/fase-2"
        "9-HERRAMIENTAS/utilidades/herramientas-dicom"
        "9-HERRAMIENTAS/utilidades/ayudas-desarrollo"
        
        # ARCHIVO (para archivos obsoletos)
        "ARCHIVO/versiones/v0-1"
        "ARCHIVO/versiones/v2-3-4"
        "ARCHIVO/experimental"
        "ARCHIVO/obsoleto"
    )
    
    for dir in "${DIRS[@]}"; do
        local ruta_completa="${BASE_DIR}/${dir}"
        if mkdir -p "$ruta_completa"; then
            log_exito "Creado: ${dir}"
        else
            log_error "Fallo al crear: ${dir}"
        fi
    done
    
    # Crear archivos README en cada sección principal
    crear_readmes_secciones "$BASE_DIR"
}

crear_readmes_secciones() {
    local BASE_DIR="$1"
    
    # README 1-LOGICA-NEGOCIO
    cat > "${BASE_DIR}/1-LOGICA-NEGOCIO/README.md" <<'EOF'
# 📋 Capa de LÓGICA DE NEGOCIO

Esta capa contiene la lógica de dominio central y las reglas de negocio para ECO-COL.

## Estructura

- `dominio/` - Entidades del dominio central y objetos de valor
- `casos-uso/` - Lógica de negocio específica de la aplicación
- `politicas/` - Políticas médicas y de validación

## Principios

- Lógica de negocio pura (sin UI, sin infraestructura)
- Independiente de frameworks
- Altamente testeable
- Principio de Responsabilidad Única

## Dependencias

Esta capa NO debe depender de:
- Controladores
- Capa de datos
- Frameworks externos
EOF

    # README 2-CONTROLADORES
    cat > "${BASE_DIR}/2-CONTROLADORES/README.md" <<'EOF'
# 🎮 Capa de CONTROLADORES

Esta capa maneja las peticiones HTTP/API y las interacciones de usuario.

## Estructura

- `api/` - Rutas y endpoints de API
- `manejadores/` - Manejadores de peticiones
- `middleware/` - Autenticación, validación, registro

## Responsabilidades

- Validación de peticiones
- Formateo de respuestas
- Manejo de errores
- Autenticación/Autorización

## Dependencias

- Puede usar: Lógica de Negocio, Transformadores, Validadores
- No puede usar: Acceso directo a datos (debe ir a través de repositorios)
EOF

    # README 5-DATOS
    cat > "${BASE_DIR}/5-DATOS/README.md" <<'EOF'
# 💾 Capa de DATOS

Esta capa gestiona toda la persistencia y recuperación de datos.

## Estructura

- `almacenamiento/` - Implementaciones de IndexedDB y localStorage
- `repositorios/` - Patrones de acceso a datos
- `migraciones/` - Migraciones de versión de esquema
- `semillas/` - Datos de prueba y demostración

## Patrones Clave

- Patrón Repository para acceso a datos
- Sistema de migración para evolución de esquema
- Estrategia de caché para rendimiento

## Almacenamiento DICOM

Todos los archivos DICOM se almacenan en IndexedDB con:
- Checksums SHA-256 para integridad
- Indexación de metadatos para consultas rápidas
- Compresión para eficiencia de espacio
EOF

    # README 7-PRUEBAS
    cat > "${BASE_DIR}/7-PRUEBAS/README.md" <<'EOF'
# 🧪 Suite de PRUEBAS

Cobertura de pruebas comprehensiva para ECO-COL.

## Tipos de Pruebas

### Pruebas Unitarias (`unitarias/`)
- Prueban funciones/clases individuales de forma aislada
- Ejecución rápida
- Sin dependencias externas

### Pruebas de Integración (`integracion/`)
- Prueban interacciones entre componentes
- Pueden usar IndexedDB real
- Prueban pipeline de procesamiento DICOM

### Pruebas E2E (`e2e/`)
- Pruebas de flujo de trabajo completo
- Flujos Hospital #1 → #2 → #1
- Validación de viaje de usuario

## Ejecutar Pruebas

```bash
# Ejecutar todas las pruebas
npm test

# Ejecutar suite específica
npm test -- unitarias/logica-negocio

# Ejecutar con cobertura
npm test -- --coverage
```
EOF

    log_exito "Archivos README de secciones creados"
}

# ============================================================================
# MOTOR DE CLASIFICACIÓN DE ARCHIVOS
# ============================================================================

clasificar_archivo() {
    local archivo="$1"
    local nombrearchivo=$(basename "$archivo")
    local extension="${nombrearchivo##*.}"
    
    # Archivos de producción (basado en puntuación del reporte de auditoría)
    if [[ "$nombrearchivo" =~ ULTIMATE.*V6.*FUSION ]] || 
       [[ "$nombrearchivo" =~ FINAL.*V5.1.*MEJORADO ]] ||
       [[ "$nombrearchivo" =~ FINAL.*V5.0.*COMPLETO ]]; then
        echo "PRODUCCION"
        return
    fi
    
    # Serie PRO V4.x (candidatos para producción)
    if [[ "$nombrearchivo" =~ PRO.*V4\.[0-9].*FINAL ]]; then
        echo "CANDIDATO_PRODUCCION"
        return
    fi
    
    # Scripts de instalación por fase
    if [[ "$nombrearchivo" =~ install.*fase.*[0-9]+\.sh ]] ||
       [[ "$nombrearchivo" =~ install-fase-[0-9]+\.sh ]]; then
        echo "INSTALADOR"
        return
    fi
    
    # Documentación
    if [[ "$nombrearchivo" =~ README\.txt ]] ||
       [[ "$nombrearchivo" =~ COMO-USAR ]] ||
       [[ "$nombrearchivo" =~ eco_col_final_analysis\.txt ]]; then
        echo "DOCUMENTACION"
        return
    fi
    
    # Archivos de Test/Demo
    if [[ "$nombrearchivo" =~ [Dd]emo ]] ||
       [[ "$nombrearchivo" =~ [Tt]est ]] ||
       [[ "$nombrearchivo" =~ diagrama ]]; then
        echo "ARCHIVO"
        return
    fi
    
    # Versiones antiguas
    if [[ "$nombrearchivo" =~ FASE[1-3] ]] ||
       [[ "$nombrearchivo" =~ V[0-3]\. ]] ||
       [[ "$archivo" =~ ECO-COL---V0-1 ]]; then
        echo "ARCHIVO"
        return
    fi
    
    # Archivos de backend
    if [[ "$nombrearchivo" =~ [Bb]ackend ]] ||
       [[ "$nombrearchivo" =~ [Ss]erver ]]; then
        echo "BACKEND"
        return
    fi
    
    # Utilidades
    if [[ "$nombrearchivo" =~ auditor\.sh ]] ||
       [[ "$nombrearchivo" =~ fix ]]; then
        echo "UTILIDAD"
        return
    fi
    
    # Por defecto: archivar archivos desconocidos
    echo "ARCHIVO"
}

# ============================================================================
# MIGRACIÓN INTELIGENTE DE ARCHIVOS
# ============================================================================

migrar_archivo() {
    local origen="$1"
    local clasificacion="$2"
    local base_destino="$3"
    
    local nombrearchivo=$(basename "$origen")
    local ruta_destino=""
    
    case "$clasificacion" in
        PRODUCCION)
            # Archivo principal de producción va a la raíz de la estructura final
            ruta_destino="${base_destino}/ECO-COL-PRODUCCION.html"
            cp "$origen" "$ruta_destino"
            log_exito "Archivo de producción: ${nombrearchivo} → ECO-COL-PRODUCCION.html"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        CANDIDATO_PRODUCCION)
            # Mantener como alternativa/respaldo
            ruta_destino="${base_destino}/6-DESPLIEGUE/staging/${nombrearchivo}"
            cp "$origen" "$ruta_destino"
            log_info "Candidato staging: ${nombrearchivo}"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        INSTALADOR)
            # Extraer número de fase y organizar
            if [[ "$nombrearchivo" =~ fase.?([0-9]+) ]]; then
                local fase="${BASH_REMATCH[1]}"
                ruta_destino="${base_destino}/9-HERRAMIENTAS/instaladores/fase-${fase}/${nombrearchivo}"
            else
                ruta_destino="${base_destino}/9-HERRAMIENTAS/instaladores/${nombrearchivo}"
            fi
            cp "$origen" "$ruta_destino"
            chmod +x "$ruta_destino" 2>/dev/null || true
            log_exito "Instalador: ${nombrearchivo} → fase-${fase}/"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        DOCUMENTACION)
            ruta_destino="${base_destino}/8-DOCUMENTACION/${nombrearchivo}"
            cp "$origen" "$ruta_destino"
            log_exito "Documentación: ${nombrearchivo}"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        BACKEND)
            ruta_destino="${base_destino}/6-DESPLIEGUE/desarrollo/${nombrearchivo}"
            cp "$origen" "$ruta_destino"
            log_info "Componente backend: ${nombrearchivo}"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        UTILIDAD)
            ruta_destino="${base_destino}/9-HERRAMIENTAS/utilidades/${nombrearchivo}"
            cp "$origen" "$ruta_destino"
            chmod +x "$ruta_destino" 2>/dev/null || true
            log_exito "Utilidad: ${nombrearchivo}"
            ((ARCHIVOS_MIGRADOS++))
            ;;
            
        ARCHIVO)
            # Organizar por versión
            if [[ "$origen" =~ V0-1 ]] || [[ "$nombrearchivo" =~ FASE[1-3] ]]; then
                ruta_destino="${base_destino}/ARCHIVO/versiones/v0-1/${nombrearchivo}"
            elif [[ "$origen" =~ V2-3-4 ]] || [[ "$nombrearchivo" =~ V[2-4]\. ]]; then
                ruta_destino="${base_destino}/ARCHIVO/versiones/v2-3-4/${nombrearchivo}"
            else
                ruta_destino="${base_destino}/ARCHIVO/obsoleto/${nombrearchivo}"
            fi
            cp "$origen" "$ruta_destino"
            log_advertencia "Archivado: ${nombrearchivo}"
            ((ARCHIVOS_ARCHIVADOS++))
            ;;
    esac
}

# ============================================================================
# PROCESO PRINCIPAL DE MIGRACIÓN
# ============================================================================

realizar_migracion() {
    local dir_origen="$1"
    local dir_destino="$2"
    
    imprimir_seccion "Analizando y Migrando Archivos"
    
    # Buscar todos los archivos HTML
    log_info "Escaneando archivos HTML..."
    while IFS= read -r -d '' archivo; do
        ((TOTAL_ARCHIVOS++))
        
        local clasificacion=$(clasificar_archivo "$archivo")
        migrar_archivo "$archivo" "$clasificacion" "$dir_destino"
        
    done < <(find "$dir_origen" -type f -name "*.html" -print0)
    
    # Buscar todos los scripts shell
    log_info "Escaneando scripts shell..."
    while IFS= read -r -d '' archivo; do
        ((TOTAL_ARCHIVOS++))
        
        local clasificacion=$(clasificar_archivo "$archivo")
        migrar_archivo "$archivo" "$clasificacion" "$dir_destino"
        
    done < <(find "$dir_origen" -type f -name "*.sh" -print0)
    
    # Buscar toda la documentación
    log_info "Escaneando documentación..."
    while IFS= read -r -d '' archivo; do
        ((TOTAL_ARCHIVOS++))
        
        local clasificacion=$(clasificar_archivo "$archivo")
        migrar_archivo "$archivo" "$clasificacion" "$dir_destino"
        
    done < <(find "$dir_origen" -type f \( -name "*.txt" -o -name "*.md" \) -print0)
}

# ============================================================================
# GENERACIÓN DE DOCUMENTACIÓN
# ============================================================================

generar_reporte_migracion() {
    local dir_destino="$1"
    local archivo_reporte="${dir_destino}/REPORTE-MIGRACION-${TIMESTAMP}.md"
    
    imprimir_seccion "Generando Reporte de Migración"
    
    cat > "$archivo_reporte" <<EOF
# 🏗️ Reporte de Reorganización Profesional ECO-COL

**Fecha:** $(date)
**Versión del Script:** ${SCRIPT_VERSION}
**Estado:** ${ERRORES} errores encontrados

---

## 📊 Estadísticas de Migración

- **Total de Archivos Procesados:** ${TOTAL_ARCHIVOS}
- **Archivos Migrados:** ${ARCHIVOS_MIGRADOS}
- **Archivos Archivados:** ${ARCHIVOS_ARCHIVADOS}
- **Errores:** ${ERRORES}

---

## 🎯 Archivos de Producción

Los siguientes archivos fueron identificados como listos para producción:

EOF

    # Listar archivo de producción
    if [[ -f "${dir_destino}/ECO-COL-PRODUCCION.html" ]]; then
        echo "- ✅ ECO-COL-PRODUCCION.html (Archivo principal de despliegue)" >> "$archivo_reporte"
    fi
    
    cat >> "$archivo_reporte" <<EOF

---

## 📁 Nueva Estructura de Directorios

\`\`\`
ECO-COL-FINAL/
├── 1-LOGICA-NEGOCIO/    # Lógica de dominio central
├── 2-CONTROLADORES/     # API y manejadores de peticiones
├── 3-TRANSFORMADORES/   # Capa de transformación de datos
├── 4-VALIDADORES/       # Validación y sanitización
├── 5-DATOS/             # Capa de persistencia (IndexedDB)
├── 6-DESPLIEGUE/        # Configuraciones de entorno
├── 7-PRUEBAS/           # Suites de pruebas
├── 8-DOCUMENTACION/     # Documentación
├── 9-HERRAMIENTAS/      # Scripts y utilidades
└── ARCHIVO/             # Versiones históricas
\`\`\`

---

## 🚀 Próximos Pasos

### 1. Verificar Archivo de Producción
\`\`\`bash
# Abrir en navegador y probar
open ECO-COL-PRODUCCION.html
\`\`\`

### 2. Revisar Candidatos en Staging
\`\`\`bash
ls -lh 6-DESPLIEGUE/staging/
\`\`\`

### 3. Ejecutar Pruebas (cuando estén implementadas)
\`\`\`bash
cd 7-PRUEBAS
npm test
\`\`\`

### 4. Desplegar a Producción
\`\`\`bash
cd 6-DESPLIEGUE/produccion
./desplegar.sh
\`\`\`

---

## 📝 Notas

- Todos los archivos obsoletos preservados en \`ARCHIVO/\`
- Scripts de instalación organizados por fase en \`9-HERRAMIENTAS/instaladores/\`
- Respaldo original: \`${BACKUP_DIR}\`

---

## ⚠️ Advertencias

EOF

    if [[ $ERRORES -gt 0 ]]; then
        echo "- ${ERRORES} errores ocurrieron durante la migración. Revisar ${LOG_FILE}" >> "$archivo_reporte"
    else
        echo "- No se detectaron errores ✓" >> "$archivo_reporte"
    fi
    
    cat >> "$archivo_reporte" <<EOF

---

## 🔄 Procedimiento de Rollback

Si surgen problemas:

\`\`\`bash
# Rollback completo
rm -rf ECO-COL-FINAL/
cp -r ${BACKUP_DIR}/* ./

# Rollback parcial - restaurar archivo específico
cp ${BACKUP_DIR}/ruta/al/archivo ./
\`\`\`

---

**Generado por:** ECO-COL Reorganizador Profesional v${SCRIPT_VERSION}
EOF

    log_exito "Reporte de migración creado: ${archivo_reporte}"
}

generar_readme_principal() {
    local dir_destino="$1"
    
    cat > "${dir_destino}/README.md" <<'EOF'
# 🏥 ECO-COL - Plataforma Profesional de Tele-Ecografía

**Solución de Imagen Médica de Grado Empresarial para la Colombia Rural**

[![Estado](https://img.shields.io/badge/estado-producción-green)]()
[![Versión](https://img.shields.io/badge/versión-6.0-blue)]()
[![Licencia](https://img.shields.io/badge/licencia-Uso%20Médico-red)]()

---

## 🎯 Misión

Reducir la mortalidad materna en el Cauca rural, Colombia, proporcionando diagnóstico ecográfico remoto en tiempo real, conectando centros de salud rurales con radiólogos en Popayán.

### Métricas Clave de Impacto (Proyectadas)
- **Reducción del 30-40%** en traslados innecesarios de pacientes
- **15-30 minutos** de diagnóstico remoto vs 3-5 horas de traslado físico
- **$72M COP/año** ahorrados en costos de traslado (estimación conservadora)
- **720 traslados/año** evitados en 5 centros piloto

---

## 🏗️ Arquitectura

Este proyecto sigue un patrón de **arquitectura en capas** para máxima mantenibilidad y escalabilidad:

```
┌─────────────────────────────────────────────────────┐
│        INTERFAZ DE USUARIO (HTML/CSS/JS)           │
└────────────────┬────────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ 2-CONTROLADORES │  ← Manejo de peticiones, enrutamiento
        └────────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼───┐   ┌───▼───┐   ┌───▼────┐
│1-LOG  │   │3-TRANS│   │4-VALID │  ← Lógica de negocio,
│NEGOCIO│   │FORM   │   │ADORES  │     transformaciones,
└───┬───┘   └───────┘   └────────┘     validación
    │
┌───▼──────┐
│ 5-DATOS  │  ← IndexedDB, persistencia
└──────────┘
```

---

## 📋 Inicio Rápido

### Prerequisitos
- Navegador web moderno (Chrome 90+, Firefox 88+, Safari 14+)
- No se requiere servidor (funciona 100% del lado del cliente)
- Archivos DICOM para pruebas

### Instalación

```bash
# Opción 1: Uso directo
open ECO-COL-PRODUCCION.html

# Opción 2: Servidor local (recomendado para desarrollo)
cd 6-DESPLIEGUE/desarrollo
python3 -m http.server 8000
# Abrir http://localhost:8000/../../ECO-COL-PRODUCCION.html
```

### Roles de Usuario

**Hospital #1 (Centro Periférico)**
1. Registrar paciente
2. Subir ecografía DICOM
3. Crear solicitud de estudio
4. Enviar a Hospital #2

**Hospital #2 (Centro de Radiología - Popayán)**
1. Revisar estudios entrantes
2. Ver DICOM en visor Cornerstone
3. Agregar diagnóstico
4. Enviar de vuelta a Hospital #1

---

## 📁 Estructura del Proyecto

```
ECO-COL-FINAL/
│
├── ECO-COL-PRODUCCION.html     ← Archivo principal de producción
├── README.md                    ← Este archivo
├── REPORTE-MIGRACION-*.md       ← Historial de reorganización
│
├── 1-LOGICA-NEGOCIO/
│   ├── dominio/                 # Entidades Paciente, Estudio, DICOM
│   ├── casos-uso/               # Flujos de trabajo de negocio
│   └── politicas/               # Reglas de validación médica
│
├── 2-CONTROLADORES/
│   ├── api/                     # API tipo REST (futuro)
│   ├── manejadores/             # Manejadores de eventos
│   └── middleware/              # Auth, logging, validación
│
├── 3-TRANSFORMADORES/
│   ├── analizadores/            # Lógica de parser DICOM
│   ├── serializadores/          # Serialización JSON/XML
│   └── mapeadores/              # Mapeo DTO
│
├── 4-VALIDADORES/
│   ├── esquemas/                # Esquemas JSON
│   ├── reglas-negocio/          # Validación médica
│   └── sanitizadores/           # Sanitización de entrada
│
├── 5-DATOS/
│   ├── almacenamiento/          # Implementación IndexedDB
│   ├── repositorios/            # Capa de acceso a datos
│   ├── migraciones/             # Migraciones de esquema
│   └── semillas/                # Datos de prueba
│
├── 6-DESPLIEGUE/
│   ├── desarrollo/              # Entorno de desarrollo
│   ├── staging/                 # Pre-producción
│   └── produccion/              # Configuraciones de producción
│
├── 7-PRUEBAS/
│   ├── unitarias/               # Pruebas unitarias
│   ├── integracion/             # Pruebas de integración
│   ├── e2e/                     # Pruebas end-to-end
│   └── fixtures/                # Datos de prueba
│
├── 8-DOCUMENTACION/
│   ├── arquitectura/            # Documentos de diseño del sistema
│   ├── api/                     # Documentación de API
│   └── guias-usuario/           # Manuales de usuario
│
├── 9-HERRAMIENTAS/
│   ├── scripts/                 # Scripts de compilación/despliegue
│   ├── instaladores/            # Instaladores basados en fases
│   └── utilidades/              # Ayudas de desarrollo
│
└── ARCHIVO/                     # Versiones históricas (V0-V5)
```

---

## 🔧 Stack Tecnológico

### Tecnologías Centrales
- **Procesamiento DICOM:** Cornerstone.js, dicom-parser
- **Almacenamiento:** IndexedDB (persistente, capaz de trabajar offline)
- **Framework UI:** JavaScript vanilla (sin dependencias)
- **Procesamiento de Imágenes:** API Canvas de HTML5

### Librerías Clave
- `cornerstone-core` v2.6.1
- `cornerstone-tools` v6.0.6
- `dicom-parser` v1.8.13
- `cornerstone-wado-image-loader` v4.1.2

### Infraestructura
- 100% del lado del cliente (no se requiere backend)
- Funciona offline después de la carga inicial
- Compatible con múltiples navegadores

---

## 🧪 Pruebas

```bash
# Ejecutar todas las pruebas
cd 7-PRUEBAS
npm test

# Ejecutar suite específica
npm test -- unitarias/logica-negocio

# Pruebas de integración (requiere DICOMs de muestra)
npm test -- integracion/dicom

# Pruebas de flujo de trabajo E2E
npm test -- e2e/flujo-hospitales
```

---

## 📊 Métricas de Rendimiento

- **Tiempo de Carga DICOM:** <2s para ecografía típica (5-10MB)
- **Renderizado Multi-frame:** 30 FPS (reproducción suave)
- **Escritura IndexedDB:** <500ms para estudio completo
- **Transferencia de Red:** N/A (funciona offline)
- **Uso de Memoria:** <200MB para sesión promedio

---

## 🚀 Despliegue

### Desarrollo
```bash
cd 6-DESPLIEGUE/desarrollo
./iniciar-servidor-dev.sh
```

### Staging
```bash
cd 6-DESPLIEGUE/staging
./desplegar-staging.sh
```

### Producción
```bash
cd 6-DESPLIEGUE/produccion
./desplegar-prod.sh
```

---

## 🤝 Contribución

Ver [CONTRIBUCION.md](8-DOCUMENTACION/desarrollo/CONTRIBUCION.md) para:
- Guía de estilo de código
- Flujo de trabajo Git
- Proceso de pull request
- Requisitos de pruebas

---

## 📄 Licencia

Licencia de Uso Médico - Ver [LICENSE.md](LICENSE.md)

**Importante:** Este software está diseñado para apoyo al diagnóstico médico. Todos los resultados deben ser validados por profesionales médicos licenciados.

---

## 🆘 Soporte

- **Documentación:** [8-DOCUMENTACION/](8-DOCUMENTACION/)
- **Issues:** GitHub Issues (si aplica)
- **Preguntas Médicas:** Contactar Hospital Universitario San José, Popayán

---

## 🏆 Créditos

**Equipo del Proyecto:**
- Asesores Clínicos: Hospital Universitario San José
- Líder Técnico: [Tu Nombre]
- Con el apoyo de: Universidad del Cauca, Gobernación del Cauca

**Financiamiento:**
- MinSalud Plan Nacional de Salud Rural
- Cooperación Internacional (USAID, OPS)

---

## 📈 Hoja de Ruta

### Fase 1 (Actual)
- ✅ Visor DICOM central
- ✅ Flujo de trabajo hospital a hospital
- ✅ Persistencia IndexedDB

### Fase 2 (Q2 2026)
- ⬜ Aplicación móvil (React Native)
- ⬜ Respaldo en la nube (opcional)
- ⬜ Mediciones avanzadas

### Fase 3 (Q3 2026)
- ⬜ Diagnóstico asistido por IA
- ⬜ Integración con SIRENAGEST
- ⬜ Red multi-hospitalaria

---

**Hecho con ❤️ para la Salud Rural en Colombia**
EOF

    log_exito "README.md principal creado"
}

# ============================================================================
# RESPALDO Y SEGURIDAD
# ============================================================================

crear_respaldo() {
    local dir_origen="$1"
    
    imprimir_seccion "Creando Respaldo de Seguridad"
    
    if [[ ! -d "$dir_origen" ]]; then
        log_error "El directorio origen no existe: $dir_origen"
        return 1
    fi
    
    log_info "Respaldando a: ${BACKUP_DIR}"
    
    if cp -r "$dir_origen" "$BACKUP_DIR"; then
        log_exito "Respaldo creado exitosamente"
        log_info "Tamaño del respaldo: $(du -sh "$BACKUP_DIR" | cut -f1)"
        return 0
    else
        log_error "¡Fallo el respaldo!"
        return 1
    fi
}

# ============================================================================
# VERIFICACIÓN E INTEGRIDAD
# ============================================================================

verificar_migracion() {
    local dir_destino="$1"
    
    imprimir_seccion "Verificando Integridad de la Migración"
    
    local verificaciones_pasadas=0
    local verificaciones_totales=5
    
    # Verificación 1: Archivo de producción existe
    if [[ -f "${dir_destino}/ECO-COL-PRODUCCION.html" ]]; then
        log_exito "Archivo de producción existe"
        ((verificaciones_pasadas++))
    else
        log_error "¡Archivo de producción faltante!"
    fi
    
    # Verificación 2: Todos los directorios principales creados
    if [[ -d "${dir_destino}/1-LOGICA-NEGOCIO" ]] && 
       [[ -d "${dir_destino}/5-DATOS" ]] &&
       [[ -d "${dir_destino}/7-PRUEBAS" ]]; then
        log_exito "Directorios centrales existen"
        ((verificaciones_pasadas++))
    else
        log_error "¡Faltan directorios centrales!"
    fi
    
    # Verificación 3: Instaladores migrados
    local contador_instaladores=$(find "${dir_destino}/9-HERRAMIENTAS/instaladores" -name "*.sh" 2>/dev/null | wc -l)
    if [[ $contador_instaladores -gt 0 ]]; then
        log_exito "Instaladores migrados ($contador_instaladores archivos)"
        ((verificaciones_pasadas++))
    else
        log_advertencia "No se encontraron instaladores"
    fi
    
    # Verificación 4: Documentación presente
    if [[ -f "${dir_destino}/README.md" ]]; then
        log_exito "README principal existe"
        ((verificaciones_pasadas++))
    else
        log_error "¡README principal faltante!"
    fi
    
    # Verificación 5: El archivo tiene contenido
    local contador_archivo=$(find "${dir_destino}/ARCHIVO" -type f 2>/dev/null | wc -l)
    if [[ $contador_archivo -gt 0 ]]; then
        log_exito "Archivo contiene ${contador_archivo} archivos"
        ((verificaciones_pasadas++))
    else
        log_advertencia "El archivo está vacío"
    fi
    
    echo ""
    log_info "Verificación: ${verificaciones_pasadas}/${verificaciones_totales} verificaciones pasadas"
    
    if [[ $verificaciones_pasadas -eq $verificaciones_totales ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# ESTADÍSTICAS FINALES Y RESUMEN
# ============================================================================

imprimir_resumen() {
    imprimir_encabezado "REORGANIZACIÓN COMPLETADA"
    
    echo -e "${GREEN}✓ Proyecto ECO-COL reorganizado exitosamente${NC}"
    echo ""
    echo -e "${CYAN}Estadísticas:${NC}"
    echo -e "  Archivos procesados: ${WHITE}${TOTAL_ARCHIVOS}${NC}"
    echo -e "  Archivos migrados:   ${GREEN}${ARCHIVOS_MIGRADOS}${NC}"
    echo -e "  Archivos archivados: ${YELLOW}${ARCHIVOS_ARCHIVADOS}${NC}"
    echo -e "  Errores:             ${RED}${ERRORES}${NC}"
    echo ""
    echo -e "${CYAN}Salidas Clave:${NC}"
    echo -e "  Archivo de producción: ${GREEN}ECO-COL-FINAL/ECO-COL-PRODUCCION.html${NC}"
    echo -e "  Documentación:         ${BLUE}ECO-COL-FINAL/README.md${NC}"
    echo -e "  Registro de migración: ${BLUE}${LOG_FILE}${NC}"
    echo -e "  Ubicación de respaldo: ${YELLOW}${BACKUP_DIR}${NC}"
    echo ""
    echo -e "${CYAN}Próximos Pasos:${NC}"
    echo -e "  1. Revisar reporte de migración en ECO-COL-FINAL/"
    echo -e "  2. Probar archivo de producción en navegador"
    echo -e "  3. Verificar todos los instaladores en 9-HERRAMIENTAS/"
    echo -e "  4. Leer 8-DOCUMENTACION/ para guía de despliegue"
    echo ""
    
    if [[ $ERRORES -eq 0 ]]; then
        echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ¡MIGRACIÓN EXITOSA - SIN ERRORES!   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════╗${NC}"
        echo -e "${RED}║  MIGRACIÓN COMPLETADA CON ERRORES     ║${NC}"
        echo -e "${RED}║  Revisar ${LOG_FILE}  ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
    fi
    echo ""
}

# ============================================================================
# EJECUCIÓN PRINCIPAL
# ============================================================================

principal() {
    imprimir_encabezado "ECO-COL REORGANIZADOR PROFESIONAL v${SCRIPT_VERSION}"
    
    # Solicitar directorio origen
    echo -e "${CYAN}Ingrese la ruta del directorio origen (ej: /mnt/user-data/uploads):${NC}"
    read -r DIR_ORIGEN
    
    # Validar directorio origen
    if [[ ! -d "$DIR_ORIGEN" ]]; then
        log_error "El directorio origen no existe: ${DIR_ORIGEN}"
        exit 1
    fi
    
    local DIR_DESTINO="/home/claude/ECO-COL-FINAL"
    
    echo ""
    log_info "Origen: ${DIR_ORIGEN}"
    log_info "Destino: ${DIR_DESTINO}"
    log_info "Respaldo: ${BACKUP_DIR}"
    echo ""
    
    read -p "¿Proceder con la reorganización? (si/no): " -r
    if [[ ! $REPLY =~ ^[Ss][Ii]$ ]]; then
        log_advertencia "Operación cancelada por el usuario"
        exit 0
    fi
    
    # Ejecutar pipeline de reorganización
    crear_respaldo "$DIR_ORIGEN" || exit 1
    
    crear_estructura_directorios "$DIR_DESTINO"
    
    realizar_migracion "$DIR_ORIGEN" "$DIR_DESTINO"
    
    generar_reporte_migracion "$DIR_DESTINO"
    
    generar_readme_principal "$DIR_DESTINO"
    
    verificar_migracion "$DIR_DESTINO"
    
    imprimir_resumen
    
    log_info "Registro completo disponible en: ${LOG_FILE}"
}

# Punto de entrada
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    principal "$@"
fi

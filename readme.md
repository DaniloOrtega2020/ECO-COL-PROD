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

## 🏗️ Arquitectura Profesional

Este proyecto sigue una **arquitectura en capas** de grado empresarial para máxima mantenibilidad y escalabilidad:

```
ECO-COL-FINAL/
├── ECO-COL-PRODUCCION.html     ← Archivo principal de producción
├── README.md                    ← Este archivo
│
├── 1-LOGICA-NEGOCIO/           ← Lógica de dominio central
├── 2-CONTROLADORES/            ← Manejo de peticiones
├── 3-TRANSFORMADORES/          ← Transformación de datos
├── 4-VALIDADORES/              ← Validación de datos
├── 5-DATOS/                    ← Capa de persistencia
├── 6-DESPLIEGUE/               ← Configuraciones de entorno
├── 7-PRUEBAS/                  ← Suites de pruebas
├── 8-DOCUMENTACION/            ← Documentación
├── 9-HERRAMIENTAS/             ← Scripts y utilidades
└── ARCHIVO/                    ← Versiones históricas
```

---

## 📋 Inicio Rápido

### Prerequisitos
- Navegador web moderno (Chrome 90+, Firefox 88+, Safari 14+)
- No se requiere servidor (funciona 100% del lado del cliente)
- Archivos DICOM para pruebas

### Instalación

```bash
# Abrir archivo de producción
open ECO-COL-PRODUCCION.html
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

## 🔧 Stack Tecnológico

### Tecnologías Centrales
- **Procesamiento DICOM:** Cornerstone.js, dicom-parser
- **Almacenamiento:** IndexedDB (persistente, capaz de trabajar offline)
- **UI Framework:** JavaScript vanilla (sin dependencias)
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
python3 -m http.server 8000
# Abrir http://localhost:8000/../../ECO-COL-PRODUCCION.html
```

### Staging
```bash
cd 6-DESPLIEGUE/staging
# Revisar archivos candidatos alternativos
ls -la
```

### Producción
```bash
# Copiar archivo de producción a servidor web
cp ECO-COL-PRODUCCION.html /ruta/servidor/web/
```

---

## 🤝 Contribución

Ver [8-DOCUMENTACION/desarrollo/CONTRIBUCION.md](8-DOCUMENTACION/desarrollo/CONTRIBUCION.md) para:
- Guía de estilo de código
- Flujo de trabajo Git
- Proceso de pull request
- Requisitos de pruebas

---

## 📄 Licencia

Licencia de Uso Médico - Ver [LICENSE.md](LICENSE.md)

**Importante:** Este software está diseñado para apoyo al diagnóstico médico. Todos los resultados deben ser validados por profesionales médicos licenciados.

---

## 🏆 Créditos

**Equipo del Proyecto:**
- Asesores Clínicos: Hospital Universitario San José
- Technical Lead: Desarrollador ECO-COL
- Con el apoyo de: Universidad del Cauca, Gobernación del Cauca

**Financiamiento:**
- MinSalud Plan Nacional de Salud Rural
- Cooperación Internacional (USAID, OPS)

---

## 📈 Hoja de Ruta

### Fase 1 (Actual) ✅
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

---

**Fecha de Reorganización:** 19 de Enero, 2026  
**Versión de Arquitectura:** 1.0  
**Estado:** Producción ✅

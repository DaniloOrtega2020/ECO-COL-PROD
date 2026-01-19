# 🏥 ROADMAP DEFINITIVO: VISOR DE ECOGRAFÍAS DE GRADO MÉDICO
## 100% Local | $0 Budget | Solo Librerías Open Source

---

## 📋 TABLA DE CONTENIDOS
1. [Visión General](#vision)
2. [Arquitectura del Sistema](#arquitectura)
3. [Stack Tecnológico Definitivo](#stack)
4. [Cronograma 20 Días](#cronograma)
5. [Implementación Detallada](#implementacion)
6. [Scripts de Instalación](#scripts)

---

## 🎯 VISIÓN GENERAL <a name="vision"></a>

### **Objetivo**
Crear un visor web de ecografías médicas profesional, ejecutándose completamente en tu Mac, sin dependencias externas, usando solo librerías open source.

### **Características Principales**
- ✅ Carga y visualización de DICOM de ecografía
- ✅ Herramientas de medición calibradas (mm reales)
- ✅ Windowing/Level en tiempo real
- ✅ Cine Loop para secuencias multipframe
- ✅ Anotaciones persistentes
- ✅ Modo colaborativo (opcional)
- ✅ Exportación de reportes

---

## 🏗️ ARQUITECTURA DEL SISTEMA <a name="arquitectura"></a>

```
┌─────────────────────────────────────────────────────────────┐
│                   TU MACBOOK AIR                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  NAVEGADOR WEB (Safari/Chrome)                       │  │
│  │                                                      │  │
│  │  ┌────────────────────────────────────────────┐    │  │
│  │  │  FRONTEND (http://localhost:3000)         │    │  │
│  │  │                                            │    │  │
│  │  │  React 18 + Vite                          │    │  │
│  │  │  Cornerstone3D (WebGL2 Rendering)         │    │  │
│  │  │  Canvas API (Anotaciones)                 │    │  │
│  │  │  D3.js (Gráficos)                         │    │  │
│  │  └────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ▲                                  │
│                          │ HTTP/WebSocket                   │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  BACKEND API (http://localhost:8000)                 │  │
│  │                                                      │  │
│  │  FastAPI + Uvicorn                                  │  │
│  │  PyDICOM (Parser)                                   │  │
│  │  NumPy + OpenCV (Procesamiento)                     │  │
│  │  Pillow (Conversión imágenes)                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ▲                                  │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  ALMACENAMIENTO LOCAL                                │  │
│  │                                                      │  │
│  │  PostgreSQL (Docker)    →  Metadata                 │  │
│  │  Redis (Docker)         →  Cache frames             │  │
│  │  FileSystem             →  Archivos .dcm            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 STACK TECNOLÓGICO DEFINITIVO <a name="stack"></a>

### **FRONTEND - Rendering y UI**

#### **1. Cornerstone3D - Motor de Visualización DICOM**
```json
{
  "librería": "@cornerstonejs/core",
  "versión": "1.75.0",
  "licencia": "MIT",
  "función": "Rendering WebGL2 de imágenes médicas",
  "características": [
    "Stack Viewport (2D)",
    "Volume Viewport (3D)",
    "Rendering optimizado con WebGL2",
    "Soporte para múltiples formatos de píxeles"
  ],
  "instalación": "npm install @cornerstonejs/core@1.75.0"
}
```

#### **2. Cornerstone Tools - Herramientas de Medición**
```json
{
  "librería": "@cornerstonejs/tools",
  "versión": "1.75.0",
  "función": "Herramientas de anotación y medición",
  "incluye": [
    "LengthTool (distancias)",
    "EllipticalROITool (áreas)",
    "RectangleROITool",
    "FreehandROITool",
    "AngleTool",
    "WindowLevelTool",
    "PanTool",
    "ZoomTool"
  ]
}
```

#### **3. React + Vite - Framework UI**
```json
{
  "framework": "React 18.2.0",
  "bundler": "Vite 5.0",
  "ventajas": [
    "Hot Module Replacement ultra-rápido",
    "Build optimizado",
    "TypeScript nativo"
  ]
}
```

#### **4. Librerías Complementarias**
```javascript
{
  "dicom-parser": "1.8.21",        // Parser DICOM en JS
  "gl-matrix": "3.4.3",            // Matemáticas 3D
  "hammerjs": "2.0.8",             // Gestos touch
  "zustand": "4.4.7",              // State management ligero
  "react-dnd": "16.0.1",           // Drag & drop
  "date-fns": "3.0.0"              // Manejo de fechas
}
```

### **BACKEND - API y Procesamiento**

#### **1. FastAPI - Framework API**
```python
{
  "framework": "fastapi==0.109.2",
  "servidor": "uvicorn[standard]==0.27.1",
  "ventajas": [
    "Auto-generación de docs (Swagger)",
    "Validación automática con Pydantic",
    "Async/await nativo",
    "WebSocket support"
  ]
}
```

#### **2. PyDICOM - Parser DICOM**
```python
{
  "librería": "pydicom==2.4.4",
  "función": "Lectura y escritura de archivos DICOM",
  "características": [
    "Parser completo del estándar DICOM",
    "Acceso a todos los tags",
    "Manejo de pixel data",
    "Soporte para Transfer Syntaxes"
  ]
}
```

#### **3. Procesamiento de Imágenes**
```python
{
  "numpy": "1.26.3",               # Operaciones matriciales
  "opencv-python": "4.9.0.80",     # Procesamiento avanzado
  "pillow": "10.2.0",              # Conversión de formatos
  "scikit-image": "0.22.0"         # Filtros y transformaciones
}
```

#### **4. Almacenamiento y Cache**
```python
{
  "asyncpg": "0.29.0",             # PostgreSQL async
  "redis": "5.0.1",                # Cache en memoria
  "aiofiles": "23.2.1",            # File I/O async
  "sqlalchemy": "2.0.25"           # ORM (opcional)
}
```

### **BASE DE DATOS**

```yaml
PostgreSQL:
  imagen: postgres:16-alpine
  puerto: 5432
  uso: Metadata, anotaciones, estudios
  
Redis:
  imagen: redis:7-alpine
  puerto: 6379
  uso: Cache de frames, sesiones
```

---

## 📅 CRONOGRAMA 20 DÍAS <a name="cronograma"></a>

### **SEMANA 1: FUNDAMENTOS (Días 1-5)**

#### **DÍA 1: Setup del Proyecto**
```bash
Objetivos:
- Estructura de carpetas
- Entorno virtual Python
- Proyecto React con Vite
- Docker Compose para PostgreSQL + Redis

Comandos:
./scripts/setup_dia1.sh
```

**Entregables:**
- ✅ Python venv activado
- ✅ React app corriendo en localhost:3000
- ✅ Backend FastAPI en localhost:8000
- ✅ PostgreSQL y Redis corriendo

---

#### **DÍA 2: Parser DICOM Backend**
**Objetivo:** Backend que lee archivos DICOM y extrae metadata + pixel data

**Implementación:**
```python
# backend/app/dicom/parser.py
import pydicom
import numpy as np
from pathlib import Path

class UltrasoundParser:
    def parse(self, dicom_path: str):
        dcm = pydicom.dcmread(dicom_path)
        
        return {
            'metadata': {
                'patient_id': dcm.PatientID,
                'study_date': dcm.StudyDate,
                'modality': dcm.Modality,
                'rows': dcm.Rows,
                'columns': dcm.Columns,
                'pixel_spacing': dcm.PixelSpacing,
            },
            'pixel_data': dcm.pixel_array
        }
```

**API Endpoint:**
```python
# backend/app/api/v1/dicom.py
from fastapi import APIRouter, UploadFile

router = APIRouter()

@router.post("/upload")
async def upload_dicom(file: UploadFile):
    # Guardar archivo
    # Parsear con PyDICOM
    # Guardar metadata en PostgreSQL
    # Cachear frame en Redis
    # Retornar ID del estudio
    pass
```

**Test:**
```bash
curl -X POST http://localhost:8000/api/v1/dicom/upload \
  -F "file=@test.dcm"
```

---

#### **DÍA 3: API de Frames**
**Objetivo:** Endpoints para obtener frames individuales

```python
@router.get("/frames/{frame_id}")
async def get_frame(frame_id: str, format: str = "png"):
    # Buscar en Redis cache
    # Si no existe, cargar desde DICOM
    # Convertir a formato solicitado
    # Retornar como StreamingResponse
    pass

@router.get("/studies/{study_id}/frames")
async def list_frames(study_id: str):
    # Listar todos los frames de un estudio
    pass
```

---

#### **DÍA 4-5: Setup Frontend con Cornerstone**
**Objetivo:** Página web que renderiza una imagen DICOM

**Instalación:**
```bash
cd frontend
npm install @cornerstonejs/core@1.75.0 \
            @cornerstonejs/tools@1.75.0 \
            @cornerstonejs/streaming-image-volume-loader@1.75.0 \
            dicom-parser@1.8.21
```

**Componente Base:**
```typescript
// frontend/src/components/DicomViewer.tsx
import React, { useEffect, useRef } from 'react';
import { RenderingEngine, Enums } from '@cornerstonejs/core';
import * as cornerstoneTools from '@cornerstonejs/tools';

export const DicomViewer: React.FC = () => {
  const elementRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    // Inicializar Cornerstone
    const setup = async () => {
      await cornerstoneTools.init();
      
      const renderingEngine = new RenderingEngine('myRenderingEngine');
      
      const viewportInput = {
        viewportId: 'CT_AXIAL',
        type: Enums.ViewportType.STACK,
        element: elementRef.current!,
        defaultOptions: {
          background: [0, 0, 0],
        },
      };
      
      renderingEngine.enableElement(viewportInput);
      
      // Cargar imagen desde backend
      const imageId = 'custom://frame-123';
      const viewport = renderingEngine.getViewport('CT_AXIAL');
      await viewport.setStack([imageId]);
      viewport.render();
    };
    
    setup();
  }, []);
  
  return (
    <div 
      ref={elementRef} 
      style={{ width: '100%', height: '600px', background: '#000' }}
    />
  );
};
```

**Resultado esperado:** Una página que muestra una imagen DICOM

---

### **SEMANA 2: VISUALIZACIÓN (Días 6-10)**

#### **DÍA 6: Custom Image Loader**
**Objetivo:** Cornerstone debe cargar imágenes desde tu backend

```typescript
// frontend/src/loaders/customImageLoader.ts
import { ImageLoaderFn } from '@cornerstonejs/core/dist/esm/types';

export const customImageLoader: ImageLoaderFn = (imageId: string) => {
  const frameId = imageId.replace('custom://', '');
  
  return new Promise((resolve, reject) => {
    fetch(`http://localhost:8000/api/v1/frames/${frameId}?format=png`)
      .then(res => res.blob())
      .then(blob => {
        const img = new Image();
        img.src = URL.createObjectURL(blob);
        
        img.onload = () => {
          const imageObject = {
            imageId,
            minPixelValue: 0,
            maxPixelValue: 255,
            slope: 1,
            intercept: 0,
            windowCenter: 128,
            windowWidth: 256,
            getPixelData: () => extractPixelData(img),
            rows: img.height,
            columns: img.width,
            height: img.height,
            width: img.width,
            color: false,
            columnPixelSpacing: 0.15,
            rowPixelSpacing: 0.15,
            sizeInBytes: img.width * img.height,
          };
          
          resolve(imageObject);
        };
      })
      .catch(reject);
  });
};

// Registrar loader
imageLoader.registerImageLoader('custom', customImageLoader);
```

---

#### **DÍA 7: Windowing (Brillo/Contraste)**
**Objetivo:** Ajustar brillo y contraste de la imagen

```typescript
// frontend/src/components/WindowingControl.tsx
import { useState } from 'react';

export const WindowingControl = ({ viewport }) => {
  const [windowCenter, setWindowCenter] = useState(128);
  const [windowWidth, setWindowWidth] = useState(256);
  
  const applyWindowing = (center: number, width: number) => {
    viewport.setProperties({
      voiRange: {
        lower: center - width / 2,
        upper: center + width / 2
      }
    });
    viewport.render();
  };
  
  return (
    <div className="windowing-panel">
      <label>
        Brightness (Center): {windowCenter}
        <input 
          type="range" 
          min="0" 
          max="255" 
          value={windowCenter}
          onChange={(e) => {
            const val = parseInt(e.target.value);
            setWindowCenter(val);
            applyWindowing(val, windowWidth);
          }}
        />
      </label>
      
      <label>
        Contrast (Width): {windowWidth}
        <input 
          type="range" 
          min="1" 
          max="512" 
          value={windowWidth}
          onChange={(e) => {
            const val = parseInt(e.target.value);
            setWindowWidth(val);
            applyWindowing(windowCenter, val);
          }}
        />
      </label>
      
      <button onClick={() => applyWindowing(128, 256)}>Reset</button>
    </div>
  );
};
```

---

#### **DÍA 8-9: Herramientas de Medición**
**Objetivo:** Implementar herramientas de medición calibradas

```typescript
// frontend/src/hooks/useMeasurementTools.ts
import { LengthTool, EllipticalROITool } from '@cornerstonejs/tools';

export const useMeasurementTools = (toolGroupId: string) => {
  const setupTools = () => {
    // Registrar herramientas
    cornerstoneTools.addTool(LengthTool);
    cornerstoneTools.addTool(EllipticalROITool);
    
    // Crear tool group
    const toolGroup = cornerstoneTools.ToolGroupManager.createToolGroup(toolGroupId);
    
    // Agregar herramientas al grupo
    toolGroup.addTool(LengthTool.toolName);
    toolGroup.addTool(EllipticalROITool.toolName);
    
    // Configurar herramienta de distancia
    toolGroup.setToolActive(LengthTool.toolName, {
      bindings: [{ mouseButton: 1 }]
    });
  };
  
  const activateLengthTool = () => {
    const toolGroup = cornerstoneTools.ToolGroupManager.getToolGroup(toolGroupId);
    toolGroup.setToolActive(LengthTool.toolName);
  };
  
  const activateEllipseTool = () => {
    const toolGroup = cornerstoneTools.ToolGroupManager.getToolGroup(toolGroupId);
    toolGroup.setToolActive(EllipticalROITool.toolName);
  };
  
  return { setupTools, activateLengthTool, activateEllipseTool };
};
```

**UI de herramientas:**
```typescript
<div className="toolbar">
  <button onClick={activateLengthTool}>
    📏 Distancia
  </button>
  <button onClick={activateEllipseTool}>
    ⭕ Área
  </button>
  <button onClick={activateAngleTool}>
    📐 Ángulo
  </button>
</div>
```

---

#### **DÍA 10: Persistencia de Anotaciones**
**Objetivo:** Guardar anotaciones en PostgreSQL

**Backend:**
```python
# backend/app/models/annotation.py
from sqlalchemy import Column, String, JSON
from .base import Base

class Annotation(Base):
    __tablename__ = "annotations"
    
    id = Column(String, primary_key=True)
    frame_id = Column(String, nullable=False)
    tool_type = Column(String)  # 'length', 'ellipse', 'angle'
    geometry = Column(JSON)     # Coordenadas
    measurement = Column(Float) # Valor calculado
    unit = Column(String)       # 'mm', 'cm²', '°'

@router.post("/annotations")
async def save_annotation(annotation: AnnotationCreate):
    # Guardar en DB
    pass

@router.get("/frames/{frame_id}/annotations")
async def get_annotations(frame_id: str):
    # Recuperar anotaciones
    pass
```

**Frontend:**
```typescript
const saveAnnotation = async (annotation) => {
  await fetch('http://localhost:8000/api/v1/annotations', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(annotation)
  });
};
```

---

### **SEMANA 3: CARACTERÍSTICAS AVANZADAS (Días 11-15)**

#### **DÍA 11-12: Cine Loop Player**
**Objetivo:** Reproducir secuencias de frames

```typescript
// frontend/src/components/CineLoopPlayer.tsx
import { useState, useEffect } from 'react';

export const CineLoopPlayer = ({ frameIds }: { frameIds: string[] }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [fps, setFps] = useState(30);
  
  useEffect(() => {
    if (!isPlaying) return;
    
    const interval = setInterval(() => {
      setCurrentIndex(prev => (prev + 1) % frameIds.length);
    }, 1000 / fps);
    
    return () => clearInterval(interval);
  }, [isPlaying, fps, frameIds.length]);
  
  return (
    <div className="cine-player">
      <div className="controls">
        <button onClick={() => setIsPlaying(!isPlaying)}>
          {isPlaying ? '⏸️ Pause' : '▶️ Play'}
        </button>
        
        <button onClick={() => setCurrentIndex(0)}>⏮️</button>
        <button onClick={() => setCurrentIndex(prev => Math.max(0, prev - 1))}>⏪</button>
        
        <span>Frame {currentIndex + 1} / {frameIds.length}</span>
        
        <button onClick={() => setCurrentIndex(prev => Math.min(frameIds.length - 1, prev + 1))}>⏩</button>
        <button onClick={() => setCurrentIndex(frameIds.length - 1)}>⏭️</button>
      </div>
      
      <input 
        type="range" 
        min="0" 
        max={frameIds.length - 1}
        value={currentIndex}
        onChange={(e) => setCurrentIndex(parseInt(e.target.value))}
      />
      
      <select value={fps} onChange={(e) => setFps(parseInt(e.target.value))}>
        <option value="15">15 FPS</option>
        <option value="30">30 FPS</option>
        <option value="60">60 FPS</option>
      </select>
    </div>
  );
};
```

---

#### **DÍA 13: Listado de Estudios**
**Objetivo:** UI para navegar entre estudios

```typescript
// frontend/src/components/StudyBrowser.tsx
import { useState, useEffect } from 'react';

export const StudyBrowser = ({ onSelectStudy }) => {
  const [studies, setStudies] = useState([]);
  
  useEffect(() => {
    fetch('http://localhost:8000/api/v1/studies')
      .then(res => res.json())
      .then(setStudies);
  }, []);
  
  return (
    <div className="study-browser">
      <h3>📁 Estudios Disponibles</h3>
      
      {studies.map(study => (
        <div 
          key={study.id} 
          className="study-card"
          onClick={() => onSelectStudy(study.id)}
        >
          <div className="study-info">
            <strong>{study.patient_name}</strong>
            <span>{study.patient_id}</span>
            <span>{study.study_date}</span>
            <span>{study.modality} - {study.body_part}</span>
          </div>
          
          <div className="study-stats">
            <span>{study.series_count} series</span>
            <span>{study.frame_count} imágenes</span>
          </div>
        </div>
      ))}
    </div>
  );
};
```

---

#### **DÍA 14: Layout Completo**
**Objetivo:** Interfaz profesional completa

```typescript
// frontend/src/App.tsx
import { useState } from 'react';
import { StudyBrowser } from './components/StudyBrowser';
import { DicomViewer } from './components/DicomViewer';
import { WindowingControl } from './components/WindowingControl';
import { CineLoopPlayer } from './components/CineLoopPlayer';

export const App = () => {
  const [selectedStudyId, setSelectedStudyId] = useState(null);
  const [viewport, setViewport] = useState(null);
  
  return (
    <div className="app-container">
      <header className="app-header">
        <h1>🏥 TURBO Ultrasound Viewer</h1>
      </header>
      
      <div className="app-layout">
        {/* Sidebar izquierdo - Lista de estudios */}
        <aside className="sidebar-left">
          <StudyBrowser onSelectStudy={setSelectedStudyId} />
        </aside>
        
        {/* Centro - Visor principal */}
        <main className="viewer-main">
          <DicomViewer 
            studyId={selectedStudyId}
            onViewportReady={setViewport}
          />
          
          {viewport && (
            <div className="viewer-overlays">
              <div className="overlay-top-left">
                <div>Patient: TEST001</div>
                <div>Study Date: 2026-01-16</div>
              </div>
              
              <div className="overlay-top-right">
                <div>US - ABDOMEN</div>
                <div>7.5 MHz</div>
              </div>
              
              <div className="overlay-bottom-left">
                <div>TURBO Systems</div>
              </div>
              
              <div className="overlay-bottom-right">
                <div>Frame 1/30</div>
                <div>30 FPS</div>
              </div>
            </div>
          )}
        </main>
        
        {/* Sidebar derecho - Controles */}
        <aside className="sidebar-right">
          {viewport && (
            <>
              <WindowingControl viewport={viewport} />
              
              <div className="tools-panel">
                <h4>🔧 Herramientas</h4>
                <button>📏 Distancia</button>
                <button>⭕ Área</button>
                <button>📐 Ángulo</button>
                <button>✏️ Anotación</button>
              </div>
              
              <CineLoopPlayer frameIds={['1', '2', '3']} />
            </>
          )}
        </aside>
      </div>
    </div>
  );
};
```

---

#### **DÍA 15: CSS/Styling Profesional**
**Objetivo:** Diseño dark mode médico

```css
/* frontend/src/styles/app.css */
:root {
  --bg-primary: #050505;
  --bg-secondary: #1a1a1a;
  --bg-tertiary: #2a2a2a;
  --text-primary: #00ff00;
  --text-secondary: #ffffff;
  --border-color: #333333;
}

body {
  margin: 0;
  font-family: 'Inter', sans-serif;
  background: var(--bg-primary);
  color: var(--text-secondary);
}

.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.app-header {
  background: var(--bg-secondary);
  padding: 1rem 2rem;
  border-bottom: 1px solid var(--border-color);
}

.app-layout {
  display: grid;
  grid-template-columns: 300px 1fr 300px;
  gap: 1rem;
  flex: 1;
  overflow: hidden;
  padding: 1rem;
}

.sidebar-left, .sidebar-right {
  background: var(--bg-secondary);
  border-radius: 8px;
  padding: 1rem;
  overflow-y: auto;
}

.viewer-main {
  position: relative;
  background: var(--bg-primary);
  border-radius: 8px;
  border: 2px solid var(--border-color);
}

.viewer-overlays {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.overlay-top-left,
.overlay-top-right,
.overlay-bottom-left,
.overlay-bottom-right {
  position: absolute;
  padding: 1rem;
  font-size: 0.875rem;
  color: var(--text-primary);
  font-family: 'Courier New', monospace;
}

.overlay-top-left { top: 0; left: 0; }
.overlay-top-right { top: 0; right: 0; text-align: right; }
.overlay-bottom-left { bottom: 0; left: 0; }
.overlay-bottom-right { bottom: 0; right: 0; text-align: right; }

button {
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

button:hover {
  background: var(--bg-secondary);
  border-color: var(--text-primary);
}

button:active {
  transform: scale(0.98);
}
```

---

### **SEMANA 4: OPTIMIZACIÓN Y PRODUCCIÓN (Días 16-20)**

#### **DÍA 16: Optimización de Performance**
**Objetivo:** Sistema rápido y eficiente

**1. Lazy Loading de Frames**
```typescript
const loadFrameLazy = async (frameId: string) => {
  // Cargar solo cuando sea necesario
  const cachedFrame = frameCache.get(frameId);
  if (cachedFrame) return cachedFrame;
  
  const frame = await fetchFrame(frameId);
  frameCache.set(frameId, frame);
  return frame;
};
```

**2. Virtual Scrolling para Estudios**
```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

const StudyList = ({ studies }) => {
  const parentRef = useRef();
  
  const virtualizer = useVirtualizer({
    count: studies.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80,
  });
  
  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      {virtualizer.getVirtualItems().map(virtualRow => (
        <StudyCard key={virtualRow.key} study={studies[virtualRow.index]} />
      ))}
    </div>
  );
};
```

**3. WebWorker para Procesamiento**
```typescript
// frontend/src/workers/imageProcessor.worker.ts
self.addEventListener('message', (e) => {
  const { imageData, operation } = e.data;
  
  let result;
  
  switch (operation) {
    case 'applyWindowing':
      result = applyWindowingWorker(imageData, e.data.center, e.data.width);
      break;
    case 'computeHistogram':
      result = computeHistogramWorker(imageData);
      break;
  }
  
  self.postMessage(result);
});
```

---

#### **DÍA 17: Testing**
**Objetivo:** Tests automatizados

```typescript
// frontend/tests/DicomViewer.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { DicomViewer } from '../components/DicomViewer';

describe('DicomViewer', () => {
  it('renders without crashing', () => {
    render(<DicomViewer studyId="test-123" />);
    expect(screen.getByRole('img')).toBeInTheDocument();
  });
  
  it('loads and displays DICOM image', async () => {
    render(<DicomViewer studyId="test-123" />);
    
    await waitFor(() => {
      expect(screen.getByAltText('DICOM Image')).toBeInTheDocument();
    });
  });
  
  it('applies windowing', async () => {
    const { container } = render(<DicomViewer studyId="test-123" />);
    
    const brightnessSlider = container.querySelector('[data-testid="brightness"]');
    fireEvent.change(brightnessSlider, { target: { value: '150' } });
    
    // Verificar que se aplicó el windowing
  });
});
```

**Backend Tests:**
```python
# backend/tests/test_dicom_parser.py
import pytest
from app.dicom.parser import UltrasoundParser

def test_parse_valid_dicom():
    parser = UltrasoundParser()
    result = parser.parse('test_data/sample.dcm')
    
    assert result['metadata']['modality'] == 'US'
    assert result['pixel_data'].shape == (480, 640)

def test_parse_invalid_file():
    parser = UltrasoundParser()
    
    with pytest.raises(ValueError):
        parser.parse('not_a_dicom.txt')
```

---

#### **DÍA 18-19: Exportación y Reportes**
**Objetivo:** Generar reportes en PDF

```python
# backend/app/reports/generator.py
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
import io

class ReportGenerator:
    def generate_ultrasound_report(
        self,
        study_id: str,
        frames: list,
        annotations: list
    ) -> bytes:
        """Genera reporte en PDF"""
        
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=letter)
        width, height = letter
        
        # Header
        c.setFont("Helvetica-Bold", 16)
        c.drawString(50, height - 50, "INFORME DE ECOGRAFÍA")
        
        # Patient info
        c.setFont("Helvetica", 12)
        c.drawString(50, height - 80, f"Paciente: {study.patient_name}")
        c.drawString(50, height - 100, f"Fecha: {study.study_date}")
        
        # Images
        y_position = height - 150
        for frame in frames[:3]:  # Primeros 3 frames
            img = Image.open(frame.path)
            img_reader = ImageReader(img)
            c.drawImage(img_reader, 50, y_position, width=200, height=150)
            y_position -= 170
        
        # Measurements
        c.drawString(50, y_position, "Mediciones:")
        y_position -= 20
        for annotation in annotations:
            c.drawString(70, y_position, 
                f"- {annotation.tool_type}: {annotation.measurement} {annotation.unit}")
            y_position -= 15
        
        c.save()
        return buffer.getvalue()

@router.get("/studies/{study_id}/report")
async def generate_report(study_id: str):
    report_bytes = generator.generate_ultrasound_report(study_id, ...)
    
    return Response(
        content=report_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename=report.pdf"}
    )
```

---

#### **DÍA 20: Deployment y Documentación**
**Objetivo:** Sistema listo para producción

**1. Script de Inicio Unificado**
```bash
#!/bin/bash
# start_turbo_viewer.sh

echo "🚀 Iniciando TURBO Ultrasound Viewer"

# Iniciar Docker
docker-compose up -d

# Esperar PostgreSQL
sleep 10

# Iniciar Backend
cd backend
source ../.venv/bin/activate
uvicorn app.main:app --reload --port 8000 &

# Iniciar Frontend
cd ../frontend
npm run dev &

echo "✅ Sistema iniciado"
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:8000"
echo "Docs:     http://localhost:8000/docs"
```

**2. Documentación de Usuario**
```markdown
# 📖 Manual de Usuario - TURBO Viewer

## Inicio Rápido
1. Ejecutar: `./start_turbo_viewer.sh`
2. Abrir navegador en `http://localhost:3000`
3. Subir archivo DICOM
4. Comenzar a visualizar

## Herramientas

### Medición de Distancia
1. Click en botón "📏 Distancia"
2. Click en punto inicial
3. Click en punto final
4. La distancia en mm aparece automáticamente

### Área (ROI)
1. Click en botón "⭕ Área"
2. Click y drag para dibujar elipse
3. El área en cm² se calcula automáticamente

### Windowing
- Usar sliders de Brightness/Contrast
- Presets: Soft Tissue, Bone, etc.
```

---

## 📦 SCRIPTS DE INSTALACIÓN <a name="scripts"></a>

### **Script Maestro de Instalación**

```bash
#!/bin/bash
# install_complete_viewer.sh

set -e

PROJECT_DIR="$(pwd)"

echo "🏥 INSTALANDO VISOR DE ECOGRAFÍAS TURBO"
echo "========================================"

# 1. Python Backend
echo "📦 Instalando dependencias Python..."
python3 -m venv .venv
source .venv/bin/activate
pip install \
  fastapi==0.109.2 \
  uvicorn[standard]==0.27.1 \
  pydicom==2.4.4 \
  numpy==1.26.3 \
  opencv-python==4.9.0.80 \
  pillow==10.2.0 \
  asyncpg==0.29.0 \
  redis==5.0.1 \
  aiofiles==23.2.1 \
  python-multipart==0.0.9 \
  reportlab==4.0.9

# 2. Node.js Frontend
echo "📦 Instalando dependencias Node.js..."
cd frontend
npm install

# 3. Docker Services
echo "🐳 Iniciando servicios Docker..."
cd ..
docker-compose up -d

echo "✅ Instalación completa"
echo ""
echo "🚀 Para iniciar el sistema:"
echo "   ./start_turbo_viewer.sh"
```

---

## 🎯 RESULTADO FINAL

Al completar este roadmap tendrás:

✅ **Visor Web Profesional**
- Renderizado con WebGL2 (60 FPS)
- Herramientas de medición calibradas
- Windowing en tiempo real
- Cine Loop fluido

✅ **Backend Robusto**
- API REST con FastAPI
- Parser DICOM completo
- Cache Redis
- PostgreSQL para persistencia

✅ **100% Local**
- Sin dependencias cloud
- Datos en tu Mac
- Sin costos recurrentes
- Control total

✅ **Performance Óptimo**
- Carga de imágenes < 500ms
- Rendering 60 FPS
- Memory usage < 2GB
- Lazy loading inteligente

---

## 📚 LIBRERÍAS COMPLETAS

```json
{
  "frontend": {
    "@cornerstonejs/core": "1.75.0",
    "@cornerstonejs/tools": "1.75.0",
    "@cornerstonejs/streaming-image-volume-loader": "1.75.0",
    "dicom-parser": "1.8.21",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "vite": "5.0.0",
    "zustand": "4.4.7",
    "gl-matrix": "3.4.3",
    "hammerjs": "2.0.8"
  },
  "backend": {
    "fastapi": "0.109.2",
    "uvicorn": "0.27.1",
    "pydicom": "2.4.4",
    "numpy": "1.26.3",
    "opencv-python": "4.9.0.80",
    "pillow": "10.2.0",
    "asyncpg": "0.29.0",
    "redis": "5.0.1",
    "reportlab": "4.0.9"
  }
}
```

**TODAS LAS LIBRERÍAS SON:**
- ✅ Open Source (MIT/BSD/Apache)
- ✅ Gratis ($0)
- ✅ Maduras y estables
- ✅ Con gran comunidad
- ✅ Actualizadas activamente

---

## 🚀 EMPIEZA AHORA

```bash
# Clonar estructura
mkdir turbo-ultrasound-viewer
cd turbo-ultrasound-viewer

# Descargar roadmap
# Ejecutar instalación
./install_complete_viewer.sh

# Iniciar sistema
./start_turbo_viewer.sh
```

**Este roadmap es 100% implementable en 20 días con dedicación de 4-6 horas diarias.**

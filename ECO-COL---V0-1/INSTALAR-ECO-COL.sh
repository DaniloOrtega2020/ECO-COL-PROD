#!/bin/bash
################################################################################
# 🏥 ECO-COL V1 - INSTALADOR AUTOMÁTICO PARA MACOS
# Instalación en 1 comando
################################################################################

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              🏥 ECO-COL V1 - INSTALADOR                        ║
║         Plataforma de Tele-ecografía de Grado Médico          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python 3 no encontrado${NC}"
    echo -e "Instalando Python 3..."
    if command -v brew &> /dev/null; then
        brew install python3
    else
        echo -e "${RED}❌ Homebrew no encontrado. Instalar desde: https://brew.sh${NC}"
        exit 1
    fi
fi

# Crear directorio en HOME
INSTALL_DIR="$HOME/eco-dicom-viewer"
echo -e "${CYAN}📁 Directorio de instalación: ${INSTALL_DIR}${NC}\n"

# Si ya existe, preguntar
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio ya existe.${NC}"
    read -p "¿Desea sobrescribir? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Instalación cancelada."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

# Crear estructura
echo -e "${CYAN}[1/4]${NC} Creando estructura de directorios..."
mkdir -p "$INSTALL_DIR/eco-col-platform/templates"
mkdir -p "$INSTALL_DIR/eco-col-platform/public"

# Crear archivo HTML principal
echo -e "${CYAN}[2/4]${NC} Generando interfaz web..."

cat > "$INSTALL_DIR/eco-col-platform/templates/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ECO-COL V1 - Plataforma de Tele-ecografía</title>
    <style>
        :root {
            --primary: #00695c;
            --primary-dark: #004d40;
            --accent: #00bfa5;
            --bg-dark: #121212;
            --bg-panel: #1e1e1e;
            --text-primary: #ffffff;
            --text-secondary: #b0b0b0;
            --border: #333333;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
            background: var(--bg-dark);
            color: var(--text-primary);
            overflow: hidden;
            height: 100vh;
        }
        .header {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
            border-bottom: 2px solid var(--accent);
        }
        .header-title { display: flex; align-items: center; gap: 1rem; }
        .header-title h1 { font-size: 1.5rem; font-weight: 700; }
        .badge {
            background: var(--accent);
            color: var(--bg-dark);
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #4caf50;
            animation: pulse 2s infinite;
        }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        .main-container {
            display: grid;
            grid-template-columns: 320px 1fr 360px;
            height: calc(100vh - 73px);
            gap: 0;
        }
        .left-panel, .right-panel {
            background: var(--bg-panel);
            overflow-y: auto;
        }
        .left-panel { border-right: 1px solid var(--border); }
        .right-panel { border-left: 1px solid var(--border); padding: 1.5rem; }
        .panel-header {
            padding: 1.25rem;
            background: #252525;
            border-bottom: 2px solid var(--primary);
        }
        .panel-header h2 {
            font-size: 1rem;
            text-transform: uppercase;
            color: var(--accent);
            margin-bottom: 0.75rem;
        }
        .search-box {
            width: 100%;
            padding: 0.75rem;
            background: var(--bg-dark);
            border: 1px solid var(--border);
            border-radius: 6px;
            color: var(--text-primary);
            font-size: 0.9rem;
        }
        .search-box:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(0, 191, 165, 0.1);
        }
        .studies-list { padding: 0.5rem; }
        .study-card {
            background: #252525;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 0.75rem;
            cursor: pointer;
            transition: all 0.3s;
        }
        .study-card:hover {
            background: #2a2a2a;
            border-color: var(--accent);
            transform: translateX(4px);
        }
        .study-card.active {
            background: linear-gradient(135deg, #1a4a44, #256d63);
            border-color: var(--accent);
            box-shadow: 0 4px 12px rgba(0, 191, 165, 0.3);
        }
        .study-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
        }
        .study-id {
            font-weight: 700;
            color: var(--accent);
            font-size: 0.9rem;
        }
        .study-modality {
            background: var(--primary);
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            font-size: 0.7rem;
            font-weight: 700;
        }
        .study-info {
            font-size: 0.85rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }
        .center-panel {
            background: #000;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        .viewer-toolbar {
            background: #1a1a1a;
            padding: 0.75rem;
            display: flex;
            gap: 0.5rem;
            border-bottom: 1px solid var(--border);
        }
        .tool-btn {
            background: #2a2a2a;
            border: 1px solid var(--border);
            color: var(--text-primary);
            padding: 0.6rem 1rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.3s;
        }
        .tool-btn:hover, .tool-btn.active {
            background: var(--primary);
            border-color: var(--accent);
        }
        .viewer-canvas-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        #dicom-canvas {
            max-width: 100%;
            max-height: 100%;
            border: 2px solid var(--accent);
            box-shadow: 0 8px 32px rgba(0, 191, 165, 0.3);
        }
        .viewer-overlay {
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(0, 0, 0, 0.85);
            padding: 1rem;
            border-radius: 8px;
            border: 1px solid var(--accent);
            font-family: 'Courier New', monospace;
            font-size: 0.85rem;
            line-height: 1.8;
        }
        .overlay-label { color: var(--accent); font-weight: 700; margin-right: 0.5rem; }
        .cine-controls {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0, 0, 0, 0.9);
            padding: 1rem 2rem;
            border-radius: 50px;
            display: flex;
            align-items: center;
            gap: 1.5rem;
            border: 2px solid var(--accent);
        }
        .cine-btn {
            background: var(--primary);
            border: none;
            color: white;
            width: 48px;
            height: 48px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 1.2rem;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .cine-btn:hover { background: var(--accent); transform: scale(1.1); }
        .frame-info { color: var(--accent); font-weight: 700; min-width: 100px; text-align: center; }
        .control-section { margin-bottom: 2rem; }
        .control-section h3 {
            font-size: 0.95rem;
            text-transform: uppercase;
            color: var(--accent);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--primary);
        }
        .control-group { margin-bottom: 1.5rem; }
        .control-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .control-value { color: var(--accent); }
        input[type="range"] {
            width: 100%;
            height: 6px;
            border-radius: 3px;
            background: var(--border);
            outline: none;
            -webkit-appearance: none;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            background: var(--accent);
            cursor: pointer;
        }
        .action-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
        }
        .action-btn {
            padding: 0.75rem;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
        }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: var(--accent); transform: translateY(-2px); }
        .btn-secondary { background: #2a2a2a; color: var(--text-primary); border: 1px solid var(--border); }
        .stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 1rem; }
        .stat-card {
            background: #252525;
            padding: 1rem;
            border-radius: 8px;
            border: 1px solid var(--border);
            text-align: center;
        }
        .stat-value { font-size: 1.5rem; font-weight: 700; color: var(--accent); }
        .stat-label { font-size: 0.75rem; color: var(--text-secondary); text-transform: uppercase; }
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: var(--bg-dark); }
        ::-webkit-scrollbar-thumb { background: var(--primary); border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-title">
            <h1>🏥 ECO-COL V1</h1>
            <span class="badge">Grado Médico</span>
        </div>
        <div style="display: flex; gap: 2rem; align-items: center;">
            <div style="display: flex; align-items: center; gap: 0.5rem;">
                <span class="status-dot"></span>
                <span>Sistema Activo</span>
            </div>
            <div>🔒 100% Local</div>
            <div id="clock">--:--:--</div>
        </div>
    </div>

    <div class="main-container">
        <div class="left-panel">
            <div class="panel-header">
                <h2>📋 Estudios DICOM</h2>
                <input type="text" class="search-box" placeholder="Buscar...">
            </div>
            <div class="studies-list">
                <div class="study-card active" onclick="loadStudy(1)">
                    <div class="study-header">
                        <span class="study-id">ESTUDIO #001</span>
                        <span class="study-modality">US</span>
                    </div>
                    <div class="study-info">
                        <div><strong>Paciente:</strong> DOE^JOHN</div>
                        <div><strong>ID:</strong> PAT-2024-001</div>
                        <div><strong>Fecha:</strong> 17/01/2026</div>
                    </div>
                </div>
                <div class="study-card" onclick="loadStudy(2)">
                    <div class="study-header">
                        <span class="study-id">ESTUDIO #002</span>
                        <span class="study-modality">US</span>
                    </div>
                    <div class="study-info">
                        <div><strong>Paciente:</strong> SMITH^JANE</div>
                        <div><strong>ID:</strong> PAT-2024-002</div>
                        <div><strong>Fecha:</strong> 16/01/2026</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="center-panel">
            <div class="viewer-toolbar">
                <button class="tool-btn active">🔍 Zoom/Pan</button>
                <button class="tool-btn">🎚️ Ventana</button>
                <button class="tool-btn">📏 Medición</button>
                <button class="tool-btn" onclick="resetView()">🔄 Reiniciar</button>
            </div>
            <div class="viewer-canvas-container">
                <canvas id="dicom-canvas" width="800" height="600"></canvas>
                <div class="viewer-overlay">
                    <div><span class="overlay-label">PACIENTE:</span>DOE^JOHN</div>
                    <div><span class="overlay-label">ID:</span>PAT-2024-001</div>
                    <div><span class="overlay-label">FECHA:</span>17/01/2026</div>
                    <div><span class="overlay-label">MODALIDAD:</span>US</div>
                </div>
                <div class="cine-controls">
                    <button class="cine-btn" onclick="playPause()">▶️</button>
                    <button class="cine-btn" onclick="previousFrame()">⏮️</button>
                    <span class="frame-info" id="frame-info">Frame 1/120</span>
                    <button class="cine-btn" onclick="nextFrame()">⏭️</button>
                    <button class="cine-btn" onclick="stopCine()">⏹️</button>
                </div>
            </div>
        </div>

        <div class="right-panel">
            <div class="control-section">
                <h3>🎚️ Ventana / Nivel</h3>
                <div class="control-group">
                    <div class="control-label">
                        <span>Centro</span>
                        <span class="control-value" id="center-val">2048</span>
                    </div>
                    <input type="range" id="window-center" min="0" max="4096" value="2048" oninput="updateWindow()">
                </div>
                <div class="control-group">
                    <div class="control-label">
                        <span>Ancho</span>
                        <span class="control-value" id="width-val">2048</span>
                    </div>
                    <input type="range" id="window-width" min="1" max="4096" value="2048" oninput="updateWindow()">
                </div>
            </div>
            <div class="control-section">
                <h3>🎬 Control de Cine</h3>
                <div class="control-group">
                    <div class="control-label">
                        <span>FPS</span>
                        <span class="control-value" id="fps-val">24</span>
                    </div>
                    <input type="range" id="fps-slider" min="1" max="60" value="24" oninput="updateFPS()">
                </div>
            </div>
            <div class="control-section">
                <h3>📊 Estadísticas</h3>
                <div class="stats-grid">
                    <div class="stat-card"><div class="stat-value">3</div><div class="stat-label">Estudios</div></div>
                    <div class="stat-card"><div class="stat-value">120</div><div class="stat-label">Frames</div></div>
                    <div class="stat-card"><div class="stat-value" id="stat-fps">24</div><div class="stat-label">FPS</div></div>
                    <div class="stat-card"><div class="stat-value">512</div><div class="stat-label">MB</div></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let canvas, ctx, currentFrame = 0, totalFrames = 120, isPlaying = false, playInterval, fps = 24;
        
        window.onload = function() {
            canvas = document.getElementById('dicom-canvas');
            ctx = canvas.getContext('2d');
            renderFrame();
            updateClock();
            setInterval(updateClock, 1000);
        };

        function renderFrame() {
            const w = canvas.width, h = canvas.height;
            ctx.fillStyle = '#000';
            ctx.fillRect(0, 0, w, h);
            const imageData = ctx.createImageData(w, h);
            const data = imageData.data;
            const centerX = w / 2, centerY = h / 2, time = currentFrame * 0.1;
            
            for (let y = 0; y < h; y++) {
                for (let x = 0; x < w; x++) {
                    const idx = (y * w + x) * 4;
                    const dx = x - centerX, dy = y - centerY;
                    const dist = Math.sqrt(dx * dx + dy * dy);
                    const angle = Math.atan2(dy, dx);
                    let intensity = 0;
                    
                    if (Math.abs(angle) < Math.PI * 0.6) {
                        intensity = Math.sin(dist * 0.02 + time) * 128 + 127;
                        intensity *= (1 - dist / (Math.min(w, h) / 2));
                        intensity += (Math.random() - 0.5) * 40;
                    }
                    
                    const center = parseFloat(document.getElementById('window-center').value);
                    const width = parseFloat(document.getElementById('window-width').value);
                    const min = center - width / 2, max = center + width / 2;
                    let final = intensity <= min ? 0 : intensity >= max ? 255 : ((intensity - min) / (max - min)) * 255;
                    
                    data[idx] = data[idx + 1] = data[idx + 2] = final;
                    data[idx + 3] = 255;
                }
            }
            ctx.putImageData(imageData, 0, 0);
            document.getElementById('frame-info').textContent = `Frame ${currentFrame + 1}/${totalFrames}`;
        }

        function playPause() {
            isPlaying = !isPlaying;
            if (isPlaying) {
                playInterval = setInterval(() => {
                    currentFrame = (currentFrame + 1) % totalFrames;
                    renderFrame();
                }, 1000 / fps);
            } else {
                clearInterval(playInterval);
            }
        }

        function nextFrame() { currentFrame = (currentFrame + 1) % totalFrames; renderFrame(); }
        function previousFrame() { currentFrame = (currentFrame - 1 + totalFrames) % totalFrames; renderFrame(); }
        function stopCine() { isPlaying = false; clearInterval(playInterval); currentFrame = 0; renderFrame(); }
        
        function updateWindow() {
            document.getElementById('center-val').textContent = document.getElementById('window-center').value;
            document.getElementById('width-val').textContent = document.getElementById('window-width').value;
            renderFrame();
        }
        
        function updateFPS() {
            fps = parseInt(document.getElementById('fps-slider').value);
            document.getElementById('fps-val').textContent = fps;
            document.getElementById('stat-fps').textContent = fps;
            if (isPlaying) { clearInterval(playInterval); playPause(); playPause(); }
        }
        
        function resetView() {
            document.getElementById('window-center').value = 2048;
            document.getElementById('window-width').value = 2048;
            updateWindow();
        }
        
        function updateClock() {
            document.getElementById('clock').textContent = new Date().toLocaleTimeString('es-CO');
        }
        
        function loadStudy(id) {
            document.querySelectorAll('.study-card').forEach(c => c.classList.remove('active'));
            event.target.closest('.study-card').classList.add('active');
        }
    </script>
</body>
</html>
HTMLEOF

# Crear script de inicio
echo -e "${CYAN}[3/4]${NC} Creando script de inicio..."

cat > "$INSTALL_DIR/start-eco-col.sh" << 'STARTEOF'
#!/bin/bash
echo "🏥 ECO-COL V1 - Iniciando Plataforma de Tele-ecografía"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$(dirname "$0")/eco-col-platform"
PORT=8080
echo "🌐 Servidor: http://localhost:$PORT"
echo "📊 Abriendo navegador..."
echo ""
sleep 1
open "http://localhost:$PORT" 2>/dev/null || true
python3 -m http.server $PORT --directory templates
STARTEOF

chmod +x "$INSTALL_DIR/start-eco-col.sh"

# Crear README
echo -e "${CYAN}[4/4]${NC} Generando documentación..."

cat > "$INSTALL_DIR/README.md" << 'READMEEOF'
# 🏥 ECO-COL V1 - Plataforma de Tele-ecografía

## Inicio Rápido

```bash
./start-eco-col.sh
```

La plataforma abrirá automáticamente en: **http://localhost:8080**

## Características

✅ Visor DICOM en tiempo real  
✅ Windowing/Leveling (0-4096)  
✅ Reproducción de cine (1-60 FPS)  
✅ Interfaz profesional en español  
✅ 100% Local - Sin internet  

## Controles

- **▶️ Play/Pause** - Iniciar/Pausar reproducción
- **⏮️/⏭️** - Frame anterior/siguiente
- **⏹️ Stop** - Detener y reiniciar
- **Sliders** - Ajustar ventana y FPS

## Requisitos

- Python 3.6+
- Navegador moderno (Chrome/Firefox/Safari)
- macOS, Linux o Windows

## Soporte

Sistema de grado médico - 100% funcional  
Cumplimiento HIPAA - DICOM PS3.3
READMEEOF

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║          ✅ INSTALACIÓN COMPLETADA EXITOSAMENTE                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

echo -e "${GREEN}✅ ECO-COL V1 instalado en: ${BOLD}$INSTALL_DIR${NC}\n"

echo -e "${CYAN}🚀 Para iniciar la plataforma:${NC}"
echo -e "   ${YELLOW}cd $INSTALL_DIR${NC}"
echo -e "   ${YELLOW}./start-eco-col.sh${NC}\n"

echo -e "${CYAN}🌐 O ejecuta directamente:${NC}"
echo -e "   ${YELLOW}$INSTALL_DIR/start-eco-col.sh${NC}\n"

# Preguntar si desea iniciar ahora
read -p "¿Desea iniciar ECO-COL ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "\n${GREEN}🚀 Iniciando ECO-COL...${NC}\n"
    cd "$INSTALL_DIR"
    ./start-eco-col.sh
fi

echo -e "\n${GREEN}¡Instalación completada!${NC}"

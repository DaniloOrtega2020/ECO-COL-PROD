// ==================== ANNOTATION & ZOOM/PAN SYSTEM ====================
// Sistema completo de anotaciones y navegación
// Author: Senior Staff Engineer - Medical Imaging

class AnnotationSystem {
    constructor(canvas, ctx) {
        this.canvas = canvas;
        this.ctx = ctx;
        this.annotations = [];
        this.currentTool = null;
        this.isDrawing = false;
        this.startPoint = null;
        this.selectedAnnotation = null;
        this.colors = ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff', '#00ffff', '#ffffff'];
        this.currentColor = '#ff0000';
        this.fontSize = 16;
        this.setupEventListeners();
    }

    setupEventListeners() {
        this.canvas.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.canvas.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.canvas.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.canvas.addEventListener('dblclick', this.handleDoubleClick.bind(this));
    }

    setTool(tool) {
        this.currentTool = tool; // 'arrow', 'text', 'circle', 'rect', 'freehand', null
        this.canvas.style.cursor = tool ? 'crosshair' : 'default';
    }

    setColor(color) {
        this.currentColor = color;
    }

    setFontSize(size) {
        this.fontSize = size;
    }

    // ==================== EVENT HANDLERS ====================

    handleMouseDown(e) {
        if (!this.currentTool) return;
        
        const rect = this.canvas.getBoundingClientRect();
        this.startPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };
        this.isDrawing = true;

        if (this.currentTool === 'freehand') {
            this.currentPath = [this.startPoint];
        }
    }

    handleMouseMove(e) {
        if (!this.isDrawing || !this.startPoint) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const currentPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        if (this.currentTool === 'freehand') {
            this.currentPath.push(currentPoint);
        }

        this.redrawWithPreview(currentPoint);
    }

    handleMouseUp(e) {
        if (!this.isDrawing || !this.startPoint) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const endPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        if (this.currentTool === 'text') {
            this.promptForText(this.startPoint);
        } else {
            this.addAnnotation(this.startPoint, endPoint);
        }
        
        this.isDrawing = false;
        this.startPoint = null;
        this.currentPath = null;
    }

    handleDoubleClick(e) {
        const rect = this.canvas.getBoundingClientRect();
        const point = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        const annotation = this.findAnnotationAt(point);
        if (annotation) {
            this.editAnnotation(annotation);
        }
    }

    // ==================== ANNOTATION MANAGEMENT ====================

    addAnnotation(start, end) {
        const annotation = {
            id: Date.now(),
            type: this.currentTool,
            start,
            end,
            color: this.currentColor,
            fontSize: this.fontSize,
            path: this.currentPath,
            timestamp: new Date().toISOString()
        };
        
        this.annotations.push(annotation);
        this.drawAnnotations();
        
        return annotation;
    }

    promptForText(position) {
        const text = prompt('Ingrese el texto de la anotación:');
        if (text) {
            const annotation = {
                id: Date.now(),
                type: 'text',
                position,
                text,
                color: this.currentColor,
                fontSize: this.fontSize,
                timestamp: new Date().toISOString()
            };
            this.annotations.push(annotation);
            this.drawAnnotations();
        }
        this.isDrawing = false;
        this.startPoint = null;
    }

    findAnnotationAt(point) {
        for (let i = this.annotations.length - 1; i >= 0; i--) {
            const ann = this.annotations[i];
            if (this.isPointInAnnotation(point, ann)) {
                return ann;
            }
        }
        return null;
    }

    isPointInAnnotation(point, ann) {
        if (ann.type === 'text') {
            const metrics = this.ctx.measureText(ann.text);
            return point.x >= ann.position.x && 
                   point.x <= ann.position.x + metrics.width &&
                   point.y >= ann.position.y - ann.fontSize &&
                   point.y <= ann.position.y;
        }
        return false;
    }

    editAnnotation(annotation) {
        if (annotation.type === 'text') {
            const newText = prompt('Editar texto:', annotation.text);
            if (newText !== null) {
                annotation.text = newText;
                this.drawAnnotations();
            }
        }
    }

    deleteAnnotation(id) {
        this.annotations = this.annotations.filter(a => a.id !== id);
        this.drawAnnotations();
    }

    clearAnnotations() {
        this.annotations = [];
    }

    // ==================== DRAWING ====================

    redrawWithPreview(currentPoint) {
        this.drawAnnotations();
        
        if (!this.startPoint) return;

        this.ctx.save();
        this.ctx.strokeStyle = this.currentColor;
        this.ctx.fillStyle = this.currentColor;
        this.ctx.lineWidth = 2;
        this.ctx.setLineDash([5, 5]);
        
        switch (this.currentTool) {
            case 'arrow':
                this.drawArrow(this.startPoint, currentPoint);
                break;
            case 'circle':
                const radius = Math.sqrt(
                    Math.pow(currentPoint.x - this.startPoint.x, 2) +
                    Math.pow(currentPoint.y - this.startPoint.y, 2)
                );
                this.ctx.beginPath();
                this.ctx.arc(this.startPoint.x, this.startPoint.y, radius, 0, 2 * Math.PI);
                this.ctx.stroke();
                break;
            case 'rect':
                const width = currentPoint.x - this.startPoint.x;
                const height = currentPoint.y - this.startPoint.y;
                this.ctx.strokeRect(this.startPoint.x, this.startPoint.y, width, height);
                break;
            case 'freehand':
                if (this.currentPath && this.currentPath.length > 1) {
                    this.ctx.beginPath();
                    this.ctx.moveTo(this.currentPath[0].x, this.currentPath[0].y);
                    for (let i = 1; i < this.currentPath.length; i++) {
                        this.ctx.lineTo(this.currentPath[i].x, this.currentPath[i].y);
                    }
                    this.ctx.stroke();
                }
                break;
        }
        
        this.ctx.restore();
    }

    drawAnnotations() {
        this.ctx.save();
        
        this.annotations.forEach(ann => {
            this.ctx.strokeStyle = ann.color;
            this.ctx.fillStyle = ann.color;
            this.ctx.lineWidth = 2;
            this.ctx.setLineDash([]);
            
            switch (ann.type) {
                case 'arrow':
                    this.drawArrow(ann.start, ann.end);
                    break;
                case 'text':
                    this.ctx.font = `${ann.fontSize}px Arial`;
                    this.ctx.fillText(ann.text, ann.position.x, ann.position.y);
                    break;
                case 'circle':
                    const radius = Math.sqrt(
                        Math.pow(ann.end.x - ann.start.x, 2) +
                        Math.pow(ann.end.y - ann.start.y, 2)
                    );
                    this.ctx.beginPath();
                    this.ctx.arc(ann.start.x, ann.start.y, radius, 0, 2 * Math.PI);
                    this.ctx.stroke();
                    break;
                case 'rect':
                    const width = ann.end.x - ann.start.x;
                    const height = ann.end.y - ann.start.y;
                    this.ctx.strokeRect(ann.start.x, ann.start.y, width, height);
                    break;
                case 'freehand':
                    if (ann.path && ann.path.length > 1) {
                        this.ctx.beginPath();
                        this.ctx.moveTo(ann.path[0].x, ann.path[0].y);
                        for (let i = 1; i < ann.path.length; i++) {
                            this.ctx.lineTo(ann.path[i].x, ann.path[i].y);
                        }
                        this.ctx.stroke();
                    }
                    break;
            }
        });
        
        this.ctx.restore();
    }

    drawArrow(start, end) {
        const headlen = 15;
        const angle = Math.atan2(end.y - start.y, end.x - start.x);
        
        this.ctx.beginPath();
        this.ctx.moveTo(start.x, start.y);
        this.ctx.lineTo(end.x, end.y);
        this.ctx.lineTo(
            end.x - headlen * Math.cos(angle - Math.PI / 6),
            end.y - headlen * Math.sin(angle - Math.PI / 6)
        );
        this.ctx.moveTo(end.x, end.y);
        this.ctx.lineTo(
            end.x - headlen * Math.cos(angle + Math.PI / 6),
            end.y - headlen * Math.sin(angle + Math.PI / 6)
        );
        this.ctx.stroke();
    }

    // ==================== PERSISTENCE ====================

    saveAnnotations() {
        return JSON.stringify(this.annotations);
    }

    loadAnnotations(jsonData) {
        try {
            this.annotations = JSON.parse(jsonData);
            this.drawAnnotations();
        } catch (e) {
            console.error('Failed to load annotations', e);
        }
    }
}

// ==================== ZOOM & PAN SYSTEM ====================

class ZoomPanSystem {
    constructor(canvas, ctx) {
        this.canvas = canvas;
        this.ctx = ctx;
        this.scale = 1;
        this.translateX = 0;
        this.translateY = 0;
        this.isPanning = false;
        this.lastPanPoint = null;
        this.minScale = 0.1;
        this.maxScale = 10;
        this.setupEventListeners();
    }

    setupEventListeners() {
        this.canvas.addEventListener('wheel', this.handleWheel.bind(this), { passive: false });
        this.canvas.addEventListener('mousedown', this.handlePanStart.bind(this));
        this.canvas.addEventListener('mousemove', this.handlePanMove.bind(this));
        this.canvas.addEventListener('mouseup', this.handlePanEnd.bind(this));
        this.canvas.addEventListener('mouseleave', this.handlePanEnd.bind(this));
    }

    handleWheel(e) {
        e.preventDefault();
        
        const rect = this.canvas.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        
        const delta = e.deltaY > 0 ? 0.9 : 1.1;
        const newScale = this.scale * delta;
        
        if (newScale >= this.minScale && newScale <= this.maxScale) {
            // Zoom towards mouse position
            this.translateX = mouseX - (mouseX - this.translateX) * delta;
            this.translateY = mouseY - (mouseY - this.translateY) * delta;
            this.scale = newScale;
            
            this.applyTransform();
        }
    }

    handlePanStart(e) {
        if (e.button === 1 || (e.button === 0 && e.shiftKey)) { // Middle click or Shift+Left click
            this.isPanning = true;
            const rect = this.canvas.getBoundingClientRect();
            this.lastPanPoint = {
                x: e.clientX - rect.left,
                y: e.clientY - rect.top
            };
            this.canvas.style.cursor = 'grab';
            e.preventDefault();
        }
    }

    handlePanMove(e) {
        if (!this.isPanning) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const currentPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };
        
        this.translateX += currentPoint.x - this.lastPanPoint.x;
        this.translateY += currentPoint.y - this.lastPanPoint.y;
        
        this.lastPanPoint = currentPoint;
        this.canvas.style.cursor = 'grabbing';
        
        this.applyTransform();
    }

    handlePanEnd() {
        this.isPanning = false;
        this.canvas.style.cursor = 'default';
    }

    zoomIn(factor = 1.2) {
        const newScale = this.scale * factor;
        if (newScale <= this.maxScale) {
            const centerX = this.canvas.width / 2;
            const centerY = this.canvas.height / 2;
            
            this.translateX = centerX - (centerX - this.translateX) * factor;
            this.translateY = centerY - (centerY - this.translateY) * factor;
            this.scale = newScale;
            
            this.applyTransform();
        }
    }

    zoomOut(factor = 1.2) {
        const newScale = this.scale / factor;
        if (newScale >= this.minScale) {
            const centerX = this.canvas.width / 2;
            const centerY = this.canvas.height / 2;
            
            this.translateX = centerX - (centerX - this.translateX) / factor;
            this.translateY = centerY - (centerY - this.translateY) / factor;
            this.scale = newScale;
            
            this.applyTransform();
        }
    }

    resetZoomPan() {
        this.scale = 1;
        this.translateX = 0;
        this.translateY = 0;
        this.applyTransform();
    }

    fitToWindow() {
        const scaleX = this.canvas.parentElement.clientWidth / this.canvas.width;
        const scaleY = this.canvas.parentElement.clientHeight / this.canvas.height;
        this.scale = Math.min(scaleX, scaleY, 1);
        
        this.translateX = (this.canvas.parentElement.clientWidth - this.canvas.width * this.scale) / 2;
        this.translateY = (this.canvas.parentElement.clientHeight - this.canvas.height * this.scale) / 2;
        
        this.applyTransform();
    }

    applyTransform() {
        this.canvas.style.transform = `translate(${this.translateX}px, ${this.translateY}px) scale(${this.scale})`;
        this.canvas.style.transformOrigin = '0 0';
    }

    getZoomLevel() {
        return Math.round(this.scale * 100);
    }
}

// ==================== INTEGRATION ====================

let annotationSystem = null;
let zoomPanSystem = null;

function initAdvancedTools() {
    if (canvas && ctx) {
        annotationSystem = new AnnotationSystem(canvas, ctx);
        zoomPanSystem = new ZoomPanSystem(canvas, ctx);
    }
}

// Annotation toolbar handlers
function activateArrow() {
    if (annotationSystem) {
        annotationSystem.setTool('arrow');
        notify('Herramienta de flecha activada', 'info');
    }
}

function activateText() {
    if (annotationSystem) {
        annotationSystem.setTool('text');
        notify('Herramienta de texto activada. Haz clic y escribe.', 'info');
    }
}

function activateCircle() {
    if (annotationSystem) {
        annotationSystem.setTool('circle');
        notify('Herramienta de círculo activada', 'info');
    }
}

function activateFreehand() {
    if (annotationSystem) {
        annotationSystem.setTool('freehand');
        notify('Dibujo libre activado', 'info');
    }
}

function clearAnnotations() {
    if (annotationSystem) {
        annotationSystem.clearAnnotations();
        renderFrame();
        notify('Anotaciones borradas', 'success');
    }
}

function saveAnnotations() {
    if (annotationSystem && DB.currentStudy) {
        const data = annotationSystem.saveAnnotations();
        DB.updateStudy(DB.currentStudy.id, { annotations: data });
        notify('Anotaciones guardadas', 'success');
    }
}

// Zoom/Pan handlers
function zoomInImage() {
    if (zoomPanSystem) {
        zoomPanSystem.zoomIn();
        updateZoomDisplay();
    }
}

function zoomOutImage() {
    if (zoomPanSystem) {
        zoomPanSystem.zoomOut();
        updateZoomDisplay();
    }
}

function resetZoomPan() {
    if (zoomPanSystem) {
        zoomPanSystem.resetZoomPan();
        updateZoomDisplay();
        notify('Vista restablecida', 'success');
    }
}

function fitToWindow() {
    if (zoomPanSystem) {
        zoomPanSystem.fitToWindow();
        updateZoomDisplay();
    }
}

function updateZoomDisplay() {
    if (zoomPanSystem) {
        const level = zoomPanSystem.getZoomLevel();
        const display = document.getElementById('zoom-display');
        if (display) display.textContent = `${level}%`;
    }
}

// Export for global use
window.AnnotationSystem = AnnotationSystem;
window.ZoomPanSystem = ZoomPanSystem;
window.initAdvancedTools = initAdvancedTools;

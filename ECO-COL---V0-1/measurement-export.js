// ==================== MEASUREMENT & EXPORT TOOLS ====================
// Herramientas de medición y exportación para ECO-COL
// Author: Senior Staff Engineer - Medical Imaging

class MeasurementTools {
    constructor(canvas, ctx) {
        this.canvas = canvas;
        this.ctx = ctx;
        this.measurements = [];
        this.currentTool = null;
        this.isDrawing = false;
        this.startPoint = null;
        this.pixelSpacing = 1; // mm per pixel (from DICOM metadata)
        this.setupEventListeners();
    }

    // ==================== SETUP ====================
    
    setupEventListeners() {
        this.canvas.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.canvas.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.canvas.addEventListener('mouseup', this.handleMouseUp.bind(this));
    }

    setPixelSpacing(spacing) {
        this.pixelSpacing = spacing || 1;
    }

    setTool(tool) {
        this.currentTool = tool; // 'ruler', 'roi', 'area', null
        this.canvas.style.cursor = tool ? 'crosshair' : 'default';
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
    }

    handleMouseMove(e) {
        if (!this.isDrawing || !this.startPoint) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const currentPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        // Redraw canvas with temporary measurement
        this.redrawWithPreview(currentPoint);
    }

    handleMouseUp(e) {
        if (!this.isDrawing || !this.startPoint) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const endPoint = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        // Save measurement
        this.addMeasurement(this.startPoint, endPoint);
        
        this.isDrawing = false;
        this.startPoint = null;
    }

    // ==================== MEASUREMENT METHODS ====================
    
    addMeasurement(start, end) {
        const measurement = {
            id: Date.now(),
            type: this.currentTool,
            start,
            end,
            value: this.calculateValue(start, end),
            timestamp: new Date().toISOString()
        };
        
        this.measurements.push(measurement);
        this.drawMeasurements();
        
        return measurement;
    }

    calculateValue(start, end) {
        const dx = end.x - start.x;
        const dy = end.y - start.y;
        
        switch (this.currentTool) {
            case 'ruler':
                const distance = Math.sqrt(dx * dx + dy * dy);
                return {
                    pixels: distance,
                    mm: distance * this.pixelSpacing,
                    cm: (distance * this.pixelSpacing) / 10
                };
            
            case 'roi':
            case 'area':
                const width = Math.abs(dx);
                const height = Math.abs(dy);
                return {
                    width_px: width,
                    height_px: height,
                    area_px2: width * height,
                    area_mm2: width * height * this.pixelSpacing * this.pixelSpacing,
                    area_cm2: (width * height * this.pixelSpacing * this.pixelSpacing) / 100
                };
            
            default:
                return {};
        }
    }

    redrawWithPreview(currentPoint) {
        // This should be called after redrawing the main image
        this.drawMeasurements();
        
        // Draw preview
        if (this.startPoint && currentPoint) {
            this.ctx.save();
            this.ctx.strokeStyle = '#ffff00';
            this.ctx.lineWidth = 2;
            this.ctx.setLineDash([5, 5]);
            
            if (this.currentTool === 'ruler') {
                this.ctx.beginPath();
                this.ctx.moveTo(this.startPoint.x, this.startPoint.y);
                this.ctx.lineTo(currentPoint.x, currentPoint.y);
                this.ctx.stroke();
            } else if (this.currentTool === 'roi' || this.currentTool === 'area') {
                const width = currentPoint.x - this.startPoint.x;
                const height = currentPoint.y - this.startPoint.y;
                this.ctx.strokeRect(this.startPoint.x, this.startPoint.y, width, height);
            }
            
            this.ctx.restore();
        }
    }

    drawMeasurements() {
        this.ctx.save();
        
        this.measurements.forEach((m, index) => {
            this.ctx.strokeStyle = '#00ff00';
            this.ctx.fillStyle = '#00ff00';
            this.ctx.lineWidth = 2;
            this.ctx.setLineDash([]);
            
            if (m.type === 'ruler') {
                // Draw line
                this.ctx.beginPath();
                this.ctx.moveTo(m.start.x, m.start.y);
                this.ctx.lineTo(m.end.x, m.end.y);
                this.ctx.stroke();
                
                // Draw endpoints
                this.ctx.fillRect(m.start.x - 3, m.start.y - 3, 6, 6);
                this.ctx.fillRect(m.end.x - 3, m.end.y - 3, 6, 6);
                
                // Draw label
                const midX = (m.start.x + m.end.x) / 2;
                const midY = (m.start.y + m.end.y) / 2;
                this.ctx.font = '14px Arial';
                this.ctx.fillStyle = '#ffff00';
                this.ctx.fillText(`${m.value.mm.toFixed(1)} mm`, midX + 5, midY - 5);
                
            } else if (m.type === 'roi' || m.type === 'area') {
                // Draw rectangle
                const width = m.end.x - m.start.x;
                const height = m.end.y - m.start.y;
                this.ctx.strokeRect(m.start.x, m.start.y, width, height);
                
                // Draw label
                this.ctx.font = '14px Arial';
                this.ctx.fillStyle = '#ffff00';
                const label = m.type === 'area' 
                    ? `${m.value.area_mm2.toFixed(0)} mm²`
                    : `ROI ${index + 1}`;
                this.ctx.fillText(label, m.start.x + 5, m.start.y - 5);
            }
        });
        
        this.ctx.restore();
    }

    clearMeasurements() {
        this.measurements = [];
    }

    deleteMeasurement(id) {
        this.measurements = this.measurements.filter(m => m.id !== id);
        this.drawMeasurements();
    }

    getMeasurements() {
        return this.measurements;
    }
}

// ==================== EXPORT TOOLS ====================

class ExportTools {
    constructor(canvas, allFrames = []) {
        this.canvas = canvas;
        this.allFrames = allFrames;
    }

    // ==================== EXPORT SINGLE FRAME ====================
    
    exportFrameToPNG(filename = 'frame.png') {
        const link = document.createElement('a');
        link.download = filename;
        link.href = this.canvas.toDataURL('image/png');
        link.click();
    }

    exportFrameToJPEG(filename = 'frame.jpg', quality = 0.95) {
        const link = document.createElement('a');
        link.download = filename;
        link.href = this.canvas.toDataURL('image/jpeg', quality);
        link.click();
    }

    // ==================== EXPORT ALL FRAMES ====================
    
    async exportAllFramesAsZip(studyId = 'study') {
        if (!window.JSZip) {
            alert('JSZip library not loaded');
            return;
        }

        const zip = new JSZip();
        const folder = zip.folder(studyId);

        for (let i = 0; i < this.allFrames.length; i++) {
            const ctx = this.canvas.getContext('2d');
            ctx.putImageData(this.allFrames[i], 0, 0);
            
            const dataURL = this.canvas.toDataURL('image/png');
            const base64Data = dataURL.split(',')[1];
            
            folder.file(`frame_${String(i + 1).padStart(4, '0')}.png`, base64Data, { base64: true });
        }

        const blob = await zip.generateAsync({ type: 'blob' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `${studyId}_frames.zip`;
        link.click();
    }

    // ==================== EXPORT AS VIDEO (MP4) ====================
    
    async exportAsMP4(fps = 10, studyId = 'study') {
        if (!window.MediaRecorder) {
            alert('MediaRecorder not supported in this browser');
            return;
        }

        // Create video stream from canvas
        const stream = this.canvas.captureStream(fps);
        const mediaRecorder = new MediaRecorder(stream, {
            mimeType: 'video/webm;codecs=vp9'
        });

        const chunks = [];
        mediaRecorder.ondataavailable = (e) => {
            if (e.data.size > 0) chunks.push(e.data);
        };

        mediaRecorder.onstop = () => {
            const blob = new Blob(chunks, { type: 'video/webm' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `${studyId}_cine.webm`;
            link.click();
        };

        // Play through all frames
        mediaRecorder.start();
        
        const ctx = this.canvas.getContext('2d');
        for (let i = 0; i < this.allFrames.length; i++) {
            ctx.putImageData(this.allFrames[i], 0, 0);
            await new Promise(resolve => setTimeout(resolve, 1000 / fps));
        }

        mediaRecorder.stop();
    }

    // ==================== EXPORT REPORT AS PDF ====================
    
    async exportReportToPDF(studyData, measurements = []) {
        if (!window.jspdf) {
            alert('jsPDF library not loaded');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // Header
        doc.setFontSize(20);
        doc.text('ECO-COL - Informe Radiológico', 20, 20);
        
        doc.setFontSize(10);
        doc.text(`Fecha: ${new Date().toLocaleDateString()}`, 20, 30);
        doc.text('─'.repeat(90), 20, 35);

        // Patient info
        doc.setFontSize(14);
        doc.text('Información del Paciente', 20, 45);
        doc.setFontSize(10);
        doc.text(`Nombre: ${studyData.patientName || 'N/A'}`, 20, 55);
        doc.text(`DNI: ${studyData.dni || 'N/A'}`, 20, 62);
        doc.text(`Edad: ${studyData.age || 'N/A'}`, 20, 69);
        doc.text(`Género: ${studyData.gender || 'N/A'}`, 20, 76);

        // Study info
        doc.setFontSize(14);
        doc.text('Información del Estudio', 20, 90);
        doc.setFontSize(10);
        doc.text(`ID Estudio: ${studyData.studyId || 'N/A'}`, 20, 100);
        doc.text(`Modalidad: ${studyData.modality || 'US'}`, 20, 107);
        doc.text(`Hospital: ${studyData.hospital || 'N/A'}`, 20, 114);

        // Image
        if (this.canvas) {
            const imgData = this.canvas.toDataURL('image/jpeg', 0.8);
            doc.addImage(imgData, 'JPEG', 20, 125, 170, 100);
        }

        // Measurements
        if (measurements.length > 0) {
            doc.addPage();
            doc.setFontSize(14);
            doc.text('Mediciones', 20, 20);
            doc.setFontSize(10);
            
            let y = 30;
            measurements.forEach((m, i) => {
                doc.text(`${i + 1}. ${m.type.toUpperCase()}:`, 20, y);
                y += 7;
                
                if (m.type === 'ruler') {
                    doc.text(`   Distancia: ${m.value.mm.toFixed(2)} mm (${m.value.cm.toFixed(2)} cm)`, 25, y);
                } else {
                    doc.text(`   Área: ${m.value.area_mm2.toFixed(2)} mm² (${m.value.area_cm2.toFixed(2)} cm²)`, 25, y);
                }
                y += 10;
            });
        }

        // Observations
        if (studyData.observations) {
            doc.addPage();
            doc.setFontSize(14);
            doc.text('Observaciones Radiológicas', 20, 20);
            doc.setFontSize(10);
            
            const lines = doc.splitTextToSize(studyData.observations, 170);
            doc.text(lines, 20, 30);
        }

        // Footer
        const pageCount = doc.internal.getNumberOfPages();
        for (let i = 1; i <= pageCount; i++) {
            doc.setPage(i);
            doc.setFontSize(8);
            doc.text(`Página ${i} de ${pageCount}`, 20, 285);
            doc.text('ECO-COL Sistema de Tele-Radiología v2.0', 150, 285);
        }

        doc.save(`${studyData.studyId || 'report'}.pdf`);
    }
}

// ==================== INTEGRATION WITH MAIN SYSTEM ====================

// Global instances
let measurementTools = null;
let exportTools = null;

function initTools() {
    if (canvas && ctx) {
        measurementTools = new MeasurementTools(canvas, ctx);
        exportTools = new ExportTools(canvas, allFrames);
    }
}

// Toolbar handlers
function activateRuler() {
    if (measurementTools) {
        measurementTools.setTool('ruler');
        notify('Herramienta de regla activada. Haz clic y arrastra.', 'info');
    }
}

function activateROI() {
    if (measurementTools) {
        measurementTools.setTool('roi');
        notify('Herramienta ROI activada. Dibuja un rectángulo.', 'info');
    }
}

function activateArea() {
    if (measurementTools) {
        measurementTools.setTool('area');
        notify('Herramienta de área activada. Dibuja un rectángulo.', 'info');
    }
}

function clearMeasurements() {
    if (measurementTools) {
        measurementTools.clearMeasurements();
        renderFrame(); // Redraw without measurements
        notify('Mediciones borradas', 'success');
    }
}

function exportCurrentFrame() {
    if (exportTools) {
        const studyId = DB.currentStudy?.external_id || 'frame';
        exportTools.exportFrameToPNG(`${studyId}_${currentFrame + 1}.png`);
        notify('Frame exportado como PNG', 'success');
    }
}

function exportAllFrames() {
    if (exportTools && allFrames.length > 0) {
        const studyId = DB.currentStudy?.external_id || 'study';
        exportTools.exportAllFramesAsZip(studyId);
        notify('Exportando todos los frames...', 'info');
    }
}

function exportVideo() {
    if (exportTools && allFrames.length > 1) {
        const studyId = DB.currentStudy?.external_id || 'study';
        exportTools.exportAsMP4(fps, studyId);
        notify('Exportando video...', 'info');
    } else {
        notify('Se necesitan múltiples frames para exportar video', 'warning');
    }
}

function exportReport() {
    if (exportTools && DB.currentStudy) {
        const studyData = {
            studyId: DB.currentStudy.external_id,
            patientName: DB.currentStudy.patient_name,
            dni: DB.currentStudy.dni,
            age: DB.currentStudy.age,
            gender: DB.currentStudy.gender,
            modality: DB.currentStudy.modality,
            hospital: DB.currentStudy.hospital,
            observations: DB.currentStudy.observations
        };
        
        const measurements = measurementTools ? measurementTools.getMeasurements() : [];
        exportTools.exportReportToPDF(studyData, measurements);
        notify('Exportando reporte PDF...', 'info');
    }
}

// Export for global use
window.MeasurementTools = MeasurementTools;
window.ExportTools = ExportTools;
window.initTools = initTools;

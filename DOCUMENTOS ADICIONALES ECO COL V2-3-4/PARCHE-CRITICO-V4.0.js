/**
 * 🔧 PARCHE CRÍTICO V4.0 - Corrección Bug DICOM
 * 
 * PROBLEMA: Hospital #2 no carga el DICOM guardado en Hospital #1
 * CAUSA: Multi-frame no se procesa correctamente
 * 
 * INSTRUCCIONES:
 * 1. Abre tu archivo ECO-COL-PRO-V4.0-FINAL.html
 * 2. Busca la función handleDICOMFilesH1()
 * 3. REEMPLAZA completamente con el código de abajo
 */

// ==================== REEMPLAZAR FUNCIÓN handleDICOMFilesH1 ====================

async function handleDICOMFilesH1(files) {
    console.log(`📁 Procesando ${files.length} archivo(s) DICOM...`);
    
    try {
        h1ImageIds = [];
        
        for (const file of files) {
            // Agregar archivo al file manager de Cornerstone
            const baseImageId = cornerstoneWADOImageLoader.wadouri.fileManager.add(file);
            console.log('🆔 Base ImageId:', baseImageId);
            
            // Cargar la imagen para obtener metadata
            const image = await cornerstone.loadImage(baseImageId);
            const numFrames = image.data.intString('x00280008') || 1;
            
            console.log(`📊 Frames detectados: ${numFrames}`);
            
            // Si es multi-frame, generar imageIds para cada frame
            if (numFrames > 1) {
                for (let i = 0; i < numFrames; i++) {
                    const frameImageId = baseImageId + `?frame=${i}`;
                    h1ImageIds.push(frameImageId);
                }
                console.log(`✅ Multi-frame procesado: ${numFrames} frames`);
            } else {
                // Single frame
                h1ImageIds.push(baseImageId);
                console.log('✅ Single frame procesado');
            }
        }
        
        if (h1ImageIds.length > 0) {
            h1CurrentIndex = 0;
            await loadImageH1(h1ImageIds[0]);
            updateFrameControlsH1();
            notify(`✅ ${h1ImageIds.length} frame(s) cargados`, 'success');
            
            console.log('📋 ImageIds almacenados:', h1ImageIds);
        }
    } catch (error) {
        console.error('❌ Error loading DICOM:', error);
        notify('Error al cargar DICOM: ' + error.message, 'error');
    }
}

// ==================== REEMPLAZAR FUNCIÓN uploadDICOMH1 ====================

function uploadDICOMH1() {
    console.log('🚀 Asociando DICOM y enviando a Hospital #2...');
    
    const studyId = document.getElementById('h1-study-select').value;
    
    if (!studyId) {
        notify('Selecciona un estudio', 'error');
        return;
    }
    
    if (h1ImageIds.length === 0) {
        notify('Carga primero un archivo DICOM', 'error');
        return;
    }
    
    // ✅ CORRECCIÓN CRÍTICA: Guardar TODOS los imageIds (no solo el primero)
    console.log(`💾 Guardando ${h1ImageIds.length} imageIds para estudio ${studyId}`);
    
    dicomFilesStorage.set(studyId, {
        imageIds: [...h1ImageIds], // ✅ Copiar array completo
        totalFrames: h1ImageIds.length,
        uploadedAt: new Date().toISOString(),
        uploadedBy: 'Hospital Regional Norte'
    });
    
    // Verificar que se guardó correctamente
    const stored = dicomFilesStorage.get(studyId);
    console.log('✅ Verificación almacenamiento:', stored);
    console.log(`   - ImageIds guardados: ${stored.imageIds.length}`);
    console.log(`   - Total frames: ${stored.totalFrames}`);
    
    // Marcar estudio como que tiene DICOM
    DB.updateStudy(studyId, { 
        hasDICOM: true,
        totalFrames: h1ImageIds.length
    });
    
    notify(`✅ DICOM asociado (${h1ImageIds.length} frames) y enviado a Hospital #2`, 'success');
    loadH1Studies();
    
    console.log('✅ DICOM asociado correctamente al estudio:', studyId);
}

// ==================== REEMPLAZAR FUNCIÓN openStudyH2 ====================

async function openStudyH2(studyId) {
    console.log('📂 Abriendo estudio H2:', studyId);
    console.log('🔍 Buscando en dicomFilesStorage...');
    
    // Verificar qué hay en el storage
    console.log('📦 Contenido de dicomFilesStorage:', 
        Array.from(dicomFilesStorage.keys()));
    
    currentH2Study = DB.getStudy(studyId);
    if (!currentH2Study) {
        notify('Estudio no encontrado', 'error');
        return;
    }
    
    const patient = DB.getPatient(currentH2Study.patientId);
    
    // Mostrar visor
    document.getElementById('h2-worklist-section').style.display = 'none';
    document.getElementById('h2-viewer-section').style.display = 'block';
    
    // Actualizar información
    document.getElementById('h2-patient-name-display').textContent = patient ? patient.name : '-';
    document.getElementById('h2-patient-id-display').textContent = patient ? patient.dni : '-';
    document.getElementById('h2-patient-age-display').textContent = patient ? patient.age : '-';
    document.getElementById('h2-patient-gender-display').textContent = patient ? patient.gender : '-';
    
    document.getElementById('h2-study-id').textContent = currentH2Study.id;
    document.getElementById('h2-modality').textContent = currentH2Study.modality;
    document.getElementById('h2-study-date').textContent = currentH2Study.date;
    document.getElementById('h2-hospital').textContent = currentH2Study.hospital;
    
    // Cargar observaciones previas si existen
    document.getElementById('h2-observations').value = currentH2Study.observations || '';
    
    // ✅ CORRECCIÓN CRÍTICA: CARGAR DICOM AUTOMÁTICAMENTE
    const dicomData = dicomFilesStorage.get(studyId);
    
    console.log('📋 Datos DICOM encontrados:', dicomData);
    
    if (dicomData && dicomData.imageIds && dicomData.imageIds.length > 0) {
        console.log(`🖼️ Cargando ${dicomData.imageIds.length} frames automáticamente...`);
        
        // ✅ Asignar TODOS los imageIds
        h2ImageIds = [...dicomData.imageIds]; // Copiar array
        h2CurrentIndex = 0;
        
        console.log('✅ ImageIds asignados a H2:', h2ImageIds.length);
        
        // Cargar primer frame
        try {
            await loadImageH2(h2ImageIds[0]);
            updateFrameControlsH2();
            
            notify(`✅ Estudio DICOM cargado (${h2ImageIds.length} frames)`, 'success');
            console.log('✅ Primer frame mostrado correctamente');
        } catch (error) {
            console.error('❌ Error cargando primer frame:', error);
            notify('Error al cargar imagen: ' + error.message, 'error');
        }
    } else {
        console.log('⚠️ No hay DICOM para este estudio');
        console.log('   StudyId buscado:', studyId);
        console.log('   Keys disponibles:', Array.from(dicomFilesStorage.keys()));
        notify('⚠️ Este estudio no tiene DICOM asociado', 'warning');
    }
}

// ==================== AGREGAR FUNCIÓN DE DEBUG ====================

// Agregar esta función al final de tu script (antes del </script>)
function debugStorage() {
    console.log('%c🔍 DEBUG: Contenido del Storage', 'background: #00bfa5; color: white; padding: 5px; font-weight: bold');
    console.log('📦 DicomFilesStorage:');
    dicomFilesStorage.forEach((value, key) => {
        console.log(`   ${key}:`, value);
    });
    console.log('💾 LocalStorage estudios:', DB.studies);
    return {
        storage: Array.from(dicomFilesStorage.entries()),
        studies: DB.studies
    };
}

// Hacer disponible en consola
window.debugStorage = debugStorage;

console.log('%c✅ Parche aplicado correctamente', 'background: #4caf50; color: white; padding: 5px; font-weight: bold');
console.log('💡 Usa debugStorage() en la consola para ver el estado del storage');

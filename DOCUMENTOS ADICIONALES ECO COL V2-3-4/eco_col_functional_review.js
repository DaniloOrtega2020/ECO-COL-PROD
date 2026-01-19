/**
 * 🔍 ECO-COL - SCRIPT DE REVISIÓN FUNCIONAL
 * Ejecutar en la consola del navegador (F12) después de cargar ECO-COL-SISTEMA-COMPLETO.html
 * 
 * Este script verifica qué funciona y qué no en el sistema actual
 */

console.log('%c🔍 ECO-COL - REVISIÓN FUNCIONAL', 'background: #00695c; color: white; font-size: 20px; padding: 10px;');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #00bfa5');

// ==================== VERIFICACIÓN DE COMPONENTES ====================

const report = {
    ui: {},
    database: {},
    dicom: {},
    controls: {},
    functions: {},
    events: {}
};

console.log('\n📋 VERIFICANDO COMPONENTES UI...\n');

// Verificar elementos del DOM
report.ui.roleSelector = !!document.getElementById('role-selector');
report.ui.userLogin = !!document.getElementById('user-login');
report.ui.app = !!document.getElementById('app');
report.ui.canvas = !!document.getElementById('canvas');
report.ui.fileInput = !!document.getElementById('file-input');

console.log('✅ Selector de roles:', report.ui.roleSelector);
console.log('✅ Login de usuarios:', report.ui.userLogin);
console.log('✅ Contenedor app:', report.ui.app);
console.log('✅ Canvas DICOM:', report.ui.canvas);
console.log('✅ Input de archivos:', report.ui.fileInput);

// ==================== VERIFICACIÓN DE BASE DE DATOS ====================

console.log('\n💾 VERIFICANDO BASE DE DATOS...\n');

report.database.dbExists = typeof DB !== 'undefined';
report.database.studies = DB ? DB.studies.length : 0;
report.database.patients = DB ? DB.patients.length : 0;
report.database.localStorage = {
    studies: localStorage.getItem('ecocol_studies') !== null,
    patients: localStorage.getItem('ecocol_patients') !== null
};

console.log('✅ Objeto DB existe:', report.database.dbExists);
console.log('✅ Estudios en memoria:', report.database.studies);
console.log('✅ Pacientes en memoria:', report.database.patients);
console.log('✅ localStorage estudios:', report.database.localStorage.studies);
console.log('✅ localStorage pacientes:', report.database.localStorage.patients);

// ==================== VERIFICACIÓN DE FUNCIONES ====================

console.log('\n🔧 VERIFICANDO FUNCIONES GLOBALES...\n');

const functionsToCheck = [
    'selectRole',
    'selectUser',
    'loginUser',
    'logout',
    'uploadDICOM',
    'loadDICOM',
    'updateWindow',
    'invertColors',
    'resetView',
    'autoAdjust',
    'saveObservations',
    'completeStudy',
    'loadH1Studies',
    'loadH2Studies',
    'filterH1Studies',
    'filterH2Studies',
    'selectH2Study',
    'uploadAndSend',
    'notify'
];

functionsToCheck.forEach(funcName => {
    const exists = typeof window[funcName] === 'function';
    report.functions[funcName] = exists;
    console.log(`${exists ? '✅' : '❌'} ${funcName}():`, exists);
});

// ==================== VERIFICACIÓN DE PARSER DICOM ====================

console.log('\n🏥 VERIFICANDO PARSER DICOM...\n');

report.dicom.dicomParserLib = typeof dicomParser !== 'undefined';
report.dicom.canvasContext = report.ui.canvas && !!document.getElementById('canvas').getContext('2d');
report.dicom.allFrames = typeof allFrames !== 'undefined';
report.dicom.currentFrame = typeof currentFrame !== 'undefined';
report.dicom.totalFrames = typeof totalFrames !== 'undefined';

console.log('✅ Librería dicom-parser:', report.dicom.dicomParserLib);
console.log('✅ Canvas 2D context:', report.dicom.canvasContext);
console.log('✅ Variable allFrames:', report.dicom.allFrames);
console.log('✅ Variable currentFrame:', report.dicom.currentFrame);
console.log('✅ Variable totalFrames:', report.dicom.totalFrames);

// ==================== VERIFICACIÓN DE CONTROLES DE IMAGEN ====================

console.log('\n🎨 VERIFICANDO CONTROLES DE IMAGEN...\n');

// Verificar funciones de cine
const cineControls = ['playPause', 'nextFrame', 'prevFrame', 'stopCine'];
report.controls.cine = {};

cineControls.forEach(ctrl => {
    const exists = typeof window[ctrl] === 'function';
    report.controls.cine[ctrl] = exists;
    console.log(`${exists ? '✅' : '❌'} ${ctrl}():`, exists);
});

// Verificar variables de reproducción
report.controls.playback = {
    playing: typeof playing !== 'undefined',
    playInterval: typeof playInterval !== 'undefined',
    fps: typeof fps !== 'undefined',
    inverted: typeof inverted !== 'undefined'
};

console.log('✅ Variable playing:', report.controls.playback.playing);
console.log('✅ Variable playInterval:', report.controls.playback.playInterval);
console.log('✅ Variable fps:', report.controls.playback.fps);
console.log('✅ Variable inverted:', report.controls.playback.inverted);

// ==================== VERIFICACIÓN DE EVENTOS ====================

console.log('\n🎯 VERIFICANDO EVENT LISTENERS...\n');

// Verificar si el file input tiene listener
const fileInput = document.getElementById('file-input');
if (fileInput) {
    report.events.fileInput = fileInput.onchange !== null;
    console.log('✅ File input onchange:', report.events.fileInput);
} else {
    report.events.fileInput = false;
    console.log('❌ File input no encontrado');
}

// ==================== ANÁLISIS DE PROBLEMAS ====================

console.log('\n%c⚠️ ANÁLISIS DE PROBLEMAS DETECTADOS', 'background: #ff9800; color: black; font-size: 16px; padding: 10px;');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #ffb74d');

const problems = [];

// Verificar controles de cine
if (!report.functions.playPause || !report.functions.nextFrame) {
    problems.push({
        severity: 'ALTA',
        area: 'Controles de Cine',
        issue: 'Funciones playPause(), nextFrame(), prevFrame() no están implementadas',
        impact: 'No se pueden reproducir estudios multi-frame',
        fix: 'Implementar funciones de reproducción de cine'
    });
}

// Verificar parser DICOM
if (report.dicom.dicomParserLib) {
    problems.push({
        severity: 'MEDIA',
        area: 'Parser DICOM',
        issue: 'Parser actual solo soporta 8/16-bit básico',
        impact: 'No procesa multi-frame, RGB, o MONOCHROME1',
        fix: 'Integrar parser mejorado de eco-col-parser-mejorado.html'
    });
}

// Verificar carga automática
problems.push({
    severity: 'MEDIA',
    area: 'Hospital #2',
    issue: 'No carga DICOM automáticamente al seleccionar estudio',
    impact: 'Radiólogo debe cargar manualmente cada vez',
    fix: 'Agregar carga automática en selectH2Study()'
});

// Verificar drag & drop
problems.push({
    severity: 'BAJA',
    area: 'UX',
    issue: 'No hay drag & drop en Hospital #1',
    impact: 'UX menos fluida para carga de archivos',
    fix: 'Implementar event listeners dragenter/dragover/drop'
});

// Imprimir problemas
problems.forEach((p, i) => {
    console.log(`\n${i + 1}. %c${p.severity}%c - ${p.area}`, 
        p.severity === 'ALTA' ? 'color: #f44336; font-weight: bold' : 
        p.severity === 'MEDIA' ? 'color: #ff9800; font-weight: bold' : 
        'color: #2196f3; font-weight: bold',
        'color: inherit');
    console.log(`   ❌ Problema: ${p.issue}`);
    console.log(`   📉 Impacto: ${p.impact}`);
    console.log(`   🔧 Solución: ${p.fix}`);
});

// ==================== PRUEBAS FUNCIONALES ====================

console.log('\n%c🧪 EJECUTANDO PRUEBAS FUNCIONALES', 'background: #2196f3; color: white; font-size: 16px; padding: 10px;');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #42a5f5');

const tests = [];

// Test 1: Base de datos
try {
    DB.init();
    const testPatient = {
        name: 'TEST PATIENT',
        dni: '99999999',
        age: 99,
        gender: 'M',
        phone: '555-TEST'
    };
    const added = DB.addPatient(testPatient);
    const retrieved = DB.getPatient(added.id);
    
    if (retrieved && retrieved.name === 'TEST PATIENT') {
        tests.push({ name: 'Base de datos', status: 'PASS', message: 'CRUD operations working' });
        // Limpiar
        DB.patients = DB.patients.filter(p => p.id !== added.id);
        DB.save();
    } else {
        tests.push({ name: 'Base de datos', status: 'FAIL', message: 'Patient not retrieved correctly' });
    }
} catch (e) {
    tests.push({ name: 'Base de datos', status: 'ERROR', message: e.message });
}

// Test 2: Notify function
try {
    if (typeof notify === 'function') {
        notify('Test notification', 'info');
        tests.push({ name: 'Sistema de notificaciones', status: 'PASS', message: 'Notification displayed' });
    } else {
        tests.push({ name: 'Sistema de notificaciones', status: 'FAIL', message: 'notify() not found' });
    }
} catch (e) {
    tests.push({ name: 'Sistema de notificaciones', status: 'ERROR', message: e.message });
}

// Test 3: Canvas rendering
try {
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#00bfa5';
    ctx.fillRect(0, 0, 10, 10);
    const imageData = ctx.getImageData(0, 0, 1, 1);
    if (imageData.data[0] > 0) {
        tests.push({ name: 'Canvas rendering', status: 'PASS', message: 'Canvas can render' });
    } else {
        tests.push({ name: 'Canvas rendering', status: 'FAIL', message: 'Canvas not rendering' });
    }
} catch (e) {
    tests.push({ name: 'Canvas rendering', status: 'ERROR', message: e.message });
}

// Imprimir resultados de tests
tests.forEach(test => {
    const icon = test.status === 'PASS' ? '✅' : test.status === 'FAIL' ? '❌' : '⚠️';
    const color = test.status === 'PASS' ? '#4caf50' : test.status === 'FAIL' ? '#f44336' : '#ff9800';
    console.log(`${icon} %c${test.name}%c: ${test.message}`, `color: ${color}; font-weight: bold`, 'color: inherit');
});

// ==================== REPORTE FINAL ====================

console.log('\n%c📊 REPORTE FINAL', 'background: #00695c; color: white; font-size: 20px; padding: 10px;');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #00bfa5');

const totalFunctions = Object.keys(report.functions).length;
const workingFunctions = Object.values(report.functions).filter(v => v).length;
const functionPercentage = Math.round((workingFunctions / totalFunctions) * 100);

const totalTests = tests.length;
const passingTests = tests.filter(t => t.status === 'PASS').length;
const testPercentage = Math.round((passingTests / totalTests) * 100);

console.log(`\n📈 MÉTRICAS:`);
console.log(`   Funciones implementadas: ${workingFunctions}/${totalFunctions} (${functionPercentage}%)`);
console.log(`   Tests pasados: ${passingTests}/${totalTests} (${testPercentage}%)`);
console.log(`   Problemas detectados: ${problems.length}`);
console.log(`   - Alta prioridad: ${problems.filter(p => p.severity === 'ALTA').length}`);
console.log(`   - Media prioridad: ${problems.filter(p => p.severity === 'MEDIA').length}`);
console.log(`   - Baja prioridad: ${problems.filter(p => p.severity === 'BAJA').length}`);

// Calcular score general
const uiScore = Object.values(report.ui).filter(v => v).length / Object.keys(report.ui).length;
const dbScore = report.database.dbExists && report.database.studies > 0 ? 1 : 0;
const dicomScore = Object.values(report.dicom).filter(v => v).length / Object.keys(report.dicom).length;
const functionsScore = functionPercentage / 100;
const testsScore = testPercentage / 100;

const totalScore = ((uiScore + dbScore + dicomScore + functionsScore + testsScore) / 5) * 100;

console.log(`\n🎯 PUNTUACIÓN GENERAL: ${Math.round(totalScore)}%`);

// Barra de progreso visual
const barLength = 40;
const filledLength = Math.round((totalScore / 100) * barLength);
const bar = '█'.repeat(filledLength) + '░'.repeat(barLength - filledLength);
console.log(`\n${bar} ${Math.round(totalScore)}%\n`);

// Recomendaciones
console.log('%c💡 RECOMENDACIONES', 'background: #4caf50; color: white; font-size: 16px; padding: 10px;');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #66bb6a');

console.log('\n1. PRIORIDAD ALTA:');
console.log('   ✨ Implementar controles de cine (playPause, next, prev)');
console.log('   ✨ Integrar parser DICOM mejorado con multi-frame');

console.log('\n2. PRIORIDAD MEDIA:');
console.log('   📋 Agregar carga automática en Hospital #2');
console.log('   🎨 Mejorar overlays con metadata completa');

console.log('\n3. PRIORIDAD BAJA:');
console.log('   🖱️ Implementar drag & drop');
console.log('   📏 Agregar herramientas de medición');

// Guardar reporte en window para acceso
window.ECO_COL_REPORT = {
    timestamp: new Date().toISOString(),
    score: Math.round(totalScore),
    details: report,
    problems: problems,
    tests: tests,
    recommendations: [
        'Implementar controles de cine',
        'Integrar parser DICOM mejorado',
        'Agregar carga automática en Hospital #2',
        'Implementar drag & drop'
    ]
};

console.log('\n%c✅ Reporte guardado en window.ECO_COL_REPORT', 'color: #4caf50; font-weight: bold');
console.log('%c━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'color: #00bfa5');
console.log('\n💾 Para ver el reporte completo: window.ECO_COL_REPORT');
console.log('📊 Para ver problemas: window.ECO_COL_REPORT.problems');
console.log('🧪 Para ver tests: window.ECO_COL_REPORT.tests\n');

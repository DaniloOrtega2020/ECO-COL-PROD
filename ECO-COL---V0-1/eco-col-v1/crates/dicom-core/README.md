# dicom-core

Parser DICOM de alto rendimiento para ECO-COL V1.

## Características

- ✅ Parser completo del estándar DICOM PS3.5
- ✅ Soporte Explicit/Implicit VR
- ✅ Lazy loading de pixel data
- ✅ Performance <100ms para archivos de 500MB
- ✅ Validación robusta
- ✅ Manejo de errores exhaustivo

## Uso

```rust
use dicom_core::DicomParser;
use std::path::Path;

let parser = DicomParser::new();
let instance = parser.parse_file(Path::new("study.dcm"))?;

println!("Patient: {}", instance.patient_name());
println!("Study: {}", instance.study_uid());
```

## Performance

Target: <100ms para archivos de 500MB

Ejecutar benchmarks:
```bash
cargo bench
```

## Tests

```bash
cargo test
```

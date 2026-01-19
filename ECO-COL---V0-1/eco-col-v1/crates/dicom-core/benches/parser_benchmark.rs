//! Benchmarks para el parser DICOM

use criterion::{black_box, criterion_group, criterion_main, Criterion};
use dicom_core::DicomParser;

fn benchmark_parser_creation(c: &mut Criterion) {
    c.bench_function("parser_creation", |b| {
        b.iter(|| {
            let parser = DicomParser::new();
            black_box(parser);
        });
    });
}

// Nota: Para benchmarks con archivos reales, descomentar y agregar fixtures

/*
fn benchmark_parse_file(c: &mut Criterion) {
    use std::path::Path;
    
    let parser = DicomParser::new();
    let path = Path::new("tests/fixtures/sample.dcm");
    
    c.bench_function("parse_file", |b| {
        b.iter(|| {
            let result = parser.parse_file(black_box(path));
            black_box(result);
        });
    });
}
*/

criterion_group!(benches, benchmark_parser_creation);
criterion_main!(benches);

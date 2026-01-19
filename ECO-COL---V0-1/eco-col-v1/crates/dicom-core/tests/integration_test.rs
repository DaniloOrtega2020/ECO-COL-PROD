//! Tests de integración para dicom-core

use dicom_core::{DicomParser, ParseOptions};

#[test]
fn test_parser_with_default_options() {
    let parser = DicomParser::new();
    assert!(parser.is_ready());
}

#[test]
fn test_parser_with_custom_options() {
    let options = ParseOptions {
        validate_checksums: true,
        load_pixel_data: false,
        strict_validation: true,
        max_file_size: 1_000_000_000,
    };

    let parser = DicomParser::with_options(options);
    assert!(parser.is_ready());
}

// Nota: Para tests con archivos DICOM reales, necesitarás agregar
// fixtures en tests/fixtures/ y descomentar los siguientes tests

/*
#[test]
fn test_parse_real_dicom_file() {
    use std::path::Path;
    
    let parser = DicomParser::new();
    let path = Path::new("tests/fixtures/sample.dcm");
    
    let result = parser.parse_file(path);
    assert!(result.is_ok());
    
    let instance = result.unwrap();
    assert!(!instance.patient_name().is_empty());
    assert!(!instance.study_uid().is_empty());
}
*/

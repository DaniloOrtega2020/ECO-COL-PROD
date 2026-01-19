//! Validación de instancias DICOM

use crate::error::{DicomError, Result};
use crate::metadata::DicomMetadata;

/// Validar que una instancia DICOM tiene todos los campos requeridos
pub fn validate_instance(metadata: &DicomMetadata) -> Result<()> {
    // Validar Patient ID
    if metadata.patient_id.is_empty() {
        return Err(DicomError::validation("Patient ID no puede estar vacío"));
    }

    // Validar UIDs
    validate_uid(&metadata.study_instance_uid, "Study Instance UID")?;
    validate_uid(&metadata.series_instance_uid, "Series Instance UID")?;
    validate_uid(&metadata.sop_instance_uid, "SOP Instance UID")?;

    // Validar modalidad
    if metadata.modality.is_empty() {
        return Err(DicomError::validation("Modality no puede estar vacío"));
    }

    Ok(())
}

/// Validar formato de UID DICOM
fn validate_uid(uid: &str, name: &str) -> Result<()> {
    if uid.is_empty() {
        return Err(DicomError::validation(format!("{} no puede estar vacío", name)));
    }

    // UID debe contener solo números y puntos
    if !uid.chars().all(|c| c.is_ascii_digit() || c == '.') {
        return Err(DicomError::validation(format!(
            "{} contiene caracteres inválidos: {}",
            name, uid
        )));
    }

    // UID no debe empezar ni terminar con punto
    if uid.starts_with('.') || uid.ends_with('.') {
        return Err(DicomError::validation(format!(
            "{} no debe empezar ni terminar con punto: {}",
            name, uid
        )));
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_uid() {
        assert!(validate_uid("1.2.840.10008.5.1.4.1.1.1", "Test UID").is_ok());
    }

    #[test]
    fn test_invalid_uid_empty() {
        assert!(validate_uid("", "Test UID").is_err());
    }

    #[test]
    fn test_invalid_uid_chars() {
        assert!(validate_uid("1.2.abc.10008", "Test UID").is_err());
    }

    #[test]
    fn test_invalid_uid_dots() {
        assert!(validate_uid(".1.2.3.", "Test UID").is_err());
    }
}

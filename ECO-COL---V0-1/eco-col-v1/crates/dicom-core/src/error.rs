//! Error types para DICOM parsing

use thiserror::Error;

/// Resultado genérico para operaciones DICOM
pub type Result<T> = std::result::Result<T, DicomError>;

/// Errores que pueden ocurrir durante parsing DICOM
#[derive(Error, Debug)]
pub enum DicomError {
    #[error("Archivo no es DICOM válido: falta magic bytes 'DICM'")]
    InvalidMagicBytes,

    #[error("Transfer Syntax no soportada: {0}")]
    UnsupportedTransferSyntax(String),

    #[error("Tag DICOM inválido: {0}")]
    InvalidTag(String),

    #[error("VR (Value Representation) inválido: {0}")]
    InvalidVR(String),

    #[error("Longitud de valor inválida: esperado {expected}, encontrado {found}")]
    InvalidLength { expected: usize, found: usize },

    #[error("Datos de píxel corruptos o incompletos")]
    CorruptedPixelData,

    #[error("Tag requerido no encontrado: {0}")]
    MissingRequiredTag(String),

    #[error("Error de I/O: {0}")]
    Io(#[from] std::io::Error),

    #[error("Error de parsing: {0}")]
    ParseError(String),

    #[error("Error de validación: {0}")]
    ValidationError(String),

    #[error("Error interno: {0}")]
    Internal(String),
}

impl DicomError {
    /// Crea un error de parsing con mensaje custom
    pub fn parse(msg: impl Into<String>) -> Self {
        DicomError::ParseError(msg.into())
    }

    /// Crea un error de validación con mensaje custom
    pub fn validation(msg: impl Into<String>) -> Self {
        DicomError::ValidationError(msg.into())
    }

    /// Crea un error interno con mensaje custom
    pub fn internal(msg: impl Into<String>) -> Self {
        DicomError::Internal(msg.into())
    }
}

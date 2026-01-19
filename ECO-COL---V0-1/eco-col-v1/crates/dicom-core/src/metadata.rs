//! Estructuras de metadata DICOM

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

use crate::pixel::PixelDataDescriptor;

/// Instancia DICOM completa
#[derive(Debug, Clone)]
pub struct DicomInstance {
    /// Path del archivo original
    pub file_path: PathBuf,
    
    /// Metadata DICOM
    pub metadata: DicomMetadata,
    
    /// Descriptor de pixel data (lazy)
    pub pixel_descriptor: Option<PixelDataDescriptor>,
}

impl DicomInstance {
    /// Obtener nombre del paciente
    pub fn patient_name(&self) -> &str {
        &self.metadata.patient_name
    }

    /// Obtener modalidad
    pub fn modality(&self) -> &str {
        &self.metadata.modality
    }

    /// Obtener UID del estudio
    pub fn study_uid(&self) -> &str {
        &self.metadata.study_instance_uid
    }

    /// Obtener UID de la serie
    pub fn series_uid(&self) -> &str {
        &self.metadata.series_instance_uid
    }

    /// Obtener UID de la instancia (SOP Instance UID)
    pub fn instance_uid(&self) -> &str {
        &self.metadata.sop_instance_uid
    }
}

/// Metadata DICOM jerárquico (Patient > Study > Series > Instance)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DicomMetadata {
    // ============================================
    // Patient Level (0010,xxxx)
    // ============================================
    pub patient_id: String,
    pub patient_name: String,
    pub patient_birth_date: Option<String>,
    pub patient_sex: Option<String>,

    // ============================================
    // Study Level (0020,000D)
    // ============================================
    pub study_instance_uid: String,
    pub study_date: Option<String>,
    pub study_time: Option<String>,
    pub study_description: Option<String>,
    pub accession_number: Option<String>,

    // ============================================
    // Series Level (0020,000E)
    // ============================================
    pub series_instance_uid: String,
    pub series_number: Option<i32>,
    pub modality: String,
    pub series_description: Option<String>,

    // ============================================
    // Instance Level (0008,0018)
    // ============================================
    pub sop_instance_uid: String,
    pub instance_number: Option<i32>,
    pub transfer_syntax_uid: String,
}

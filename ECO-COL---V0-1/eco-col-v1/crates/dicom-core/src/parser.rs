//! Parser DICOM principal

use crate::error::{DicomError, Result};
use crate::metadata::{DicomInstance, DicomMetadata};
use crate::pixel::PixelDataDescriptor;
use crate::validation;

use dicom::object::{DefaultDicomObject, InMemDicomObject};
use dicom::dictionary_std::tags;
use std::path::Path;
use std::fs::File;
use std::io::{BufReader, Read, Seek, SeekFrom};

/// Opciones de parsing
#[derive(Debug, Clone)]
pub struct ParseOptions {
    /// Validar checksums de pixel data
    pub validate_checksums: bool,
    
    /// Cargar pixel data en memoria (false = lazy loading)
    pub load_pixel_data: bool,
    
    /// Validar estrictamente el estándar DICOM
    pub strict_validation: bool,
    
    /// Tamaño máximo de archivo en bytes (0 = sin límite)
    pub max_file_size: u64,
}

impl Default for ParseOptions {
    fn default() -> Self {
        Self {
            validate_checksums: false,
            load_pixel_data: false,      // Lazy loading por defecto
            strict_validation: true,
            max_file_size: 2_000_000_000, // 2GB por defecto
        }
    }
}

/// Parser DICOM principal
pub struct DicomParser {
    options: ParseOptions,
}

impl DicomParser {
    /// Crear nuevo parser con opciones por defecto
    pub fn new() -> Self {
        Self {
            options: ParseOptions::default(),
        }
    }

    /// Crear parser con opciones custom
    pub fn with_options(options: ParseOptions) -> Self {
        Self { options }
    }

    /// Verificar si el parser está listo
    pub fn is_ready(&self) -> bool {
        true
    }

    /// Parsear archivo DICOM desde path
    pub fn parse_file(&self, path: &Path) -> Result<DicomInstance> {
        // Validar que el archivo existe
        if !path.exists() {
            return Err(DicomError::Io(std::io::Error::new(
                std::io::ErrorKind::NotFound,
                format!("Archivo no encontrado: {:?}", path),
            )));
        }

        // Validar tamaño del archivo
        let metadata = std::fs::metadata(path)?;
        if self.options.max_file_size > 0 && metadata.len() > self.options.max_file_size {
            return Err(DicomError::validation(format!(
                "Archivo demasiado grande: {} bytes (máximo: {})",
                metadata.len(),
                self.options.max_file_size
            )));
        }

        // Abrir archivo
        let file = File::open(path)?;
        let mut reader = BufReader::new(file);

        // Validar magic bytes DICOM
        self.validate_magic_bytes(&mut reader)?;

        // Parsear con dicom-rs
        let obj = InMemDicomObject::read_from(&mut reader)
            .map_err(|e| DicomError::parse(format!("Error parsing DICOM: {}", e)))?;

        // Extraer metadata
        let metadata = self.extract_metadata(&obj)?;

        // Extraer descriptor de pixel data (sin cargar datos)
        let pixel_descriptor = if self.options.load_pixel_data {
            Some(self.extract_pixel_data(&obj)?)
        } else {
            Some(self.extract_pixel_descriptor(&obj)?)
        };

        // Validar si está habilitado
        if self.options.strict_validation {
            validation::validate_instance(&metadata)?;
        }

        Ok(DicomInstance {
            file_path: path.to_path_buf(),
            metadata,
            pixel_descriptor,
        })
    }

    /// Validar magic bytes "DICM" en posición 128
    fn validate_magic_bytes<R: Read + Seek>(&self, reader: &mut R) -> Result<()> {
        // DICOM tiene 128 bytes de preamble, luego "DICM"
        reader.seek(SeekFrom::Start(128))?;
        
        let mut magic = [0u8; 4];
        reader.read_exact(&mut magic)?;

        if &magic != b"DICM" {
            return Err(DicomError::InvalidMagicBytes);
        }

        // Volver al inicio para parsing completo
        reader.seek(SeekFrom::Start(0))?;
        
        Ok(())
    }

    /// Extraer metadata del objeto DICOM
    fn extract_metadata(&self, obj: &DefaultDicomObject) -> Result<DicomMetadata> {
        Ok(DicomMetadata {
            // Patient Level
            patient_id: self.get_string(obj, tags::PATIENT_ID)?,
            patient_name: self.get_string(obj, tags::PATIENT_NAME)?,
            patient_birth_date: self.get_string_opt(obj, tags::PATIENT_BIRTH_DATE),
            patient_sex: self.get_string_opt(obj, tags::PATIENT_SEX),

            // Study Level
            study_instance_uid: self.get_string(obj, tags::STUDY_INSTANCE_UID)?,
            study_date: self.get_string_opt(obj, tags::STUDY_DATE),
            study_time: self.get_string_opt(obj, tags::STUDY_TIME),
            study_description: self.get_string_opt(obj, tags::STUDY_DESCRIPTION),
            accession_number: self.get_string_opt(obj, tags::ACCESSION_NUMBER),

            // Series Level
            series_instance_uid: self.get_string(obj, tags::SERIES_INSTANCE_UID)?,
            series_number: self.get_integer_opt(obj, tags::SERIES_NUMBER),
            modality: self.get_string(obj, tags::MODALITY)?,
            series_description: self.get_string_opt(obj, tags::SERIES_DESCRIPTION),

            // Instance Level
            sop_instance_uid: self.get_string(obj, tags::SOP_INSTANCE_UID)?,
            instance_number: self.get_integer_opt(obj, tags::INSTANCE_NUMBER),
            transfer_syntax_uid: self.get_string(obj, tags::TRANSFER_SYNTAX_UID)
                .unwrap_or_else(|_| "1.2.840.10008.1.2.1".to_string()), // Default: Explicit VR Little Endian
        })
    }

    /// Extraer descriptor de pixel data (sin cargar píxeles)
    fn extract_pixel_descriptor(&self, obj: &DefaultDicomObject) -> Result<PixelDataDescriptor> {
        Ok(PixelDataDescriptor {
            rows: self.get_integer(obj, tags::ROWS)? as u32,
            columns: self.get_integer(obj, tags::COLUMNS)? as u32,
            bits_allocated: self.get_integer(obj, tags::BITS_ALLOCATED)? as u16,
            bits_stored: self.get_integer(obj, tags::BITS_STORED)? as u16,
            high_bit: self.get_integer(obj, tags::HIGH_BIT)? as u16,
            photometric_interpretation: self.get_string(obj, tags::PHOTOMETRIC_INTERPRETATION)?,
            samples_per_pixel: self.get_integer(obj, tags::SAMPLES_PER_PIXEL)? as u16,
            pixel_representation: self.get_integer(obj, tags::PIXEL_REPRESENTATION)? as u16,
        })
    }

    /// Extraer pixel data completo (carga en memoria)
    fn extract_pixel_data(&self, _obj: &DefaultDicomObject) -> Result<PixelDataDescriptor> {
        // Por ahora, solo extraemos el descriptor
        // La carga real de píxeles se implementará cuando sea necesario
        self.extract_pixel_descriptor(_obj)
    }

    // ============================================
    // Utilidades para extraer tags
    // ============================================

    fn get_string(&self, obj: &DefaultDicomObject, tag: dicom::core::Tag) -> Result<String> {
        obj.element(tag)
            .map_err(|_| DicomError::MissingRequiredTag(format!("{:?}", tag)))?
            .to_str()
            .map(|s| s.to_string())
            .map_err(|e| DicomError::parse(format!("Error converting tag {:?}: {}", tag, e)))
    }

    fn get_string_opt(&self, obj: &DefaultDicomObject, tag: dicom::core::Tag) -> Option<String> {
        obj.element(tag)
            .ok()
            .and_then(|e| e.to_str().ok())
            .map(|s| s.to_string())
    }

    fn get_integer(&self, obj: &DefaultDicomObject, tag: dicom::core::Tag) -> Result<i32> {
        obj.element(tag)
            .map_err(|_| DicomError::MissingRequiredTag(format!("{:?}", tag)))?
            .to_int::<i32>()
            .map_err(|e| DicomError::parse(format!("Error converting tag {:?}: {}", tag, e)))
    }

    fn get_integer_opt(&self, obj: &DefaultDicomObject, tag: dicom::core::Tag) -> Option<i32> {
        obj.element(tag)
            .ok()
            .and_then(|e| e.to_int::<i32>().ok())
    }
}

impl Default for DicomParser {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parser_creation() {
        let parser = DicomParser::new();
        assert!(parser.is_ready());
    }

    #[test]
    fn test_custom_options() {
        let options = ParseOptions {
            validate_checksums: true,
            load_pixel_data: true,
            strict_validation: false,
            max_file_size: 1_000_000,
        };
        
        let parser = DicomParser::with_options(options);
        assert!(parser.is_ready());
    }
}

//! Estructuras para pixel data

use serde::{Deserialize, Serialize};

/// Descriptor de pixel data (sin los píxeles en sí)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PixelDataDescriptor {
    /// Altura en píxeles
    pub rows: u32,
    
    /// Ancho en píxeles
    pub columns: u32,
    
    /// Bits asignados por píxel (8, 16, etc.)
    pub bits_allocated: u16,
    
    /// Bits almacenados (puede ser menor que bits_allocated)
    pub bits_stored: u16,
    
    /// Bit más significativo
    pub high_bit: u16,
    
    /// Interpretación fotométrica (MONOCHROME1, MONOCHROME2, RGB, etc.)
    pub photometric_interpretation: String,
    
    /// Muestras por píxel (1 para grayscale, 3 para RGB)
    pub samples_per_pixel: u16,
    
    /// Representación de píxel (0 = unsigned, 1 = signed)
    pub pixel_representation: u16,
}

impl PixelDataDescriptor {
    /// Calcular tamaño total en bytes del pixel data
    pub fn total_size_bytes(&self) -> usize {
        let bytes_per_pixel = (self.bits_allocated / 8) as usize;
        (self.rows as usize) * (self.columns as usize) * bytes_per_pixel * (self.samples_per_pixel as usize)
    }

    /// Verificar si es imagen monocromática
    pub fn is_monochrome(&self) -> bool {
        self.photometric_interpretation.starts_with("MONOCHROME")
    }

    /// Verificar si es imagen RGB
    pub fn is_rgb(&self) -> bool {
        self.photometric_interpretation == "RGB"
    }
}

/// Pixel data cargado en memoria
#[derive(Debug, Clone)]
pub struct PixelData {
    pub descriptor: PixelDataDescriptor,
    pub data: Vec<u8>,
}

impl PixelData {
    /// Crear pixel data vacío con descriptor
    pub fn new(descriptor: PixelDataDescriptor) -> Self {
        let size = descriptor.total_size_bytes();
        Self {
            descriptor,
            data: vec![0; size],
        }
    }

    /// Obtener píxel en posición (x, y)
    pub fn get_pixel(&self, x: u32, y: u32) -> Option<u16> {
        if x >= self.descriptor.columns || y >= self.descriptor.rows {
            return None;
        }

        let bytes_per_pixel = (self.descriptor.bits_allocated / 8) as usize;
        let offset = ((y * self.descriptor.columns + x) as usize) * bytes_per_pixel;

        if offset + bytes_per_pixel > self.data.len() {
            return None;
        }

        // Leer valor (asumiendo little endian)
        if bytes_per_pixel == 2 {
            Some(u16::from_le_bytes([
                self.data[offset],
                self.data[offset + 1],
            ]))
        } else {
            Some(self.data[offset] as u16)
        }
    }
}

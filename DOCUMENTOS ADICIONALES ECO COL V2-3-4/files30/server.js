// ==================== ECO-COL BACKEND SERVER ====================
// Node.js + Express + JWT + File Upload + PostgreSQL
// Author: Senior Staff Engineer - Medical Imaging Specialist

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const { Pool } = require('pg');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

// ==================== CONFIGURATION ====================
const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'eco-col-secret-key-change-in-production';
const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads/dicom';

// Database connection
const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'ecocol',
    password: process.env.DB_PASSWORD || 'password',
    port: process.env.DB_PORT || 5432,
});

// ==================== MIDDLEWARE ====================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// File upload configuration
const storage = multer.diskStorage({
    destination: async (req, file, cb) => {
        const uploadPath = path.join(UPLOAD_DIR, req.user.id.toString());
        await fs.mkdir(uploadPath, { recursive: true });
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}.dcm`;
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50MB max
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'application/dicom' || file.originalname.match(/\.(dcm|dicom)$/i)) {
            cb(null, true);
        } else {
            cb(new Error('Only DICOM files allowed'));
        }
    }
});

// JWT Authentication Middleware
const authenticate = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) return res.status(401).json({ error: 'No token provided' });

        const decoded = jwt.verify(token, JWT_SECRET);
        const result = await pool.query('SELECT id, email, role, name FROM users WHERE id = $1', [decoded.id]);
        
        if (result.rows.length === 0) return res.status(401).json({ error: 'Invalid token' });
        
        req.user = result.rows[0];
        next();
    } catch (error) {
        res.status(401).json({ error: 'Authentication failed' });
    }
};

// ==================== DATABASE INITIALIZATION ====================
async function initDatabase() {
    const client = await pool.connect();
    try {
        // Users table
        await client.query(`
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                name VARCHAR(255) NOT NULL,
                role VARCHAR(50) NOT NULL CHECK (role IN ('hospital1', 'hospital2', 'admin')),
                specialty VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Patients table
        await client.query(`
            CREATE TABLE IF NOT EXISTS patients (
                id SERIAL PRIMARY KEY,
                external_id VARCHAR(50) UNIQUE,
                name VARCHAR(255) NOT NULL,
                dni VARCHAR(50),
                age INTEGER,
                gender VARCHAR(10),
                phone VARCHAR(50),
                created_by INTEGER REFERENCES users(id),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Studies table
        await client.query(`
            CREATE TABLE IF NOT EXISTS studies (
                id SERIAL PRIMARY KEY,
                external_id VARCHAR(50) UNIQUE,
                patient_id INTEGER REFERENCES patients(id),
                hospital VARCHAR(255),
                modality VARCHAR(10),
                status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'reading', 'completed')),
                observations TEXT,
                radiologist_id INTEGER REFERENCES users(id),
                dicom_file_path VARCHAR(500),
                dicom_metadata JSONB,
                created_by INTEGER REFERENCES users(id),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP
            )
        `);

        // Create default users
        const hashedPassword = await bcrypt.hash('demo123', 10);
        await client.query(`
            INSERT INTO users (email, password, name, role, specialty) 
            VALUES 
                ('hospital1@ecocol.com', $1, 'Hospital Regional Norte', 'hospital1', NULL),
                ('ortega@ecocol.com', $1, 'Dr. Danilo Ortega', 'hospital2', 'Radiología Abdominal'),
                ('martinez@ecocol.com', $1, 'Dra. María Martínez', 'hospital2', 'Eco. Obstétrica'),
                ('rodriguez@ecocol.com', $1, 'Dr. Carlos Rodríguez', 'hospital2', 'Eco. Cardíaca'),
                ('admin@ecocol.com', $1, 'Administrador Sistema', 'admin', NULL)
            ON CONFLICT (email) DO NOTHING
        `, [hashedPassword]);

        console.log('✅ Database initialized successfully');
    } finally {
        client.release();
    }
}

// ==================== AUTH ROUTES ====================

// Login
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const user = result.rows[0];
        const validPassword = await bcrypt.compare(password, user.password);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
                specialty: user.specialty
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Register
app.post('/api/auth/register', async (req, res) => {
    try {
        const { email, password, name, role, specialty } = req.body;
        
        const hashedPassword = await bcrypt.hash(password, 10);
        
        const result = await pool.query(
            'INSERT INTO users (email, password, name, role, specialty) VALUES ($1, $2, $3, $4, $5) RETURNING id, email, name, role',
            [email, hashedPassword, name, role, specialty]
        );

        res.status(201).json({ user: result.rows[0] });
    } catch (error) {
        if (error.code === '23505') { // Unique violation
            res.status(400).json({ error: 'Email already exists' });
        } else {
            res.status(500).json({ error: 'Internal server error' });
        }
    }
});

// ==================== PATIENT ROUTES ====================

// Get all patients
app.get('/api/patients', authenticate, async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM patients ORDER BY created_at DESC'
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch patients' });
    }
});

// Create patient
app.post('/api/patients', authenticate, async (req, res) => {
    try {
        const { name, dni, age, gender, phone } = req.body;
        
        const result = await pool.query(
            `INSERT INTO patients (external_id, name, dni, age, gender, phone, created_by) 
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [`PAC-${Date.now()}`, name, dni, age, gender, phone, req.user.id]
        );
        
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create patient' });
    }
});

// ==================== STUDY ROUTES ====================

// Get all studies
app.get('/api/studies', authenticate, async (req, res) => {
    try {
        const { status, radiologist_id } = req.query;
        
        let query = `
            SELECT s.*, p.name as patient_name, p.dni, u.name as radiologist_name
            FROM studies s
            LEFT JOIN patients p ON s.patient_id = p.id
            LEFT JOIN users u ON s.radiologist_id = u.id
            WHERE 1=1
        `;
        const params = [];
        
        if (status) {
            params.push(status);
            query += ` AND s.status = $${params.length}`;
        }
        
        if (radiologist_id) {
            params.push(radiologist_id);
            query += ` AND s.radiologist_id = $${params.length}`;
        }
        
        query += ' ORDER BY s.created_at DESC';
        
        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch studies' });
    }
});

// Get single study
app.get('/api/studies/:id', authenticate, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT s.*, p.name as patient_name, p.dni, p.age, p.gender
             FROM studies s
             LEFT JOIN patients p ON s.patient_id = p.id
             WHERE s.id = $1`,
            [req.params.id]
        );
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Study not found' });
        }
        
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch study' });
    }
});

// Create study
app.post('/api/studies', authenticate, async (req, res) => {
    try {
        const { patient_id, hospital, modality } = req.body;
        
        const result = await pool.query(
            `INSERT INTO studies (external_id, patient_id, hospital, modality, created_by) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [`ECO-${Date.now()}`, patient_id, hospital, modality, req.user.id]
        );
        
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create study' });
    }
});

// Update study
app.put('/api/studies/:id', authenticate, async (req, res) => {
    try {
        const { observations, status } = req.body;
        
        const updates = [];
        const params = [];
        let paramCount = 1;
        
        if (observations !== undefined) {
            params.push(observations);
            updates.push(`observations = $${paramCount++}`);
        }
        
        if (status) {
            params.push(status);
            updates.push(`status = $${paramCount++}`);
            params.push(req.user.id);
            updates.push(`radiologist_id = $${paramCount++}`);
            
            if (status === 'completed') {
                updates.push(`completed_at = CURRENT_TIMESTAMP`);
            }
        }
        
        params.push(req.params.id);
        
        const result = await pool.query(
            `UPDATE studies SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
            params
        );
        
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to update study' });
    }
});

// ==================== DICOM FILE ROUTES ====================

// Upload DICOM
app.post('/api/dicom/upload/:studyId', authenticate, upload.single('dicom'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        // Update study with file path
        await pool.query(
            'UPDATE studies SET dicom_file_path = $1, dicom_metadata = $2 WHERE id = $3',
            [req.file.path, req.body.metadata || {}, req.params.studyId]
        );

        res.json({
            success: true,
            filename: req.file.filename,
            path: req.file.path,
            size: req.file.size
        });
    } catch (error) {
        console.error('Upload error:', error);
        res.status(500).json({ error: 'Failed to upload file' });
    }
});

// Download DICOM
app.get('/api/dicom/download/:studyId', authenticate, async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT dicom_file_path FROM studies WHERE id = $1',
            [req.params.studyId]
        );

        if (result.rows.length === 0 || !result.rows[0].dicom_file_path) {
            return res.status(404).json({ error: 'DICOM file not found' });
        }

        const filePath = result.rows[0].dicom_file_path;
        res.download(filePath);
    } catch (error) {
        res.status(500).json({ error: 'Failed to download file' });
    }
});

// ==================== STATISTICS ROUTES ====================

app.get('/api/stats', authenticate, async (req, res) => {
    try {
        const stats = await pool.query(`
            SELECT 
                COUNT(*) as total_studies,
                COUNT(*) FILTER (WHERE status = 'pending') as pending_studies,
                COUNT(*) FILTER (WHERE status = 'completed') as completed_studies,
                (SELECT COUNT(*) FROM patients) as total_patients
            FROM studies
        `);

        res.json(stats.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch statistics' });
    }
});

// ==================== HEALTH CHECK ====================

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ==================== START SERVER ====================

async function start() {
    try {
        await fs.mkdir(UPLOAD_DIR, { recursive: true });
        await initDatabase();
        
        app.listen(PORT, () => {
            console.log(`🚀 ECO-COL Backend running on port ${PORT}`);
            console.log(`📁 Upload directory: ${UPLOAD_DIR}`);
            console.log(`🔐 JWT authentication enabled`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

start();

module.exports = app;

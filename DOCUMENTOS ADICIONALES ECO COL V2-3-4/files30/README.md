# 🚀 ECO-COL BACKEND - Guía Completa

## 📋 Requisitos

- Node.js >= 16.0.0
- PostgreSQL >= 12
- npm o yarn

## ⚡ Instalación Rápida

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar base de datos PostgreSQL
createdb ecocol

# 3. Configurar variables de entorno
cp .env.example .env
# Edita .env con tus credenciales

# 4. Iniciar servidor
npm start
```

## 🔧 Configuración Detallada

### 1. PostgreSQL Setup

```bash
# macOS (con Homebrew)
brew install postgresql
brew services start postgresql

# Crear base de datos
createdb ecocol

# Crear usuario (opcional)
psql postgres
CREATE USER ecocol_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ecocol TO ecocol_user;
```

### 2. Variables de Entorno

Edita `.env`:

```env
PORT=3000
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=ecocol
JWT_SECRET=tu-secreto-super-largo-minimo-32-caracteres
UPLOAD_DIR=./uploads/dicom
```

### 3. Iniciar Servidor

```bash
# Producción
npm start

# Desarrollo (auto-reload)
npm run dev
```

## 🔌 API Endpoints

### Authentication

**POST** `/api/auth/login`
```json
{
  "email": "ortega@ecocol.com",
  "password": "demo123"
}
```

Response:
```json
{
  "token": "eyJhbGc...",
  "user": {
    "id": 2,
    "email": "ortega@ecocol.com",
    "name": "Dr. Danilo Ortega",
    "role": "hospital2",
    "specialty": "Radiología Abdominal"
  }
}
```

### Patients

**GET** `/api/patients`
- Requiere: Bearer Token
- Retorna: Lista de pacientes

**POST** `/api/patients`
```json
{
  "name": "García Pérez, Ana María",
  "dni": "12345678",
  "age": 45,
  "gender": "F",
  "phone": "555-0001"
}
```

### Studies

**GET** `/api/studies?status=pending`
- Filtros opcionales: `status`, `radiologist_id`

**POST** `/api/studies`
```json
{
  "patient_id": 1,
  "hospital": "Hospital Regional Norte",
  "modality": "US"
}
```

**PUT** `/api/studies/:id`
```json
{
  "observations": "Hígado normal. Sin alteraciones.",
  "status": "completed"
}
```

### DICOM Files

**POST** `/api/dicom/upload/:studyId`
- Content-Type: multipart/form-data
- Field: `dicom` (file)
- Field: `metadata` (JSON string)

**GET** `/api/dicom/download/:studyId`
- Descarga archivo DICOM

### Statistics

**GET** `/api/stats`
```json
{
  "total_studies": 10,
  "pending_studies": 3,
  "completed_studies": 7,
  "total_patients": 5
}
```

## 🔐 Usuarios por Defecto

```
Email: hospital1@ecocol.com
Password: demo123
Role: hospital1

Email: ortega@ecocol.com
Password: demo123
Role: hospital2

Email: admin@ecocol.com
Password: demo123
Role: admin
```

## 💻 Uso desde Frontend

```javascript
// Inicializar cliente
const api = new EcoColAPI('http://localhost:3000/api');

// Login
const { token, user } = await api.login('ortega@ecocol.com', 'demo123');

// Obtener estudios
const studies = await api.getStudies({ status: 'pending' });

// Subir DICOM
await api.uploadDICOM(studyId, dicomFile, metadata);

// Completar estudio
await api.completeStudy(studyId, 'Observaciones médicas...');
```

## 📁 Estructura del Proyecto

```
backend/
├── server.js           # Servidor principal
├── package.json        # Dependencias
├── .env               # Configuración (no subir a git)
├── .env.example       # Template de configuración
├── client.js          # Cliente JavaScript para frontend
└── uploads/
    └── dicom/         # Archivos DICOM subidos
```

## 🔒 Seguridad

- JWT tokens con expiración 24h
- Contraseñas hasheadas con bcrypt (10 rounds)
- Validación de tipos de archivo
- Límite de tamaño: 50MB por archivo
- CORS configurado
- Rate limiting (próximamente)

## 🚀 Deploy en Producción

### Opción A: Heroku

```bash
# 1. Crear app
heroku create ecocol-backend

# 2. Agregar PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# 3. Configurar variables
heroku config:set JWT_SECRET=your-secret

# 4. Deploy
git push heroku main
```

### Opción B: DigitalOcean

1. Crear Droplet (Ubuntu 20.04)
2. Instalar Node.js y PostgreSQL
3. Clonar repositorio
4. Configurar variables de entorno
5. Usar PM2 para mantener servidor activo

```bash
npm install -g pm2
pm2 start server.js --name ecocol-backend
pm2 save
pm2 startup
```

### Opción C: AWS

- EC2 para servidor Node.js
- RDS para PostgreSQL
- S3 para almacenar archivos DICOM
- CloudFront como CDN

## 🧪 Testing

```bash
npm test
```

## 📊 Monitoreo

```bash
# Ver logs
pm2 logs ecocol-backend

# Estadísticas
pm2 monit
```

## ⚠️ Troubleshooting

### Error: "ECONNREFUSED"
- Verifica que PostgreSQL esté corriendo
- Revisa credenciales en .env

### Error: "JWT malformed"
- Token inválido o expirado
- Hacer login nuevamente

### Error: "File too large"
- Archivo DICOM >50MB
- Aumentar MAX_FILE_SIZE en .env

## 🔄 Actualizar a Producción

```bash
# 1. Pull últimos cambios
git pull

# 2. Instalar dependencias
npm install

# 3. Restart servidor
pm2 restart ecocol-backend
```

## 📞 Soporte

- GitHub Issues: [repositorio]
- Email: support@ecocol.com

---

**Versión:** 2.0.0  
**Última actualización:** Enero 2026

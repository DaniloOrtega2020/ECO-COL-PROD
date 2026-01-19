-- ECO-COL V1 - Database Schema
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA foreign_keys = ON;
PRAGMA auto_vacuum = INCREMENTAL;

CREATE TABLE IF NOT EXISTS patients (
    patient_id TEXT PRIMARY KEY,
    patient_name TEXT NOT NULL,
    patient_birth_date TEXT,
    patient_sex TEXT CHECK(patient_sex IN ('M','F','O')),
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    last_accessed INTEGER NOT NULL DEFAULT (unixepoch())
) STRICT;

CREATE TABLE IF NOT EXISTS studies (
    study_instance_uid TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    study_date TEXT NOT NULL,
    study_time TEXT,
    study_description TEXT,
    accession_number TEXT,
    referring_physician TEXT,
    retention_expires_at INTEGER NOT NULL,
    is_archived INTEGER NOT NULL DEFAULT 0,
    archived_at INTEGER,
    deletion_scheduled_at INTEGER,
    has_completed_report INTEGER NOT NULL DEFAULT 0,
    is_protected INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS series (
    series_instance_uid TEXT PRIMARY KEY,
    study_instance_uid TEXT NOT NULL,
    modality TEXT NOT NULL,
    series_number INTEGER,
    series_description TEXT,
    body_part_examined TEXT,
    frame_rate REAL,
    number_of_instances INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    FOREIGN KEY (study_instance_uid) REFERENCES studies(study_instance_uid) ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS instances (
    sop_instance_uid TEXT PRIMARY KEY,
    series_instance_uid TEXT NOT NULL,
    instance_number INTEGER,
    transfer_syntax_uid TEXT NOT NULL,
    rows INTEGER NOT NULL,
    columns INTEGER NOT NULL,
    bits_allocated INTEGER NOT NULL,
    bits_stored INTEGER NOT NULL,
    photometric_interpretation TEXT NOT NULL,
    file_path TEXT NOT NULL UNIQUE,
    file_size_bytes INTEGER NOT NULL,
    file_sha256 TEXT NOT NULL,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    FOREIGN KEY (series_instance_uid) REFERENCES series(series_instance_uid) ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS radiologists (
    radiologist_id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    license_number TEXT UNIQUE NOT NULL,
    specialization TEXT,
    email TEXT,
    private_key_pem TEXT NOT NULL,
    public_key_pem TEXT NOT NULL,
    certificate_pem TEXT,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    is_active INTEGER NOT NULL DEFAULT 1
) STRICT;

CREATE TABLE IF NOT EXISTS worklist_assignments (
    study_instance_uid TEXT PRIMARY KEY,
    assigned_to_radiologist TEXT,
    claimed_at INTEGER,
    locked_until INTEGER,
    status TEXT NOT NULL CHECK(status IN ('pending','in_progress','completed','rejected')) DEFAULT 'pending',
    urgency TEXT NOT NULL CHECK(urgency IN ('routine','urgent','stat')) DEFAULT 'routine',
    priority_score INTEGER NOT NULL DEFAULT 0,
    assigned_at INTEGER NOT NULL DEFAULT (unixepoch()),
    completed_at INTEGER,
    FOREIGN KEY (study_instance_uid) REFERENCES studies(study_instance_uid) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_radiologist) REFERENCES radiologists(radiologist_id) ON DELETE SET NULL
) STRICT;

CREATE TABLE IF NOT EXISTS annotations (
    annotation_id TEXT PRIMARY KEY,
    study_instance_uid TEXT NOT NULL,
    series_instance_uid TEXT,
    instance_sop_uid TEXT,
    radiologist_id TEXT NOT NULL,
    annotation_type TEXT NOT NULL CHECK(annotation_type IN ('measurement_length','measurement_area','measurement_volume','text_note','arrow','circle','rectangle','polyline')),
    data_json TEXT NOT NULL,
    vector_clock_json TEXT NOT NULL,
    lamport_timestamp INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL DEFAULT 0,
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    modified_at INTEGER NOT NULL DEFAULT (unixepoch()),
    FOREIGN KEY (study_instance_uid) REFERENCES studies(study_instance_uid) ON DELETE CASCADE,
    FOREIGN KEY (radiologist_id) REFERENCES radiologists(radiologist_id)
) STRICT;

CREATE TABLE IF NOT EXISTS reports (
    report_id TEXT PRIMARY KEY,
    study_instance_uid TEXT NOT NULL UNIQUE,
    radiologist_id TEXT NOT NULL,
    findings TEXT NOT NULL,
    conclusions TEXT NOT NULL,
    recommendations TEXT,
    pdf_file_path TEXT NOT NULL,
    pdf_size_bytes INTEGER NOT NULL,
    pdf_sha256 TEXT NOT NULL,
    signature_sha256 TEXT NOT NULL,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    signed_at INTEGER NOT NULL,
    FOREIGN KEY (study_instance_uid) REFERENCES studies(study_instance_uid) ON DELETE CASCADE,
    FOREIGN KEY (radiologist_id) REFERENCES radiologists(radiologist_id)
) STRICT;

CREATE TABLE IF NOT EXISTS sync_queue (
    queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
    peer_ae_title TEXT NOT NULL,
    peer_hostname TEXT NOT NULL,
    peer_port INTEGER NOT NULL,
    operation TEXT NOT NULL CHECK(operation IN ('send_study','send_report','send_annotations','send_worklist_update')),
    payload_type TEXT NOT NULL,
    payload_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('pending','in_progress','completed','failed')) DEFAULT 'pending',
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 5,
    last_error TEXT,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    next_retry_at INTEGER NOT NULL DEFAULT (unixepoch()),
    completed_at INTEGER
) STRICT;

CREATE TABLE IF NOT EXISTS known_peers (
    peer_id TEXT PRIMARY KEY,
    ae_title TEXT UNIQUE NOT NULL,
    hostname TEXT NOT NULL,
    dicom_port INTEGER NOT NULL DEFAULT 11112,
    notification_port INTEGER NOT NULL DEFAULT 9999,
    last_seen INTEGER NOT NULL DEFAULT (unixepoch()),
    is_reachable INTEGER NOT NULL DEFAULT 1,
    supports_c_store INTEGER NOT NULL DEFAULT 1,
    supports_c_find INTEGER NOT NULL DEFAULT 1,
    supports_c_get INTEGER NOT NULL DEFAULT 1,
    total_studies_sent INTEGER NOT NULL DEFAULT 0,
    total_studies_received INTEGER NOT NULL DEFAULT 0,
    last_sync_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT (unixepoch())
) STRICT;

CREATE TABLE IF NOT EXISTS audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,
    event_category TEXT NOT NULL CHECK(event_category IN ('data_access','data_modification','system','security')),
    user_id TEXT,
    peer_ae_title TEXT,
    description TEXT NOT NULL,
    entity_type TEXT,
    entity_id TEXT,
    ip_address TEXT,
    hostname TEXT,
    created_at INTEGER NOT NULL DEFAULT (unixepoch())
) STRICT;

CREATE TABLE IF NOT EXISTS system_config (
    config_key TEXT PRIMARY KEY,
    config_value TEXT NOT NULL,
    config_type TEXT NOT NULL CHECK(config_type IN ('string','integer','boolean','json')),
    description TEXT,
    updated_at INTEGER NOT NULL DEFAULT (unixepoch())
) STRICT;

-- Índices
CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(patient_name);
CREATE INDEX IF NOT EXISTS idx_studies_patient ON studies(patient_id, study_date DESC);
CREATE INDEX IF NOT EXISTS idx_series_study ON series(study_instance_uid);
CREATE INDEX IF NOT EXISTS idx_instances_series ON instances(series_instance_uid);
CREATE INDEX IF NOT EXISTS idx_worklist_status ON worklist_assignments(status, priority_score DESC);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_log(created_at DESC);

-- Configuración inicial
INSERT OR IGNORE INTO system_config VALUES ('node_ae_title', 'ECO_COL_NODE_1', 'string', 'AE Title', unixepoch());
INSERT OR IGNORE INTO system_config VALUES ('dicom_port', '11112', 'integer', 'Puerto DICOM', unixepoch());
INSERT OR IGNORE INTO system_config VALUES ('retention_days', '15', 'integer', 'Días de retención', unixepoch());

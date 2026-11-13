-- FieldOps schema for Cloudflare D1
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, phone TEXT,
  pin_hash TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('employee','admin')),
  active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS attendance (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  type TEXT NOT NULL CHECK(type IN ('clockin','clockout')),
  lat REAL NOT NULL, lng REAL NOT NULL, accuracy REAL, photo_key TEXT,
  work_date TEXT NOT NULL, ts TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_attendance_user_date ON attendance(user_id, work_date);
CREATE TABLE IF NOT EXISTS locations (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  lat REAL NOT NULL, lng REAL NOT NULL, accuracy REAL, ts TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_locations_user_ts ON locations(user_id, ts);
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  expense_date TEXT NOT NULL, category TEXT NOT NULL, amount REAL NOT NULL,
  description TEXT, receipt_key TEXT,
  status TEXT NOT NULL DEFAULT 'submitted' CHECK(status IN ('submitted','approved','rejected')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS leave_requests (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  start_date TEXT NOT NULL, end_date TEXT NOT NULL, reason TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','rejected')),
  decided_by TEXT REFERENCES users(id), decided_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bike_readings (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  work_date TEXT NOT NULL, type TEXT NOT NULL CHECK(type IN ('start','end')),
  reading_km REAL NOT NULL, source TEXT NOT NULL CHECK(source IN ('ocr','manual','ocr_edited')),
  ocr_confidence REAL, photo_key TEXT, ts TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_bike_user_date ON bike_readings(user_id, work_date);
CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
  expires_at TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

import "./../config/env.js";
import { pool } from "./pool.js";

const schema = `
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  facility_id TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS mothers (
  id UUID PRIMARY KEY,
  maternal_token TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  age INT NOT NULL,
  region TEXT,
  phone_enc TEXT,
  national_id_enc TEXT,
  consent_json JSONB NOT NULL,
  facility_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS visits (
  id UUID PRIMARY KEY,
  mother_id UUID NOT NULL REFERENCES mothers(id) ON DELETE CASCADE,
  visit_date TIMESTAMPTZ NOT NULL DEFAULT now(),
  gest_week INT,
  bp_systolic INT,
  hb DOUBLE PRECISION,
  weight DOUBLE PRECISION,
  complications_history BOOLEAN DEFAULT false,
  pregnancy_interval_months INT,
  risk_json JSONB
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY,
  actor_user_id TEXT NOT NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
`;

const seed = `
INSERT INTO users (id, username, password, role, facility_id)
VALUES
 ('u1','agent1','pass123','AGENT','f1'),
 ('u2','admin1','pass123','ADMIN','f1')
ON CONFLICT (username) DO NOTHING;
`;

async function main() {
  await pool.query(schema);
  await pool.query(seed);
  await pool.end();
  console.log("Migration complete.");
}

main().catch(async (e) => {
  console.error(e);
  await pool.end();
  process.exit(1);
});

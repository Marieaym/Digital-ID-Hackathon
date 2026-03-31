import { v4 as uuidv4 } from "uuid";
import { pool } from "../db/pool.js";

export async function logAudit({ actorUserId, action, entityType, entityId, metadata = {} }) {
  await pool.query(
    `INSERT INTO audit_logs (id, actor_user_id, action, entity_type, entity_id, metadata)
     VALUES ($1,$2,$3,$4,$5,$6)`,
    [uuidv4(), actorUserId, action, entityType, entityId, JSON.stringify(metadata)]
  );
}

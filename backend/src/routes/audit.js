import express from "express";
import { requireAuth } from "../middlewares/auth.js";
import { pool } from "../db/pool.js";

const router = express.Router();
router.use(requireAuth);

router.get("/", async (req, res) => {
  const r = await pool.query("SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 200");
  res.json(r.rows);
});

export default router;

import express from "express";
import jwt from "jsonwebtoken";
import { pool } from "../db/pool.js";

const router = express.Router();

router.post("/login", async (req, res) => {
  const { username, password } = req.body || {};
  const r = await pool.query("SELECT * FROM users WHERE username=$1 AND password=$2", [username, password]);
  const u = r.rows[0];
  if (!u) return res.status(401).json({ error: "Invalid credentials" });

  const token = jwt.sign({ userId: u.id, role: u.role, facilityId: u.facility_id }, process.env.JWT_SECRET, { expiresIn: "12h" });
  res.json({ token, user: { id: u.id, username: u.username, role: u.role, facilityId: u.facility_id } });
});

export default router;

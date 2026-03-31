import express from "express";
import axios from "axios";
import { v4 as uuidv4 } from "uuid";
import { requireAuth } from "../middlewares/auth.js";
import { pool } from "../db/pool.js";
import { logAudit } from "../utils/audit.js";
import { encryptOptional, decryptOptional } from "../utils/crypto.js";
import { buildMotherFhirBundle } from "../utils/fhir.js";

const router = express.Router();
router.use(requireAuth);

router.post("/", async (req, res) => {
  const id = uuidv4();
  const maternalToken = `HM-${String(Date.now()).slice(-6)}`;

  const consent = req.body.consentJson;
  if (!consent || !consent.timestamp || !consent.language || !consent.signedBy) {
    return res.status(400).json({ error: "Missing consentJson" });
  }

  const phoneEnc = encryptOptional(req.body.phone);
  const nationalEnc = encryptOptional(req.body.nationalId || null);

  await pool.query(
    `INSERT INTO mothers (id, maternal_token, full_name, age, region, phone_enc, national_id_enc, consent_json, facility_id)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
    [id, maternalToken, req.body.fullName, req.body.age, req.body.region || null, phoneEnc, nationalEnc, JSON.stringify(consent), req.user.facilityId]
  );

  await logAudit({ actorUserId: req.user.userId, action: "CREATE_MOTHER", entityType: "mother", entityId: id, metadata: { facilityId: req.user.facilityId } });

  res.json({ id, maternalToken });
});

router.get("/", async (req, res) => {
  const q = (req.query.search || "").toString().toLowerCase();
  const params = [];
  let sql = "SELECT id, maternal_token, full_name, age, region, facility_id FROM mothers";
  if (req.user.role !== "ADMIN") {
    params.push(req.user.facilityId);
    sql += ` WHERE facility_id=$${params.length}`;
  }
  const r = await pool.query(sql, params);
  let rows = r.rows;

  if (q) {
    rows = rows.filter(m =>
      (m.full_name || "").toLowerCase().includes(q) || (m.maternal_token || "").includes(q)
    );
  }

  res.json(rows.map(m => ({
    id: m.id,
    maternalToken: m.maternal_token,
    fullName: m.full_name,
    age: m.age,
    region: m.region
  })));
});

router.get("/:id", async (req, res) => {
  const mR = await pool.query("SELECT * FROM mothers WHERE id=$1", [req.params.id]);
  const m = mR.rows[0];
  if (!m) return res.status(404).json({ error: "Not found" });
  if (req.user.role !== "ADMIN" && m.facility_id !== req.user.facilityId) return res.status(403).json({ error: "Forbidden" });

  const vR = await pool.query("SELECT * FROM visits WHERE mother_id=$1 ORDER BY visit_date ASC", [req.params.id]);

  res.json({
    id: m.id,
    maternalToken: m.maternal_token,
    fullName: m.full_name,
    age: m.age,
    region: m.region,
    phone: decryptOptional(m.phone_enc),
    nationalId: decryptOptional(m.national_id_enc),
    consentJson: m.consent_json,
    visits: vR.rows.map(v => ({
      id: v.id,
      visitDate: v.visit_date,
      gestWeek: v.gest_week,
      bpSystolic: v.bp_systolic,
      hb: v.hb,
      weight: v.weight,
      complicationsHistory: v.complications_history,
      pregnancyIntervalMonths: v.pregnancy_interval_months,
      risk: v.risk_json
    }))
  });
});

router.post("/:id/visits", async (req, res) => {
  const mR = await pool.query("SELECT * FROM mothers WHERE id=$1", [req.params.id]);
  const m = mR.rows[0];
  if (!m) return res.status(404).json({ error: "Mother not found" });
  if (req.user.role !== "ADMIN" && m.facility_id !== req.user.facilityId) return res.status(403).json({ error: "Forbidden" });

  const visitId = uuidv4();

  const visit = {
    id: visitId,
    mother_id: m.id,
    gest_week: req.body.gestWeek ?? null,
    bp_systolic: req.body.bpSystolic ?? null,
    hb: req.body.hb ?? null,
    weight: req.body.weight ?? null,
    complications_history: !!req.body.complicationsHistory,
    pregnancy_interval_months: req.body.pregnancyIntervalMonths ?? null,
  };

  const aiUrl = process.env.AI_URL || "http://localhost:8001/risk_score";
  const aiPayload = {
    age: m.age,
    bp_systolic: visit.bp_systolic ?? 0,
    hb: visit.hb ?? 0,
    complications_history: visit.complications_history,
    pregnancy_interval_months: visit.pregnancy_interval_months,
    gest_week: visit.gest_week,
  };

  const ai = await axios.post(aiUrl, aiPayload);
  const riskJson = ai.data;

  await pool.query(
    `INSERT INTO visits (id, mother_id, gest_week, bp_systolic, hb, weight, complications_history, pregnancy_interval_months, risk_json)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
    [visitId, m.id, visit.gest_week, visit.bp_systolic, visit.hb, visit.weight, visit.complications_history, visit.pregnancy_interval_months, JSON.stringify(riskJson)]
  );

  await logAudit({ actorUserId: req.user.userId, action: "ADD_VISIT", entityType: "visit", entityId: visitId, metadata: { motherId: m.id, riskLevel: riskJson.level, riskScore: riskJson.score } });

  res.json({
    id: visitId,
    motherId: m.id,
    risk: riskJson
  });
});

router.get("/:id/fhir", async (req, res) => {
  const mR = await pool.query("SELECT * FROM mothers WHERE id=$1", [req.params.id]);
  const m = mR.rows[0];
  if (!m) return res.status(404).json({ error: "Not found" });
  if (req.user.role !== "ADMIN" && m.facility_id !== req.user.facilityId) return res.status(403).json({ error: "Forbidden" });

  const vR = await pool.query("SELECT * FROM visits WHERE mother_id=$1 ORDER BY visit_date ASC", [req.params.id]);

  const mother = {
    id: m.id,
    maternal_token: m.maternal_token,
    full_name: m.full_name,
    age: m.age,
    region: m.region,
    phone: decryptOptional(m.phone_enc),
  };

  const visits = vR.rows.map(v => ({
    id: v.id,
    visit_date: v.visit_date,
    bp_systolic: v.bp_systolic,
    hb: v.hb,
    risk_json: v.risk_json
  }));

  res.json(buildMotherFhirBundle(mother, visits));
});

export default router;

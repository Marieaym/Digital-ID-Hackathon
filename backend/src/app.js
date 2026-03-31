import "./config/env.js";
import express from "express";
import cors from "cors";
import morgan from "morgan";
import authRoutes from "./routes/auth.js";
import motherRoutes from "./routes/mothers.js";
import auditRoutes from "./routes/audit.js";

const app = express();
app.use(cors());
app.use(express.json({ limit: "5mb" }));
app.use(morgan("dev"));

app.get("/health", (req, res) => res.json({ ok: true }));

app.use("/auth", authRoutes);
app.use("/mothers", motherRoutes);
app.use("/audit", auditRoutes);

export default app;

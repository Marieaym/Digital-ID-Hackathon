from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="HealthID Mama AI Risk Service")

class RiskRequest(BaseModel):
    age: int
    bp_systolic: int
    hb: float
    complications_history: bool = False
    pregnancy_interval_months: Optional[int] = None
    gest_week: Optional[int] = None

class RiskResponse(BaseModel):
    score: int
    level: str
    reasons: List[str]
    recommendations: List[str]

def clamp(v: int, lo: int = 0, hi: int = 100) -> int:
    return max(lo, min(hi, v))

@app.post("/risk_score", response_model=RiskResponse)
def risk_score(req: RiskRequest):
    score = 0
    reasons: List[str] = []
    recs: List[str] = []

    if req.age < 18 or req.age > 35:
        score += 20
        reasons.append("Âge maternel à risque (<18 ou >35).")
        recs.append("Renforcer le suivi prénatal et anticiper la référence si nécessaire.")

    if req.bp_systolic >= 140:
        score += 30
        reasons.append("Tension artérielle élevée (≥140).")
        recs.append("Contrôle TA rapproché + évaluation prééclampsie + référence si persistance.")

    if req.hb < 10:
        score += 20
        reasons.append("Anémie probable (Hb < 10).")
        recs.append("Supplémentation fer/folates + suivi nutritionnel.")

    if req.complications_history:
        score += 25
        reasons.append("Antécédents de complications.")
        recs.append("Plan de naissance + suivi spécialisé au centre de référence.")

    if req.pregnancy_interval_months is not None and req.pregnancy_interval_months < 24:
        score += 15
        reasons.append("Intervalle inter-grossesses court (<24 mois).")
        recs.append("Conseils + suivi rapproché.")

    score = clamp(score)
    level = "LOW" if score <= 30 else ("MODERATE" if score <= 60 else "HIGH")

    if not reasons:
        reasons = ["Aucun facteur majeur détecté dans les données fournies."]
        recs = ["Suivi prénatal standard + rappels rendez-vous."]

    return RiskResponse(score=score, level=level, reasons=reasons, recommendations=recs)

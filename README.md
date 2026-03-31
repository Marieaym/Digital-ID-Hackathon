# HealthID Mama — Prototype v2 (Flutter + Provider, Node.js + PostgreSQL, Python AI)

Adds:
- Consent screen (language + timestamp + signature)
- FHIR-shaped export (Bundle)
- PostgreSQL persistence (with optional field-level encryption in Node)

Repo contains:
- `mobile/` Flutter Android app (Provider)
- `backend/` Node.js/Express API (JWT auth, mothers, visits, audit, FHIR export) + PostgreSQL
- `ai_service/` Python FastAPI explainable risk scoring microservice

## Quick start (local)

### 1) AI service
```bash
cd ai_service
python -m venv .venv
# activate venv then:
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### 2) PostgreSQL (Docker)
```bash
cd backend
docker compose up -d
```

### 3) Backend
```bash
cd backend
npm i
cp .env.example .env
npm run migrate
npm run dev
```

### 4) Flutter (Android emulator)
Android emulator accesses host at `10.0.2.2`.
```bash
cd mobile
flutter pub get
flutter run
```

## Demo accounts
- Agent: `agent1` / `pass123`
- Admin: `admin1` / `pass123`

## MVP screens
- Login
- Home (list mothers + search + sync)
- Consent screen (language + timestamp + signature)
- Register Mother
- Mother Profile (visits + pending + last risk + Export FHIR)
- Add Visit (calls AI service)
- Audit Logs

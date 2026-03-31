# Run & Test Guide (VF)

## Prerequisites
- Node.js 18+
- Docker Desktop (or Docker Engine) for PostgreSQL
- Python 3.10+
- Flutter SDK + Android Studio (Android Emulator) or a physical Android phone

## 1) Start AI Service (FastAPI)
```bash
cd ai_service
python -m venv .venv
# activate venv (Windows: .venv\Scripts\activate) (Linux/mac: source .venv/bin/activate)
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```
Health check: open `http://localhost:8001/docs`

## 2) Start PostgreSQL (Docker)
```bash
cd backend
docker compose up -d
```
Check container:
```bash
docker ps
```

## 3) Run Backend (Node/Express)
```bash
cd backend
npm install
cp .env.example .env
npm run migrate
npm run dev
```
Health check:
```bash
curl http://localhost:5000/health
```

### Optional: Enable field encryption (AES-256-GCM)
In `backend/.env`, set `FIELD_ENCRYPTION_KEY_BASE64` to a 32-byte base64 key.
Example (Node):
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```
Paste the output into `.env`.

## 4) Run Mobile (Flutter)
### Android Emulator
The emulator reaches your machine via `10.0.2.2`. The app is already configured for:
- API: `http://10.0.2.2:5000`

Run:
```bash
cd mobile
flutter pub get
flutter run
```

## Demo Accounts
- Agent: `agent1` / `pass123`
- Admin: `admin1` / `pass123`

## Functional Test Script (5 minutes)
1. Login with `agent1/pass123`.
2. Tap **Register** → open **Consent**:
   - Choose language (FR/EN/HA demo)
   - Add signer name
   - Draw signature
   - Accept checkbox
3. Submit mother → you should see a token like `HM-xxxxxx`.
4. Open mother profile → **Add visit** → submit values:
   - BP 150, Hb 9.5, GW 28, complications=true → should return HIGH risk.
5. Offline test:
   - Stop backend (Ctrl+C) or turn off internet
   - Add visit → should save offline and show **PENDING** in profile
6. Restart backend → go Home → tap **Sync now**
   - Pending count decreases, visit becomes synced with risk.
7. In mother profile → tap **Export FHIR** → see a FHIR Bundle JSON.
8. Open **Audit Logs** → see CREATE_MOTHER / ADD_VISIT entries.

## Common Issues
- Mobile cannot reach API: ensure emulator uses `10.0.2.2` (not `localhost`).
- DB errors: confirm `docker compose up -d` and port 5432 is free.
- AI errors: ensure uvicorn runs on port 8001 and `AI_URL` in `.env` matches.

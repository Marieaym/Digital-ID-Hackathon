# Mama HealthID

**Maternal Digital Identity Layer for Interoperable Public Health Infrastructure in Africa**

> A working prototype built to address one of West Africa's most critical public health challenges: the absence of identity continuity in maternal care.

---

## The Problem

In Niger and across West Africa, maternal mortality is not only a clinical failure — it is a systems failure. Pregnant women move between clinics due to distance, insecurity, or rural mobility, and their medical histories disappear with each transition. Records are paper-based, fragmented, and impossible to transfer. High-risk pregnancies go undetected. Preventable deaths persist.

Mama HealthID was built to fix that.

---

## What It Does

Mama HealthID is a modular maternal digital identity system that transforms fragmented maternal records into a continuous, identity-driven care pathway. It is designed to work in environments with unreliable internet connectivity, limited infrastructure, and low digital literacy among frontline health workers.

The system is structured in five layers:

**Identity Layer** — Generates a privacy-preserving sectoral maternal ID token. Interoperable with national foundational IDs where available, and functional as a provisional ID where national coverage is low. Biometrics are used strictly for deduplication.

**Health Data Layer** — Maternal records are FHIR-compliant, structured, and interoperable. Offline-first design with encrypted local storage and automatic synchronization when connectivity is restored. API-first architecture supports integration with DHIS2 and national health platforms.

**AI Risk Engine** — An Explainable AI (XAI) microservice that provides interpretable maternal risk scores, referral alerts, and actionable recommendations for frontline health workers. Designed to avoid black-box decision-making in high-stakes clinical contexts.

**Access Layer** — Android mobile application for health workers, with offline queue ensuring visits are stored locally and synchronized once the network is available.

**Government Analytics Dashboard** — Aggregated and anonymized data supports real-time maternal risk mapping, district-level monitoring, and optimized resource allocation at the ministry level.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Android), Provider state management |
| Backend API | Node.js, Express, JWT authentication |
| Database | PostgreSQL with optional field-level AES-256 encryption |
| AI Service | Python, FastAPI, Explainable AI (XAI) |
| Health Standards | FHIR-compliant data export (Bundle format) |
| Security | OAuth 2.0, role-based access control, immutable audit logs |
| Offline Support | Offline queue with automatic sync on reconnection |

---

## Key Features

- Consent screen with language selection, timestamp, and digital signature
- FHIR-compliant data export (Bundle format) for interoperability with national health systems
- Explainable AI risk scoring — interpretable results, not black-box predictions
- Offline-first architecture — critical for rural Niger where connectivity is unreliable
- Role-based access control — agent and admin roles with full audit logging
- Field-level encryption for sensitive maternal data
- Real-time risk alerts and referral recommendations for health workers

---

## Quick Start

### 1. AI Service (Python/FastAPI)

```bash
cd ai_service
python -m venv .venv
# Activate venv, then:
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### 2. PostgreSQL (Docker)

```bash
cd backend
docker compose up -d
```

### 3. Backend API (Node.js)

```bash
cd backend
npm install
cp .env.example .env
npm run migrate
npm run dev
```

### 4. Mobile App (Flutter/Android)

Android emulator accesses the host at `10.0.2.2`.

```bash
cd mobile
flutter pub get
flutter run
```

---

## Demo Accounts

| Role | Username | Password |
|---|---|---|
| Health Agent | agent1 | pass123 |
| Admin | admin1 | pass123 |

---

## App Screens

- Login
- Home (mother list, search, sync status)
- Consent Screen (language selection, timestamp, signature)
- Register Mother
- Mother Profile (visit history, pending visits, last risk score, FHIR export)
- Add Visit (triggers AI risk scoring service)
- Audit Logs

---

## Security and Governance

- Ministry of Health retains full data ownership
- Role-based access control with explicit informed consent
- AES-256 encryption for sensitive fields
- Immutable audit logs for all data access and modifications
- Offline queue ensures no data loss in low-connectivity environments

---

## Projected Impact

Based on early detection modeling in low and middle income country contexts:

- +60% complete pregnancy follow-up
- 30% reduction in undetected complications
- 20% reduction in maternal mortality in pilot regions

---

*Built in Niger. Designed for Africa.*

# Project Overview

## 1. Purpose

The TA Recruitment System is a lightweight web prototype for managing Teaching Assistant recruitment in BUPT International School. It replaces manual forms and spreadsheets with role-based workflows for applicants, Module Organisers, and HR/Admin staff.

## 2. Users and Goals

| Role | Goal |
|---|---|
| TA | Find jobs, apply, upload documents, track status, withdraw active applications, maintain profile |
| MO | Create and edit jobs, review candidates, make interview/accept/reject decisions |
| HR/Admin | Review candidate and job information, inspect workload, use AI decision support |

## 3. Core Workflow

1. MO creates a job with required skills, slots, hours, deadline, and stipend.
2. TA browses jobs and applies with profile data and attachments.
3. MO reviews applications and changes status.
4. HR/Admin checks overall workload and candidate-job fit.
5. AI-assisted functions provide match summaries and missing-skill suggestions.

## 4. Architecture

```text
JSP/JavaScript UI
        |
Servlet Controllers
        |
Service Layer
        |
Repositories
        |
JSONL File Store
```

Design choices:

- Servlet/JSP keeps the project within coursework constraints.
- JSONL files satisfy the no-database requirement.
- Service layer centralizes business rules so UI and API behavior stay consistent.
- Repository layer hides append-only persistence details.
- AI layer supports both external OpenAI calls and deterministic fallback.

## 5. Main Business Rules

- TA applications are tied to the logged-in user.
- TA cannot repeatedly submit duplicate active applications for the same job.
- TA can withdraw only active pending/interviewed applications.
- MO can manage only own jobs.
- MO job hours per week are capped at 40.
- MO job deadlines cannot be in the past.
- MO cannot approve more candidates than job slots.
- Withdrawn applications are hidden from MO review.
- HR/Admin workload uses applicant display names where possible.

## 6. Data Files

| File | Purpose |
|---|---|
| `data/users.jsonl` | User profiles and password hashes |
| `data/jobs.jsonl` | Job postings |
| `data/applications.jsonl` | Application records |
| `data/attachments.jsonl` | Uploaded attachment metadata |

Append-only storage means updates are represented by appending newer records. Current job state is resolved by the latest record for the same `jobId`.

## 7. Quality Strategy

- Validate input both in frontend and backend.
- Enforce authorization in servlets and services.
- Keep role workflows separated.
- Use readable status tags and consistent button styles.
- Provide deterministic fallback for AI features.
- Verify critical rules with focused tests and manual acceptance checklist.

## 8. Delivery Documents

- `README.md`: repository entry and setup guide.
- `QUICKSTART.md`: quick local run and demo flow.
- `docs/USER_MANUAL.md`: end-user manual.
- `README_AUTH.md`: authentication and role access.
- `docs/MO_API_REFERENCE.md`: MO API reference.
- `docs/TESTING_AND_ACCEPTANCE.md`: testing and acceptance guide.

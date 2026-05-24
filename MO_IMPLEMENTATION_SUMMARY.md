# MO Implementation Summary

## 1. Architecture

The MO workflow follows the project-wide layered architecture:

```text
mo.jsp + assets/js/mo-page.js
        |
MO Servlets
        |
JobService / ApplicationService
        |
JobRepository / ApplicationRepository
        |
JSONL FileStore
```

## 2. Implemented Backend Endpoints

| Endpoint | Method | Servlet | Purpose |
|---|---|---|---|
| `/mo/jobs` | POST | `MoJobServlet` | Create jobs |
| `/mo/jobs` | POST with `mode: "update"` | `MoJobServlet` | Update own jobs |
| `/mo/candidates` | GET | `MoScreeningServlet` | List candidates for own jobs |
| `/mo/applications` | PUT | `MoStatusUpdateServlet` | Update application status |
| `/mo/candidate-detail` | GET | `MoCandidateDetailServlet` | Candidate detail |
| `/mo/candidate-assessment` | POST | `MoCandidateAssessmentServlet` | AI assessment |

## 3. Business Rules

- Current MO user is taken from session.
- Client-provided `createdBy` is not trusted.
- MO can only manage own jobs.
- Hours per week must be at most `40`.
- Deadline cannot be in the past.
- Accepted candidates cannot exceed job slots.
- Withdrawn applications are hidden from MO review.

## 4. Frontend Behavior

- Job cards show counts for total, pending, interviewed, accepted, and rejected candidates.
- `Edit` switches the create form into update mode.
- `Cancel Edit` resets the form.
- Review actions are confirmed before sending API requests.
- Approve buttons are disabled when a job is already full.

## 5. Verification

```bash
mvn -Dmaven.test.skip=true package
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
node --check src/main/webapp/assets/js/mo-page.js
```

Manual checks are listed in [DELIVERY_CHECKLIST.md](DELIVERY_CHECKLIST.md).

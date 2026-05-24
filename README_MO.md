# MO Workspace Guide

This document summarizes the current MO implementation. For full endpoint details, see [docs/MO_API_REFERENCE.md](docs/MO_API_REFERENCE.md).

## 1. Files

| Area | File |
|---|---|
| MO page | `src/main/webapp/mo.jsp` |
| MO frontend logic | `src/main/webapp/assets/js/mo-page.js` |
| Job create/update servlet | `src/main/java/cn/ebu6304/tarecruitment/controller/MoJobServlet.java` |
| Candidate list servlet | `src/main/java/cn/ebu6304/tarecruitment/controller/MoScreeningServlet.java` |
| Status update servlet | `src/main/java/cn/ebu6304/tarecruitment/controller/MoStatusUpdateServlet.java` |
| Candidate detail servlet | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateDetailServlet.java` |
| Candidate AI assessment servlet | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateAssessmentServlet.java` |
| Business logic | `src/main/java/cn/ebu6304/tarecruitment/service/JobService.java`, `ApplicationService.java` |

## 2. MO Capabilities

- Create new jobs.
- Edit existing jobs created by the current MO.
- Set job slots, required skills, weekly hours, deadline, and stipend.
- Review own job applications.
- Filter candidates by All, Pending, Interviewed, Accepted, and Rejected.
- Mark candidates as interviewed.
- Approve or reject candidates with confirmation.
- Prevent approval beyond job slots.
- Hide withdrawn TA applications from MO review.
- Open candidate detail and attachments.
- Run AI one-click assessment for candidate-job fit.

## 3. Main Rules

- MO can only manage jobs created by itself.
- `hoursPerWeek` cannot exceed `40`.
- `applicationDeadline` cannot be in the past.
- Required skills cannot be empty.
- Updating a job keeps applications attached to the same `jobId`.
- Accepted application count cannot exceed job `slots`.

## 4. Startup

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

Open:

```text
http://localhost:8080/index.jsp?login=1
```

Login:

```text
Role: MO
Identifier: mo001
Password: MoDemo@123
```

## 5. API Summary

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/mo/jobs` | Create job |
| POST | `/mo/jobs` with `mode: "update"` | Update job |
| GET | `/mo/candidates` | List candidates for own job |
| PUT | `/mo/applications` | Update application status |
| GET | `/mo/candidate-detail` | View candidate detail |
| POST | `/mo/candidate-assessment` | Run AI assessment |

## 6. Verification

Recommended checks:

```bash
mvn -Dmaven.test.skip=true package
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
node --check src/main/webapp/assets/js/mo-page.js
```

Manual checks:

- Create valid job.
- Try invalid hours `41`.
- Try a past deadline.
- Edit a job and confirm changes persist.
- Approve candidates until slots are full, then confirm additional approve is blocked.
- Withdraw a TA application and confirm it disappears from MO review.

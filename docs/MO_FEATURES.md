# MO Feature Guide

This guide describes the Module Organiser workspace in the current system.

## 1. Job Management

MO users can create and edit jobs from `mo.jsp`.

Fields:

- Job ID
- Job title
- Module code
- Open slots
- Required skills
- Hours per week
- Application deadline
- Monthly stipend

Validation:

- Required skills cannot be empty.
- Open slots must be positive.
- Hours per week must not exceed `40`.
- Application deadline cannot be in the past.
- Monthly stipend must be positive.

Editing behavior:

- Click `Edit` on a job card.
- The form switches to Edit Job mode.
- The Job ID becomes read-only.
- Saving uses `POST /mo/jobs` with `mode: "update"`.
- Existing applications remain attached to the same job.

## 2. Candidate Review

MO users can review applications for jobs they created.

Available filters:

- All
- Pending
- Interviewed
- Accepted
- Rejected

Candidate actions:

- `Mark Interviewed`
- `Approve`
- `Reject`
- `Detail`

Each review action asks for confirmation before updating the application status.

## 3. Status Rules

Supported statuses:

- `SUBMITTED`
- `INTERVIEWED`
- `ACCEPTED`
- `REJECTED`
- `WITHDRAWN`

MO-visible statuses:

- `SUBMITTED`
- `INTERVIEWED`
- `ACCEPTED`
- `REJECTED`

Withdrawn applications are hidden from MO review because they are no longer active candidate records for selection.

## 4. Approval Limit

The system prevents over-accepting candidates:

- If `accepted count >= job slots`, additional `Approve` buttons are disabled in the UI.
- The backend also rejects additional `ACCEPTED` updates.

This protects data integrity even if a user bypasses the frontend.

## 5. Candidate Detail and AI Assessment

The `Detail` button opens a candidate detail page.

The detail page shows:

- Candidate profile
- Application status
- Submitted time
- Job metadata
- Skills
- Resume text
- Attachments with open links
- AI assessment area

AI assessment provides:

- Match overview
- Matched skills
- Missing skills
- Explanation and suggestions

If no OpenAI key is configured, the system uses deterministic rule-based fallback output.

## 6. Main Files

| Purpose | File |
|---|---|
| MO page | `src/main/webapp/mo.jsp` |
| MO frontend logic | `src/main/webapp/assets/js/mo-page.js` |
| Job create/update API | `src/main/java/cn/ebu6304/tarecruitment/controller/MoJobServlet.java` |
| Candidate list API | `src/main/java/cn/ebu6304/tarecruitment/controller/MoScreeningServlet.java` |
| Status update API | `src/main/java/cn/ebu6304/tarecruitment/controller/MoStatusUpdateServlet.java` |
| Candidate detail API | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateDetailServlet.java` |
| AI assessment API | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateAssessmentServlet.java` |
| Job business rules | `src/main/java/cn/ebu6304/tarecruitment/service/JobService.java` |
| Application business rules | `src/main/java/cn/ebu6304/tarecruitment/service/ApplicationService.java` |

## 7. Verification

Recommended commands:

```bash
mvn -Dmaven.test.skip=true package
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
node --check src/main/webapp/assets/js/mo-page.js
```

Manual checks:

- Create a valid job.
- Confirm invalid hours and past deadline are rejected.
- Edit a job and confirm changes are saved.
- Mark a candidate as interviewed.
- Approve up to the slot limit.
- Confirm further approval is blocked.
- Withdraw an application as TA and confirm MO no longer sees it.

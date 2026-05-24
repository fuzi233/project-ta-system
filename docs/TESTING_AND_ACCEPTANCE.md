# Testing and Acceptance Guide

This guide records how to verify the project before submission or demonstration.

## 1. Build Checks

Run a fast package check:

```bash
mvn -Dmaven.test.skip=true package
```

Run focused tests for recently maintained business rules:

```bash
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
```

Run JavaScript syntax check:

```bash
node --check src/main/webapp/assets/js/mo-page.js
```

Notes:

- Some older baseline tests in the repository may use outdated constructor signatures. If full `mvn test` fails on stale tests, use the focused command above and record the exact failure separately.
- Do not use `-DskipTests` when you need to skip test compilation; use `-Dmaven.test.skip=true`.

## 2. Manual Acceptance Checklist

### Public Job Browsing

- Open `http://localhost:8080/jobs.jsp`.
- Confirm jobs are visible before login.
- Confirm `View Detail` works before login.
- Confirm filters update job results.

### TA Application Flow

- Login as `ta001` / `TaDemo@123`.
- Apply for an open job.
- Confirm email validation works.
- Upload CV and transcript.
- Submit once and confirm the submit button becomes disabled after success.
- Confirm duplicate active submissions are not created.
- Open My Applications.
- Confirm status filters include Withdrawn.
- Confirm `View Detail` shows job information and attachment links.
- Withdraw an active application.
- Confirm it appears under Withdrawn for TA.

### MO Job Flow

- Login as `mo001` / `MoDemo@123`.
- Create a job.
- Try `hoursPerWeek` greater than `40`; confirm validation error.
- Try a deadline in the past; confirm validation error.
- Create a valid job.
- Click `Edit`.
- Change title, skills, slots, hours, deadline, or stipend.
- Click `Update Job`.
- Confirm the updated job appears in review.

### MO Review Flow

- Confirm candidate filters include All, Pending, Interviewed, Accepted, Rejected.
- Mark a candidate as Interviewed.
- Approve a candidate.
- Reject a candidate.
- Confirm each action asks for confirmation.
- Set accepted count equal to job slots, then confirm additional Approve buttons are disabled or rejected.
- Confirm withdrawn TA applications are hidden from MO review.
- Open candidate Detail and confirm attachments are clickable.

### HR/Admin Flow

- Login as `hradmin` / `HrDemo@123`.
- Open `admin.jsp`.
- Select candidate and job for AI decision support.
- Confirm AI output is readable.
- Check Workload Dashboard.
- Confirm Applicant uses display names where available.

## 3. API Smoke Tests

Use a browser session for protected APIs, or use curl with cookies.

Login example:

```bash
curl -c /tmp/mo.cookie -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"role":"MO","identifier":"mo001","password":"MoDemo@123"}'
```

Create job:

```bash
curl -b /tmp/mo.cookie -X POST http://localhost:8080/mo/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "jobId": "manual-test-job",
    "title": "Manual Test TA",
    "moduleCode": "EBU6304",
    "requiredSkills": "Java,Testing",
    "slots": 2,
    "hoursPerWeek": 8,
    "applicationDeadline": "2026/12/31",
    "monthlyStipend": 2000
  }'
```

Update job:

```bash
curl -b /tmp/mo.cookie -X POST http://localhost:8080/mo/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "update",
    "jobId": "manual-test-job",
    "title": "Manual Test TA Updated",
    "moduleCode": "EBU6304",
    "requiredSkills": "Java,Testing,SQL",
    "slots": 2,
    "hoursPerWeek": 10,
    "applicationDeadline": "2026/12/31",
    "monthlyStipend": 2200
  }'
```

List candidates:

```bash
curl -b /tmp/mo.cookie "http://localhost:8080/mo/candidates?jobId=manual-test-job&page=1&size=20"
```

## 4. Evidence to Keep

- Terminal output for package and focused tests.
- Browser screenshots for each role.
- Screenshot of MO job edit success.
- Screenshot of MO approval limit behavior.
- Screenshot of TA withdrawal category.
- Screenshot of HR/Admin workload dashboard.
- Notes about any intentionally skipped stale tests.

## 5. Known Constraints

- Persistence is append-only JSONL, so old historical records may remain in data files.
- The current job record is determined by latest appended record for the same `jobId`.
- File upload metadata is stored locally; this prototype is intended for local demo use.
- External AI is optional. Fallback AI is deterministic and suitable for offline demonstration.

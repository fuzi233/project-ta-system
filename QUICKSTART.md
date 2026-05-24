# Quick Start Guide

This guide explains how to start the TA Recruitment System locally and verify the main TA, MO, and HR/Admin flows.

## 1. Prerequisites

- Java 17 or newer
- Maven
- A browser
- Optional: Node.js for JavaScript syntax checking

## 2. Start the Server

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

Open:

```text
http://localhost:8080/jobs.jsp
```

If port `8080` is occupied:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
kill <PID>
```

Then rerun the Jetty command.

## 3. Login Accounts

| Role | Identifier | Password | Page |
|---|---|---|---|
| TA | `ta001` | `TaDemo@123` | `jobs.jsp` |
| MO | `mo001` | `MoDemo@123` | `mo.jsp` |
| HR/Admin | `hradmin` | `HrDemo@123` | `admin.jsp` |

Use `http://localhost:8080/index.jsp?login=1` to sign in. Public users can browse jobs and view job detail before login.

## 4. TA Demo Flow

1. Open `jobs.jsp`.
2. Browse and filter jobs without login.
3. Click `View Detail` to inspect a job.
4. Click `Apply`; if not logged in, sign in as TA.
5. Fill email, skills, experience, CV, and transcript.
6. Click `Submit Application`.
7. Confirm the browser confirmation dialog.
8. Confirm the submit button becomes disabled after submission.
9. Open `My Applications`.
10. Expand `View Detail` to view job details and submitted attachment links.
11. Use `Withdraw` for an active application; it should move into the Withdrawn category.

## 5. MO Demo Flow

1. Sign in as `mo001`.
2. Open `mo.jsp`.
3. Create a job with these constraints:
   - `Hours per Week` must be `1` to `40`.
   - `Application Deadline` must not be in the past.
   - `Open Slots` must be at least `1`.
4. Click `Edit` on any own job card.
5. Update title, module, slots, skills, hours, deadline, or stipend.
6. Click `Update Job`; the edited job should refresh in the review list.
7. Review candidates using filters: All, Pending, Interviewed, Accepted, Rejected.
8. Use `Mark Interviewed`, `Approve`, or `Reject`.
9. If accepted candidates already equal job slots, further `Approve` buttons are disabled and backend approval is blocked.
10. Withdrawn TA applications should not appear in the MO candidate list.

## 6. HR/Admin Demo Flow

1. Sign in as `hradmin`.
2. Open `admin.jsp`.
3. Review candidate and job information.
4. Run AI decision support if candidate/job data is selected.
5. Scroll to workload dashboard.
6. Confirm the Applicant column shows display names rather than only internal IDs.

## 7. Useful Commands

```bash
# Build/package without compiling tests
mvn -Dmaven.test.skip=true package

# Focused service tests
mvn test -Dtest=JobServiceTest,ApplicationServiceTest

# JavaScript syntax check
node --check src/main/webapp/assets/js/mo-page.js
```

## 8. Troubleshooting

- `HTTP 405` after editing a job: restart Jetty and hard-refresh the browser. The current implementation saves edits through `POST /mo/jobs` with `mode: "update"`.
- `Address already in use`: stop the process occupying port `8080`.
- Page redirects to login: sign in with the correct role.
- MO sees no jobs: make sure the job was created by the same MO account.
- AI output is unavailable: configure `OPENAI_API_KEY`, or use the built-in rule-based fallback.
- Browser still shows old UI: use `Cmd + Shift + R` on macOS or clear cache.

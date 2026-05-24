# User Manual

This manual describes how end users operate the TA Recruitment System. It covers three roles: TA, MO, and HR/Admin.

## 1. Accessing the System

Start the application:

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

Open the system:

```text
http://localhost:8080/jobs.jsp
```

Public visitors can browse the job list and job detail pages. Applying, viewing personal applications, profile editing, MO review, and HR/Admin functions require login.

## 2. Login and Sign Out

Login page:

```text
http://localhost:8080/index.jsp?login=1
```

Demo accounts:

| Role | Identifier | Password |
|---|---|---|
| TA | `ta001` | `TaDemo@123` |
| MO | `mo001` | `MoDemo@123` |
| HR/Admin | `hradmin` | `HrDemo@123` |

Use the `Sign Out` link on TA, MO, and HR/Admin pages to return to the login page.

## 3. Account Rules

- TA users can self-register from the login page.
- TA registration requires a valid email format and password length of at least 8 characters.
- MO and HR/Admin accounts are internal accounts; they should not be created from the public registration form.
- User passwords are stored as SHA-256 hashes in `data/users.jsonl`.

## 4. TA User Guide

### 4.1 Browse Jobs

1. Open `jobs.jsp`.
2. Use search and filter controls to narrow jobs by module, skills, status, or keyword.
3. Click `View Detail` to inspect a job without login.

### 4.2 Apply for a Job

1. Click `Apply`.
2. If not logged in, sign in as a TA.
3. Confirm that Full Name and Student ID are taken from the account profile.
4. Enter or confirm email.
5. Select skills and enter relevant experience.
6. Upload CV and transcript.
7. Click `Submit Application`.
8. Confirm the browser confirmation dialog.

Expected behavior:

- The submit button becomes disabled after a successful submission.
- Email format is validated.
- Duplicate active applications for the same job are prevented.
- Uploaded attachments can be opened later from My Applications.

### 4.3 Track and Withdraw Applications

1. Open `My Applications`.
2. Filter by All, Pending, Accepted, Rejected, or Withdrawn.
3. Click `View Detail` to see job details and submitted attachments.
4. Click `Withdraw` for active pending/interviewed applications.

Expected behavior:

- Withdrawn applications remain visible to the TA under Withdrawn.
- Withdrawn applications are hidden from MO review pages.
- Accepted or rejected applications cannot be withdrawn.

### 4.4 Edit Profile

1. Open `Profile`.
2. Update display name, email, skills, and resume/experience text.
3. Save the profile.

Updated profile information is used in application forms, MO candidate detail, and HR/Admin candidate review.

## 5. MO User Guide

### 5.1 Create a Job

1. Sign in as MO.
2. Open `mo.jsp`.
3. Go to the Create Job panel.
4. Fill in Job ID, title, module code, open slots, required skills, hours per week, deadline, and stipend.
5. Click `Create Job`.

Rules:

- `Hours per Week` cannot exceed `40`.
- `Application Deadline` cannot be in the past.
- Required skills must contain at least one skill.
- The job is owned by the current MO account.

### 5.2 Edit a Job

1. In the Review panel, find one of the current MO's jobs.
2. Click `Edit`.
3. Modify the job fields.
4. Click `Update Job`.

Expected behavior:

- Job ID stays attached to existing applications.
- Existing applications remain linked after editing.
- Updated job information appears after refresh.

### 5.3 Review Candidates

1. Use All/Pending/Interviewed/Accepted/Rejected filters.
2. Use the job dropdown or search field to find a specific job/candidate.
3. Click `Mark Interviewed`, `Approve`, or `Reject`.
4. Confirm the browser confirmation dialog before status changes.
5. Click `Detail` to view candidate profile, resume text, attachments, and AI assessment.

Rules:

- MO can only manage jobs created by itself.
- Withdrawn TA applications do not appear in the MO review list.
- When accepted candidates equal the job slots, no more candidates can be approved.
- Rejected/accepted status is clearly shown using colored status labels.

## 6. HR/Admin User Guide

### 6.1 Candidate Review Workspace

1. Sign in as HR/Admin.
2. Open `admin.jsp`.
3. Select a candidate and a job.
4. Review candidate profile and job information.
5. Run AI decision support if needed.

Expected behavior:

- AI output is formatted as readable decision support rather than raw unreadable text.
- If no external AI key is configured, the fallback analysis still returns deterministic suggestions.

### 6.2 Workload Dashboard

1. Scroll to Workload Dashboard.
2. Review applicant workload counts.
3. Confirm applicants are shown with display names where available.

The workload view helps HR/Admin avoid overloading the same TA across multiple jobs.

## 7. Common Problems

| Problem | Solution |
|---|---|
| Page redirects to login | Sign in with the correct role. |
| MO cannot see a job | Confirm the job was created by the same MO account. |
| `HTTP 405` while editing job | Restart Jetty and hard-refresh the browser. |
| Port `8080` is occupied | Run `lsof -nP -iTCP:8080 -sTCP:LISTEN`, then stop the old process. |
| AI result is unavailable | Configure OpenAI settings or use fallback output. |
| Old UI still appears | Hard-refresh browser with `Cmd + Shift + R`. |

## 8. Evidence Checklist for Submission

- Screenshot of public job list and job detail.
- Screenshot of TA application form after upload.
- Screenshot of My Applications with status filters and attachment links.
- Screenshot of MO job creation/edit form.
- Screenshot of MO candidate review with status actions.
- Screenshot of MO candidate detail and AI assessment.
- Screenshot of HR/Admin workload dashboard.
- Terminal output for package/test commands.

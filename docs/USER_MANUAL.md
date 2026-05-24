# User Manual

This manual explains how to start the system, sign in with each role, submit applications, and verify status changes across the main pages.

## 1. Start the System

### Recommended start

```bash
mvn jetty:run
```

If local test compilation is temporarily blocked during branch integration, use:

```bash
mvn -Dmaven.test.skip=true jetty:run
```

When the server is ready, open:

- [http://localhost:8080/index.jsp](http://localhost:8080/index.jsp)
- [http://localhost:8080/jobs.jsp](http://localhost:8080/jobs.jsp)
- [http://localhost:8080/applications.jsp](http://localhost:8080/applications.jsp)
- [http://localhost:8080/mo.jsp](http://localhost:8080/mo.jsp)
- [http://localhost:8080/admin.jsp](http://localhost:8080/admin.jsp)
- [http://localhost:8080/ai.jsp](http://localhost:8080/ai.jsp)

## 2. Available Roles

The system has three main user roles:

- `TA`: browse jobs and submit applications
- `MO`: create jobs and screen candidates
- `ADMIN / HR`: review workload and candidate information

## 3. Demo Login

Use the login page demo shortcuts or enter the credentials manually:

### TA Demo

- Role: `TA`
- Identifier: `ta001@bupt.edu.cn`
- Password: `TaDemo@123`

### Admin / HR Demo

- Role: `ADMIN`
- Identifier: `hradmin`
- Password: `HrDemo@123`

## 4. Registration Rules

If you register a new account instead of using demos:

- `TA`
  - identifier: 10-digit student number or email
- `MO`
  - identifier: 3 letters + 4 digits or email
- `ADMIN`
  - identifier: at least 3 characters, first character must be a letter

Password must be at least 8 characters.

## 5. TA Workflow

### 5.1 Browse Jobs

1. Sign in as `TA`
2. Open `jobs.jsp`
3. Search or browse open jobs
4. Click `Apply` on a target job

### 5.2 Fill the Application Form

On `apply.jsp`, complete:

- `Full Name`
- `Student ID`
- `Email`
- `Skills`
- `Experience`
- `CV`
- `Transcript`

### 5.3 Upload Files

The upload area provides immediate feedback:

- A custom `Choose File` button
- The selected file name shown beside the button
- Accepted formats shown below the transcript area
- Field-level error messages when a file is missing or invalid

### 5.4 Submit the Application

Click `Submit Application`.

After submission, the page shows a `Submission Result` panel with separate feedback for:

- `Application`
- `CV`
- `Transcript`

Examples:

- `Application submitted successfully. Current application status: Pending review.`
- `CV uploaded successfully`
- `Transcript uploaded successfully`

If submission fails, the panel explains which part failed and what should be corrected.

### 5.5 View Application History

Open `applications.jsp` to review your records.

The TA-facing status rules are:

- backend `SUBMITTED` -> shown as `Pending`
- `Pending` means the application has been submitted and is waiting for review

You can filter the list by:

- `All`
- `Pending`
- `Accepted`
- `Rejected`

## 6. MO Workflow

### 6.1 Sign In

Sign in using an `MO` account.

### 6.2 Create a Job

1. Open `mo.jsp`
2. Go to the posting form
3. Complete the required fields
4. Submit the form

### 6.3 Screen Candidates

MO can:

- filter candidates by `jobId`
- inspect submitted applications
- update application status

Typical status flow:

`SUBMITTED -> INTERVIEWED -> ACCEPTED / REJECTED`

## 7. Admin / HR Workflow

### 7.1 Open Workload Dashboard

1. Sign in as `ADMIN`
2. Open `admin.jsp`
3. Set a threshold if needed
4. Refresh the workload view

The page summarizes:

- total applications
- workload by applicant
- overloaded applicants

## 8. AI Pages

The project includes AI helper pages and APIs for:

- match scoring
- missing skills suggestions
- workload-based recommendations
- HR assessment summaries

Open `ai.jsp` after the server starts.

## 9. Data Files

The project stores its records in JSONL files:

- `data/users.jsonl`
- `data/jobs.jsonl`
- `data/applications.jsonl`
- `data/attachments.jsonl`

These files are useful for troubleshooting local demos and verifying whether records are being written.

## 10. Troubleshooting

### Login redirects back to the home page

Possible causes:

- the role is incorrect
- the session expired
- the identifier/password pair does not match the selected role

### Upload feedback is missing

Check:

- whether both files were selected
- whether the browser session is still logged in as `TA`
- whether attachment records are being saved

### Pending list does not look right

Check:

- whether the application was actually created
- whether the TA account is viewing its own applications
- whether the record status is still `SUBMITTED`

### Server starts but pages do not reflect changes

Use a hard refresh:

- macOS: `Command + Shift + R`

## 11. Suggested Demo Flow

For classroom presentation or acceptance:

1. Start the server
2. Sign in with `TA Demo`
3. Open `jobs.jsp`
4. Apply to one job
5. Upload `CV` and `Transcript`
6. Submit and show the `Submission Result` panel
7. Open `applications.jsp`
8. Show that the new record appears as `Pending`
9. Filter by `Pending`

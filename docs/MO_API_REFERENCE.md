# MO API Reference

This document focuses on MO-related endpoints and the rules used by the MO workspace.

All MO endpoints require an authenticated MO session.

## 1. Create or Update Job

Endpoint:

```text
POST /mo/jobs
```

Create request:

```json
{
  "jobId": "job-101",
  "title": "Software Engineering TA",
  "moduleCode": "EBU6304",
  "requiredSkills": "Java,Testing,SQL",
  "slots": 2,
  "hoursPerWeek": 8,
  "applicationDeadline": "2026/06/30",
  "monthlyStipend": 2000
}
```

Update request:

```json
{
  "mode": "update",
  "jobId": "job-101",
  "title": "Updated Software Engineering TA",
  "moduleCode": "EBU6304",
  "requiredSkills": "Java,Testing,SQL,Communication",
  "slots": 3,
  "hoursPerWeek": 10,
  "applicationDeadline": "2026/07/15",
  "monthlyStipend": 2500
}
```

Rules:

- `createdBy` is ignored from the client and forced to the current MO user.
- Only the MO who created a job can update it.
- `hoursPerWeek` must be between `1` and `40`.
- `applicationDeadline` must be a valid date and cannot be in the past.
- `slots` and `monthlyStipend` must be positive.
- Updating a job keeps existing applications attached to the same `jobId`.

Success response:

```json
{
  "created": true,
  "record": {
    "jobId": "job-101",
    "title": "Software Engineering TA",
    "moduleCode": "EBU6304",
    "requiredSkills": "Java,Testing,SQL",
    "slots": 2,
    "hoursPerWeek": 8,
    "applicationDeadline": "2026/06/30",
    "monthlyStipend": 2000,
    "status": "OPEN",
    "createdBy": "mo-001",
    "createdAt": "2026-05-24T10:00:00+08:00"
  }
}
```

## 2. List Candidates for a Job

Endpoint:

```text
GET /mo/candidates?jobId=<jobId>&status=<status>&page=1&size=20
```

Query parameters:

| Parameter | Required | Description |
|---|---|---|
| `jobId` | Yes | Job ID created by current MO |
| `status` | No | `SUBMITTED`, `INTERVIEWED`, `ACCEPTED`, or `REJECTED` |
| `page` | No | Page number, default `1` |
| `size` | No | Page size, default `20` |

Notes:

- Withdrawn applications are hidden from MO candidate lists.
- The endpoint enriches applications with user profile data and attachment metadata.
- The MO can only view candidates for own jobs.

Example response:

```json
{
  "jobId": "job-101",
  "owner": "mo-001",
  "status": "ALL",
  "page": 1,
  "size": 20,
  "count": 1,
  "candidates": [
    {
      "applicationId": "app-0001",
      "applicantId": "ta-001",
      "jobId": "job-101",
      "status": "SUBMITTED",
      "submittedAt": "2026-05-24T10:20:00+08:00",
      "displayName": "Alice Demo",
      "identifier": "ta001",
      "email": "ta001@bupt.edu.cn",
      "skills": "SQL",
      "resumeText": "Coursework and teaching support experience.",
      "attachments": []
    }
  ]
}
```

## 3. Update Application Status

Endpoint:

```text
PUT /mo/applications
```

Request:

```json
{
  "applicationId": "app-0001",
  "status": "INTERVIEWED"
}
```

Allowed statuses:

- `SUBMITTED`
- `INTERVIEWED`
- `ACCEPTED`
- `REJECTED`

Rules:

- MO can update only applications under own jobs.
- Before changing to `ACCEPTED`, the service checks the job's accepted count.
- If accepted count already equals or exceeds job slots, the update is rejected.
- UI buttons ask for confirmation before sending status changes.

Success response:

```json
{
  "updated": true,
  "record": {
    "applicationId": "app-0001",
    "applicantId": "ta-001",
    "jobId": "job-101",
    "status": "INTERVIEWED",
    "submittedAt": "2026-05-24T10:20:00+08:00"
  }
}
```

## 4. Candidate Detail

Endpoint:

```text
GET /mo/candidate-detail?jobId=<jobId>&candidateUserId=<userId>&applicationId=<applicationId>
```

Purpose:

- View profile fields.
- View job metadata.
- View current application status.
- View attachment metadata and open attachment download links.

Withdrawn applications return a not-found style response because they should no longer be reviewed by MO.

## 5. Candidate AI Assessment

Endpoint:

```text
POST /mo/candidate-assessment
```

Request:

```json
{
  "candidateUserId": "ta-001",
  "jobId": "job-101"
}
```

Purpose:

- Generate match score.
- Summarize candidate experience.
- List matched and missing skills.
- Provide explanation for MO decision support.

If no external AI provider is configured, the service uses deterministic rule-based fallback.

## 6. Common Error Responses

| Status | Meaning | Example Cause |
|---|---|---|
| 400 | Validation error | Past deadline or hours > 40 |
| 401 | Not authenticated | Session missing |
| 403 | Forbidden | MO tries to manage another MO's job |
| 404 | Not found | Job/application missing or withdrawn |
| 500 | Server error | Unexpected file or parsing problem |

## 7. Browser Debug Tips

In `mo.jsp`, open developer tools and inspect Network requests:

- Job create/edit should call `POST /mo/jobs`.
- Review actions should call `PUT /mo/applications`.
- Candidate lists should call `GET /mo/candidates`.

If a recent backend change is not reflected, restart Jetty and hard-refresh the browser.

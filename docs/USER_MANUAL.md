# User Manual (TA / MO / Admin)

## 1. Start the System

```bash
mvn jetty:run
```

Open:

- `http://localhost:8080/` (login/register)
- `http://localhost:8080/jobs.jsp` (TA)
- `http://localhost:8080/mo.jsp` (MO)
- `http://localhost:8080/admin.jsp` (Admin)

## 2. Account Rules

Registration is role-based and requires role-specific identifier formats:

- TA: `10-digit number` or email (example: `2026123456`)
- MO: `3 letters + 4 digits` or email (example: `MOA1024`)
- Admin: `>=3 chars`, first char must be letter (example: `admin_team1`)

Password must be at least 8 characters.

## 3. TA Workflow

1. Login as TA from `index.jsp`
2. Go to `jobs.jsp`
3. Search open jobs
4. Submit application (`applicationId` optional)
5. Click **Query** to check application status

Expected APIs:

- `GET /jobs`
- `POST /applications`
- `GET /applications`

## 4. MO Workflow

1. Login as MO
2. Open `mo.jsp`
3. Create a new job in **Post New Job**
4. Filter candidates in **Screen Candidates** by:
   - `jobId`
   - optional `status`
   - `page` and `size`
5. Update candidate status in **Update Application Status**

Expected APIs:

- `POST /mo/jobs`
- `GET /mo/candidates`
- `PUT /mo/applications`

## 5. Admin Workflow

1. Login as Admin
2. Open `admin.jsp`
3. Set threshold and click **Refresh**
4. Check:
   - total applications
   - by-applicant counts
   - overloaded applicants

Expected API:

- `GET /admin/workload?threshold=<value>`

## 6. Troubleshooting

- If role page redirects to `index.jsp`, session is missing or role is incorrect.
- If API returns `401/403`, re-login with correct role.
- If no data appears, verify there are records in:
  - `data/jobs.jsonl`
  - `data/applications.jsonl`
  - `data/users.jsonl`

## 7. Screenshot Checklist

Capture and store screenshots following:

- `docs/screenshots/README.md`

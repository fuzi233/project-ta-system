# Start Here

This file is the document entry point for reviewers and teammates.

## Recommended Reading Order

1. [README.md](README.md): project overview, setup, features, accounts, and API summary.
2. [QUICKSTART.md](QUICKSTART.md): local startup commands and role-based demo flow.
3. [docs/USER_MANUAL.md](docs/USER_MANUAL.md): user-facing manual for TA, MO, and HR/Admin.
4. [README_AUTH.md](README_AUTH.md): login, registration, session, and role access rules.
5. [docs/MO_API_REFERENCE.md](docs/MO_API_REFERENCE.md): MO endpoint reference.
6. [docs/TESTING_AND_ACCEPTANCE.md](docs/TESTING_AND_ACCEPTANCE.md): testing commands and acceptance checklist.
7. [docs/project-overview.md](docs/project-overview.md): architecture and design overview.

## One-Minute Startup

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

Then open:

```text
http://localhost:8080/jobs.jsp
```

## Demo Accounts

| Role | Identifier | Password |
|---|---|---|
| TA | `ta001` | `TaDemo@123` |
| MO | `mo001` | `MoDemo@123` |
| HR/Admin | `hradmin` | `HrDemo@123` |

## What to Demonstrate

- Public users can browse jobs and view job details before login.
- TA can apply, upload attachments, view application detail, and withdraw active applications.
- MO can create/edit own jobs, review candidates, and approve/reject with slot limits.
- HR/Admin can review candidate-job information and workload dashboard.
- AI support works with optional OpenAI configuration and deterministic fallback.

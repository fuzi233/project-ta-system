# TA Recruitment System

Servlet/JSP prototype for the EBU6304 Software Engineering group project. The system supports Teaching Assistant recruitment for BUPT International School with TA, Module Organiser (MO), and HR/Admin workflows.

## Main Features

- TA users can browse open jobs before login, sign in or register, apply for jobs, upload CV/transcript files, view application status, withdraw active applications, and edit profile information.
- MO users can create jobs, edit existing own jobs, review candidates, filter by status, mark interviewed, approve, reject, and run AI-assisted candidate assessment.
- HR/Admin users can review candidate information, use AI decision support, and inspect workload distribution by applicant name.
- AI features support rule-based fallback when no OpenAI key is configured, so demos remain usable offline.
- Data is stored in JSON Lines files under `data/`; no database is required.

## Technology Stack

- Java 17
- Jakarta Servlet and JSP
- Jetty Maven Plugin for local development
- HTML/CSS/JavaScript frontend
- JSONL text-file persistence
- JUnit 5 and Mockito for tests

## Project Structure

```text
src/main/java/cn/ebu6304/tarecruitment/
  controller/      Servlet endpoints
  service/         Business rules
  repository/      JSONL repository access
  storage/         File-store utilities
  ai/              AI provider and fallback logic
src/main/webapp/
  index.jsp        Login/register entry
  jobs.jsp         Public and TA job list
  apply.jsp        TA application form
  applications.jsp TA application history
  profile.jsp      TA profile editor
  mo.jsp           MO workspace
  admin.jsp        HR/Admin workspace
data/              JSONL demo data
docs/              User manual, API guide, testing guide
scripts/           Acceptance helpers
```

## Quick Start

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

Open:

- `http://localhost:8080/jobs.jsp` for public job browsing and TA entry
- `http://localhost:8080/index.jsp?login=1` for login
- `http://localhost:8080/mo.jsp` for MO workspace after MO login
- `http://localhost:8080/admin.jsp` for HR/Admin workspace after Admin login

If port `8080` is already in use:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
kill <PID>
```

## Demo Accounts

The seeded demo accounts in `data/users.jsonl` include:

| Role | Identifier | Password | Landing Page |
|---|---|---|---|
| TA | `ta001` | `TaDemo@123` | `jobs.jsp` |
| MO | `mo001` | `MoDemo@123` | `mo.jsp` |
| HR/Admin | `hradmin` | `HrDemo@123` | `admin.jsp` |

Only TA self-registration is available from the UI. MO and HR/Admin accounts are treated as internal accounts and should already exist in `data/users.jsonl`.

## Important Business Rules

- A TA cannot submit duplicate applications for the same job while an active application already exists.
- After TA submits or withdraws an application, relevant buttons become disabled or state-aware.
- Withdrawn TA applications remain visible to the TA in the Withdrawn category but are hidden from the MO review list.
- MO can only manage jobs created by that MO account.
- MO job `hoursPerWeek` must be between `1` and `40`.
- MO job `applicationDeadline` cannot be in the past.
- MO cannot approve more applicants than the job's `slots`.
- Uploaded attachment links are available from TA application history and MO candidate detail pages.

## API Summary

| Endpoint | Method | Purpose |
|---|---|---|
| `/auth/login` | POST | Login and create session |
| `/auth/logout` | POST | Sign out |
| `/auth/register` | POST | TA self-registration |
| `/auth/me` | GET/POST | Read or update current user profile |
| `/jobs` | GET | List jobs |
| `/mo/jobs` | POST | Create job; update job with `mode: "update"` |
| `/applications` | GET/POST/DELETE | TA application list, submit, withdraw |
| `/mo/candidates` | GET | MO candidate screening |
| `/mo/applications` | PUT | MO status update |
| `/mo/candidate-detail` | GET | MO candidate detail |
| `/mo/candidate-assessment` | POST | MO AI assessment |
| `/admin/workload` | GET | HR/Admin workload dashboard |
| `/hr/candidates` | GET | HR/Admin candidate data |

More details are in [docs/MO_API_REFERENCE.md](docs/MO_API_REFERENCE.md).

## AI Configuration

The system works without an API key by using deterministic rule-based fallback logic.

Optional local config file:

```text
config/ai.local.properties
```

```properties
openai.api.key=<your_api_key>
openai.model=gpt-4.1
openai.api.endpoint=https://api.openai.com/v1/chat/completions
```

Environment variables can also be used:

```bash
export OPENAI_API_KEY="<your_api_key>"
export OPENAI_MODEL="gpt-4.1"
export OPENAI_API_ENDPOINT="https://api.openai.com/v1/chat/completions"
```

## Testing

Fast compile/package check:

```bash
mvn -Dmaven.test.skip=true package
```

Focused tests for currently maintained service logic:

```bash
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
```

JavaScript syntax check:

```bash
node --check src/main/webapp/assets/js/mo-page.js
```

See [docs/TESTING_AND_ACCEPTANCE.md](docs/TESTING_AND_ACCEPTANCE.md) for the full manual acceptance checklist.

## Documentation

- [QUICKSTART.md](QUICKSTART.md): startup and demo walkthrough
- [docs/USER_MANUAL.md](docs/USER_MANUAL.md): TA, MO, HR/Admin user manual
- [README_AUTH.md](README_AUTH.md): login, registration, and role access control
- [docs/MO_API_REFERENCE.md](docs/MO_API_REFERENCE.md): MO API reference
- [docs/TESTING_AND_ACCEPTANCE.md](docs/TESTING_AND_ACCEPTANCE.md): testing and acceptance guide
- [docs/project-overview.md](docs/project-overview.md): project overview

## Branch Workflow

- Work on a personal branch.
- Pull or merge the latest `project-ta-system` branch before final changes.
- Create a pull request back to `project-ta-system`.
- Keep screenshots, manual checks, and test output as delivery evidence.

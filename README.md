# TA Recruitment System

TA Recruitment System is a Servlet/JSP-based group project for managing TA job posting, student applications, candidate screening, workload review, and AI-assisted evaluation. The project uses JSON Lines files under `data/` for persistence and does not require a database.

## Overview

- Multi-role web application for `TA`, `MO`, and `ADMIN / HR`
- Servlet + JSP architecture with JSON APIs
- File-based persistence with append-only JSONL storage
- Built-in demo accounts for presentation and local verification
- AI helper endpoints for matching, missing skills, workload suggestions, and HR assessment

## Main Features

### TA

- Browse open jobs on `jobs.jsp`
- Submit applications on `apply.jsp`
- Upload `CV` and `Transcript`
- See selected file names before submission
- See per-item submission results for:
  - `Application`
  - `CV`
  - `Transcript`
- View personal application history on `applications.jsp`
- See `SUBMITTED` rendered as `Pending` in the TA interface

### MO

- Post new jobs
- Screen candidates by job and status
- Update application status

### ADMIN / HR

- Review workload summary and overloaded applicants
- Inspect candidate data for decision support

### AI Support

- Applicant-job matching
- Missing skills diagnosis
- Workload-aware recommendation
- HR assessment summary

## Architecture

```text
Servlet (Controller) -> Service -> Repository -> FileStore
```

Key characteristics:

- Text-only persistence with `data/*.jsonl`
- No relational database
- Lightweight indexing and paged reads
- Session-based role access control

## Project Structure

```text
src/main/java/cn/ebu6304/tarecruitment/
  controller/    Web and API servlets
  service/       Business logic
  repository/    JSONL persistence
  model/         Domain models
  util/          Shared helpers

src/main/webapp/
  *.jsp          Role pages and UI
  assets/        CSS / JS / images

data/
  users.jsonl
  jobs.jsonl
  applications.jsonl
  attachments.jsonl

docs/
  USER_MANUAL.md
  TESTING_AND_ACCEPTANCE.md
```

## Main Endpoints

### Authentication

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`

### TA

- `GET /jobs`
- `POST /applications`
- `GET /applications`
- `GET /application-detail`
- `GET /attachments/download`

### MO

- `POST /mo/jobs`
- `GET /mo/candidates`
- `PUT /mo/applications`

### ADMIN / HR

- `GET /admin/workload`
- `GET /hr/candidates`

### AI

- `POST /ai/match`
- `POST /ai/missing-skills`
- `GET /ai/workload-suggestion`
- `POST /ai/hr-assessment`

## Requirements

- JDK 17
- Maven 3.9+

## Local Run

### Standard

```bash
mvn test
mvn jetty:run
```

### Practical UI Demo Start

If test compilation is temporarily blocked by branch merge mismatch, you can still verify the web UI with:

```bash
mvn -Dmaven.test.skip=true jetty:run
```

Then open:

- [http://localhost:8080/index.jsp](http://localhost:8080/index.jsp)
- [http://localhost:8080/jobs.jsp](http://localhost:8080/jobs.jsp)
- [http://localhost:8080/applications.jsp](http://localhost:8080/applications.jsp)
- [http://localhost:8080/mo.jsp](http://localhost:8080/mo.jsp)
- [http://localhost:8080/admin.jsp](http://localhost:8080/admin.jsp)
- [http://localhost:8080/ai.jsp](http://localhost:8080/ai.jsp)

## Demo Accounts

Built-in demo accounts after seeding:

- `TA`
  - identifier: `ta001@bupt.edu.cn`
  - password: `TaDemo@123`
- `ADMIN / HR`
  - identifier: `hradmin`
  - password: `HrDemo@123`

Notes:

- The login page also provides quick-fill demo buttons.
- TA application submission updates the application record and profile fields used for skills/experience, but should not be used to overwrite demo login identity fields.

## Current TA Application UX

The TA application flow now includes clearer feedback:

- Selected `CV` and `Transcript` file names are visible before submit
- Validation errors are shown near the corresponding upload area
- Submission results are shown item by item
- `SUBMITTED` is shown to the TA as `Pending review`
- The Applications page supports `Pending` filtering for submitted records

## Testing

Run all tests:

```bash
mvn test
```

Run selected tests:

```bash
mvn -Dtest=ApplicationRepositoryTest,WorkloadServiceTest,StatusLifecycleIntegrationTest test
```

Run acceptance script after the server starts:

```bash
bash scripts/acceptance/run_acceptance.sh
```

See:

- [docs/TESTING_AND_ACCEPTANCE.md](/Users/ns/Documents/NASA/project-ta-system/docs/TESTING_AND_ACCEPTANCE.md)
- [docs/USER_MANUAL.md](/Users/ns/Documents/NASA/project-ta-system/docs/USER_MANUAL.md)

## Optional AI Configuration

Default local config file:

`config/ai.local.properties`

```properties
openai.api.key=<your_api_key>
openai.model=gpt-4.1
openai.api.endpoint=https://api.openai.com/v1/chat/completions
```

Or use environment variables:

```bash
export OPENAI_API_KEY="<your_api_key>"
export OPENAI_MODEL="gpt-4.1"
export OPENAI_API_ENDPOINT="https://api.openai.com/v1/chat/completions"
```

If no API key is configured, the project falls back to deterministic rule-based behavior so demos remain usable.

## Troubleshooting

- If the page redirects back to `index.jsp`, the session may be missing or the role is incorrect.
- If demo login stops working after local testing, check whether demo data in `data/users.jsonl` was modified by hand.
- If `mvn jetty:run` fails during test compilation after a merge, use `mvn -Dmaven.test.skip=true jetty:run` for UI verification first, then reconcile outdated test signatures.
- If upload results appear inconsistent, verify:
  - `data/attachments.jsonl`
  - `data/applications.jsonl`
  - the browser session role

## Branch Workflow

- Work on a personal branch
- Push your branch to remote
- Open a Pull Request into `project-ta-system`
- Do not push code directly to `main`

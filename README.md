# TA Recruitment System (Servlet/JSP Prototype)

EBU6304 group project implementation branch.

## Architecture

- `Servlet (Controller) -> Service -> Repository -> FileStore`
- Text-only persistence with JSON Lines (`data/*.jsonl`)
- No database, compliant with handout constraints

## API v1

- `GET /jobs` (list + filter)
- `POST /applications` (idempotent submit)
- `GET /applications?applicantId=` (status query)
- `POST /mo/jobs` (MO post job)
- `GET /admin/workload` (workload summary)

## Quality Targets

- Memory: lightweight `id/status` indexes, paged reads, no unbounded cache
- Stability: input validation, explicit error response, append-only writes, atomic compaction
- Frontend: iPhone-inspired glass style, mobile-first layout, distinct visual hierarchy

## Data Files

- `data/jobs.jsonl`
- `data/applications.jsonl`
- `data/users.jsonl`

## Local Run

```bash
mvn test
mvn jetty:run
```

Then open:
- `http://localhost:8080/`
- `http://localhost:8080/jobs.jsp`
- `http://localhost:8080/mo.jsp`
- `http://localhost:8080/admin.jsp`

## Branch Workflow

- personal branch -> PR -> `project-ta-system`
- no direct push to `main` for code

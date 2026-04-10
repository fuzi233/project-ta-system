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
- `POST /ai/match` (LLM-assisted applicant-job matching)
- `POST /ai/missing-skills` (missing skill diagnosis + suggestions)
- `GET /ai/workload-suggestion` (workload-aware shortlist recommendation)

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
- `http://localhost:8080/ai.jsp`

## Optional LLM Configuration

Default local config file:

`config/ai.local.properties` (ignored by git)

```properties
openai.api.key=<your_api_key>
openai.model=gpt-5.3
openai.api.endpoint=https://api.openai.com/v1/chat/completions
```

You can also override by environment variables:

```bash
export OPENAI_API_KEY=\"<your_api_key>\"
export OPENAI_MODEL=\"gpt-5.3\"
export OPENAI_API_ENDPOINT=\"https://api.openai.com/v1/chat/completions\"
```

If `OPENAI_API_KEY` is not set, the system automatically falls back to deterministic rule-based reasoning so demos remain stable.

## Branch Workflow

- personal branch -> PR -> `project-ta-system`
- no direct push to `main` for code

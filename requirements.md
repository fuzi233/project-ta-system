# Requirements Baseline (Iteration 1)

## Functional

1. TA profile and job application lifecycle.
2. MO job posting and candidate screening support.
3. Admin workload visibility per applicant.
4. API endpoints for job listing, apply, status query, posting, workload summary.

## Non-functional

1. Layered architecture: Servlet -> Service -> Repository -> FileStore.
2. JSONL text persistence only; no database.
3. Efficient memory usage via lightweight indexes and paged reading.
4. Stable writes using append-only and atomic compaction.
5. Responsive, high-recognition frontend style.

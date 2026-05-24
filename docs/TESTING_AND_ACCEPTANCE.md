# Testing and Acceptance Guide

This document describes how to test the TA Recruitment System locally and how to collect evidence for submission or classroom acceptance.

## 1. Testing Scope

The project should be checked at three levels:

- unit tests for repository and service logic
- integration tests for workflow behavior
- browser or API acceptance checks for role-based end-to-end behavior

## 2. Automated Tests

Run the full test suite:

```bash
mvn test
```

Run selected tests:

```bash
mvn -Dtest=ApplicationRepositoryTest,WorkloadServiceTest,StatusLifecycleIntegrationTest test
```

Typical areas covered:

- application persistence
- status update lifecycle
- workload threshold logic
- MO screening behavior

## 3. Local UI Verification Start

### Standard

```bash
mvn jetty:run
```

### Practical fallback for UI-only verification

If test compilation is temporarily out of sync after a merge, start the web app with:

```bash
mvn -Dmaven.test.skip=true jetty:run
```

This allows browser acceptance checks while test files are being reconciled.

## 4. Acceptance Script

Script path:

```bash
scripts/acceptance/run_acceptance.sh
```

### Start the server first

```bash
mvn jetty:run
```

or

```bash
mvn -Dmaven.test.skip=true jetty:run
```

### Run the script

```bash
bash scripts/acceptance/run_acceptance.sh
```

Or pass a custom base URL:

```bash
bash scripts/acceptance/run_acceptance.sh http://localhost:8080
```

### What the script verifies

1. service reachability
2. TA registration
3. MO registration
4. Admin registration
5. MO login and job creation
6. TA login and application submission
7. TA application query
8. MO candidate screening
9. MO status update
10. Admin workload query

## 5. Manual Browser Acceptance

The manual checks below are especially important for presentation and grading.

### 5.1 TA flow

1. Sign in as `TA`
2. Open `jobs.jsp`
3. Click `Apply` for an open job
4. Fill the form
5. Choose a `CV`
6. Choose a `Transcript`
7. Confirm file names are visible
8. Submit the form
9. Verify `Submission Result` shows:
   - `Application`
   - `CV`
   - `Transcript`
10. Verify successful submission mentions `Pending review`
11. Open `applications.jsp`
12. Verify the new record appears as `Pending`
13. Click the `Pending` filter and verify the record remains visible

### 5.2 TA validation flow

1. Open `apply.jsp`
2. Leave one or both files empty
3. Submit
4. Verify field-level error messages appear in English
5. Verify the result panel explains that the application was not submitted

### 5.3 MO flow

1. Sign in as `MO`
2. Open `mo.jsp`
3. Create a job
4. Query candidates for a job
5. Update one application status

### 5.4 Admin flow

1. Sign in as `ADMIN`
2. Open `admin.jsp`
3. Refresh workload summary
4. Verify total applications and threshold-based workload data

## 6. Evidence Checklist

Keep the following as final evidence:

1. `mvn test` output, or a note explaining temporary test mismatch after branch merge
2. acceptance script output
3. screenshots of:
   - login page
   - job list
   - TA application form
   - upload feedback
   - submission result
   - applications page with `Pending`
   - MO screening
   - admin workload view
4. updated documentation files:
   - `README.md`
   - `docs/USER_MANUAL.md`
   - `docs/TESTING_AND_ACCEPTANCE.md`

## 7. Common Issues

### `Invalid credentials for selected role`

Check:

- selected role
- identifier value
- whether demo seed data was modified locally

### `Pending` does not appear

Check:

- whether the application creation returned success
- whether the record is still `SUBMITTED`
- whether the current session belongs to the same TA

### Upload status looks inconsistent

Check:

- `data/attachments.jsonl`
- `data/applications.jsonl`
- browser refresh after submission

### UI changes do not appear

Use a hard refresh:

- macOS: `Command + Shift + R`

## 8. Notes

- The project uses JSONL append-only persistence and no database.
- Some local environments may temporarily start the web app with `-Dmaven.test.skip=true` during integration work, but final delivery should still aim to restore full `mvn test` health.

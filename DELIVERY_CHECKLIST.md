# Delivery Checklist

Use this checklist before packaging or submitting the software.

## Documentation

- [ ] `README.md` explains setup, features, accounts, testing, and API summary.
- [ ] `QUICKSTART.md` provides a runnable local demo flow.
- [ ] `docs/USER_MANUAL.md` covers TA, MO, and HR/Admin usage.
- [ ] `README_AUTH.md` explains login, registration, and role permissions.
- [ ] `docs/MO_API_REFERENCE.md` explains MO endpoints.
- [ ] `docs/TESTING_AND_ACCEPTANCE.md` lists manual acceptance evidence.
- [ ] Screenshots are stored or listed according to `docs/screenshots/README.md`.

## Build and Test

- [ ] `mvn -Dmaven.test.skip=true package` succeeds.
- [ ] `mvn test -Dtest=JobServiceTest,ApplicationServiceTest` succeeds.
- [ ] `node --check src/main/webapp/assets/js/mo-page.js` succeeds.
- [ ] Any known stale baseline test failures are documented.

## TA Flow

- [ ] Public job list loads before login.
- [ ] Job detail is visible before login.
- [ ] TA can sign in.
- [ ] TA can submit an application with attachments.
- [ ] Submit button becomes disabled after successful submission.
- [ ] TA can view application detail and attachments.
- [ ] TA can withdraw active applications.
- [ ] Withdrawn category is visible in My Applications.

## MO Flow

- [ ] MO can sign in.
- [ ] MO can create a valid job.
- [ ] MO cannot create/edit a job with hours greater than `40`.
- [ ] MO cannot create/edit a job with a past deadline.
- [ ] MO can edit own jobs.
- [ ] MO can filter candidates by status.
- [ ] MO review actions ask for confirmation.
- [ ] MO cannot approve more candidates than job slots.
- [ ] Withdrawn applications are hidden from MO review.
- [ ] Candidate detail attachment links work.

## HR/Admin Flow

- [ ] HR/Admin can sign in.
- [ ] Candidate/job selection works.
- [ ] AI decision support is readable.
- [ ] Workload dashboard shows applicant names when available.

## Packaging

- [ ] Source code included.
- [ ] Test code included.
- [ ] Documentation included.
- [ ] Data files included or clear seed instructions provided.
- [ ] No API keys committed.

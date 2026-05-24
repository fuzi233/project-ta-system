# MO Delivery Summary

This file summarizes the current MO delivery state. The detailed and up-to-date MO guide is maintained in [README_MO.md](README_MO.md) and [docs/MO_API_REFERENCE.md](docs/MO_API_REFERENCE.md).

## Delivered Features

- MO job creation.
- MO job editing for all jobs created by the current MO.
- Weekly hours limit of `40`.
- Deadline validation to prevent past dates.
- Candidate review by status.
- Review actions with confirmation.
- Approval limit based on job slots.
- Hidden withdrawn applications from MO review.
- Candidate detail page with attachment links.
- AI assessment support with fallback logic.

## Current MO Files

| Purpose | File |
|---|---|
| MO workspace | `src/main/webapp/mo.jsp` |
| MO frontend logic | `src/main/webapp/assets/js/mo-page.js` |
| Job create/update | `src/main/java/cn/ebu6304/tarecruitment/controller/MoJobServlet.java` |
| Candidate screening | `src/main/java/cn/ebu6304/tarecruitment/controller/MoScreeningServlet.java` |
| Status update | `src/main/java/cn/ebu6304/tarecruitment/controller/MoStatusUpdateServlet.java` |
| Candidate detail | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateDetailServlet.java` |
| AI assessment | `src/main/java/cn/ebu6304/tarecruitment/controller/MoCandidateAssessmentServlet.java` |

## Startup

```bash
cd /Users/ns/Documents/GRQ/project-ta-system
mvn -Dmaven.test.skip=true jetty:run
```

MO demo login:

```text
Role: MO
Identifier: mo001
Password: MoDemo@123
```

## Verification

```bash
mvn -Dmaven.test.skip=true package
mvn test -Dtest=JobServiceTest,ApplicationServiceTest
node --check src/main/webapp/assets/js/mo-page.js
```

Manual acceptance details are in [docs/TESTING_AND_ACCEPTANCE.md](docs/TESTING_AND_ACCEPTANCE.md).

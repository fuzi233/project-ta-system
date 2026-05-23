# Testing & Documentation Delivery Summary

## Module Owner Scope

This document records the delivery for:

- test cases (unit + integration)
- acceptance script
- documentation integration (testing guide + user manual + screenshot checklist)

## Delivered Items

### 1) Test cases

- `src/test/java/cn/ebu6304/tarecruitment/repository/ApplicationRepositoryTest.java`
- `src/test/java/cn/ebu6304/tarecruitment/service/WorkloadServiceTest.java`
- `src/test/java/cn/ebu6304/tarecruitment/integration/StatusLifecycleIntegrationTest.java`
- `src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker`

### 2) Acceptance script

- `scripts/acceptance/run_acceptance.sh`

### 3) Documentation

- `docs/TESTING_AND_ACCEPTANCE.md`
- `docs/USER_MANUAL.md`
- `docs/screenshots/README.md`
- README navigation updates

## Validation Commands

```bash
mvn test
bash scripts/acceptance/run_acceptance.sh
```

## Notes

- Acceptance script assumes the server is running at `http://localhost:8080`.
- Role permissions are enforced in all script checks (TA/MO/Admin).

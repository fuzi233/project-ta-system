# Testing and Acceptance Guide

This guide is the delivery package for the **Testing & Documentation** module.

## 1. Scope

- Unit tests: repository/storage/service behavior
- Integration tests: workflow from job creation to status transitions
- Acceptance script: TA + MO + Admin end-to-end verification via HTTP APIs
- Documentation alignment: startup, test commands, acceptance evidence checklist

## 2. Automated Test Cases

Run all tests:

```bash
mvn test
```

Run only key module tests:

```bash
mvn -Dtest=ApplicationRepositoryTest,WorkloadServiceTest,StatusLifecycleIntegrationTest test
```

### Added/updated test classes

| Test Class | Level | Coverage |
|---|---|---|
| `ApplicationRepositoryTest` | Unit | status update consistency, idempotent update checks, compaction correctness |
| `WorkloadServiceTest` | Unit | workload threshold behavior and unique-application counting |
| `StatusLifecycleIntegrationTest` | Integration | submit -> interview -> accepted lifecycle visibility in query/statistics |
| `MoScreeningServiceTest` | Unit | MO filtering/status update service surface |

## 3. One-Click Acceptance Script

Path:

```bash
scripts/acceptance/run_acceptance.sh
```

### Precondition

Start the server first:

```bash
mvn jetty:run
```

### Run

```bash
bash scripts/acceptance/run_acceptance.sh
```

Or specify a custom base URL:

```bash
bash scripts/acceptance/run_acceptance.sh http://localhost:8080
```

### What the script verifies

1. Service reachability
2. TA/MO/Admin registration
3. MO login and job creation
4. TA login, application submission, and status query
5. MO candidate filtering and status update
6. Admin workload query with threshold filtering

## 4. Acceptance Evidence Checklist

Keep these as submission evidence:

1. `mvn test` terminal output
2. Acceptance script terminal output (all PASS)
3. Required screenshots under `docs/screenshots/`
4. Updated README and user manual links

## 5. Notes

- Project uses JSONL append-only persistence (`data/*.jsonl`) and no database.
- For stable local test execution on recent JDK versions, Mockito uses subclass mock maker via:
  - `src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker`

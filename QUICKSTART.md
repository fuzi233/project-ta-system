# Quick Start

This file is a short setup reference for local demo and acceptance.

## 1. Start the Project

### Standard

```bash
mvn test
mvn jetty:run
```

### UI Demo Fallback

If test compilation is temporarily out of sync after branch merging:

```bash
mvn -Dmaven.test.skip=true jetty:run
```

## 2. Open the Main Pages

- [http://localhost:8080/index.jsp](http://localhost:8080/index.jsp)
- [http://localhost:8080/jobs.jsp](http://localhost:8080/jobs.jsp)
- [http://localhost:8080/applications.jsp](http://localhost:8080/applications.jsp)
- [http://localhost:8080/mo.jsp](http://localhost:8080/mo.jsp)
- [http://localhost:8080/admin.jsp](http://localhost:8080/admin.jsp)
- [http://localhost:8080/ai.jsp](http://localhost:8080/ai.jsp)

## 3. Demo Accounts

### TA Demo

- identifier: `ta001@bupt.edu.cn`
- password: `TaDemo@123`

### Admin / HR Demo

- identifier: `hradmin`
- password: `HrDemo@123`

## 4. Fast Acceptance Path

### TA

1. Sign in
2. Open `jobs.jsp`
3. Click `Apply`
4. Fill the form
5. Upload `CV` and `Transcript`
6. Submit
7. Confirm the `Submission Result` panel
8. Open `applications.jsp`
9. Verify the new record appears as `Pending`

### MO

1. Sign in as `MO`
2. Open `mo.jsp`
3. Create a job
4. Query candidates
5. Update a candidate status

### Admin

1. Sign in as `ADMIN`
2. Open `admin.jsp`
3. Refresh workload data

## 5. Acceptance Script

```bash
bash scripts/acceptance/run_acceptance.sh
```

## 6. Documentation

- [README.md](/Users/ns/Documents/NASA/project-ta-system/README.md)
- [docs/USER_MANUAL.md](/Users/ns/Documents/NASA/project-ta-system/docs/USER_MANUAL.md)
- [docs/TESTING_AND_ACCEPTANCE.md](/Users/ns/Documents/NASA/project-ta-system/docs/TESTING_AND_ACCEPTANCE.md)

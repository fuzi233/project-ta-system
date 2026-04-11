# TA Recruitment System - Login/Register & Auth README

## 1. Scope
This README documents only authentication and role-based access control changes.
These changes are not written in `README_MO.md`.

## 2. Core Behavior
- Real registration is enabled and persisted to `data/users.jsonl`
- Real login is enabled and reads from `data/users.jsonl`
- Built-in demo accounts are removed
- Backend role isolation is enforced (not UI-only)

## 3. Role Credential Rules
- TA: `10-digit student ID` or `email`
- MO: `staff ID` (`3 letters + 4 digits`, e.g. `TCH1001`) or `email`
- Admin: `admin username` (`letter` + at least 2 letters/digits/underscore)

## 4. Login/Register API

### Register
- Endpoint: `POST /auth/register`
- Request JSON:
```json
{
  "name": "Alice",
  "role": "TA",
  "identifier": "2023213149",
  "email": "alice@example.com",
  "password": "yourPassword"
}
```
- Validation:
  - role is required and must be one of `TA/MO/ADMIN`
  - identifier must match selected role format
  - email format must be valid
  - password length >= 8
  - duplicate email rejected
  - duplicate `(role, identifier)` rejected
- Success: `201 Created`

### Login
- Endpoint: `POST /auth/login`
- Request JSON:
```json
{
  "role": "TA",
  "identifier": "2023213149",
  "password": "yourPassword"
}
```
- Login key matching:
  - matches by selected role + (`identifier` OR `email`)
- Password check:
  - compares SHA-256 hash
- Success: returns role-specific redirect page

## 5. Password Policy
- Passwords are stored as SHA-256 hash in `passwordHash`
- Plain password is not stored

## 6. Role Isolation (Backend)

### TA
- `POST /applications`: applicant is forced to current session user
- `GET /applications`: can only read own applications

### MO
- `POST /mo/jobs`: `createdBy` is forced to current session user
- `GET /mo/candidates`: only allowed for jobs created by current MO
- `PUT /mo/applications`: only allowed for applications under current MO's jobs

### Admin
- `GET /admin/workload`: admin-only

## 7. Session Model
- Session attributes are stored under auth keys:
  - `auth.userId`
  - `auth.role`
  - `auth.displayName`
  - `auth.identifier`
- Session timeout is set in login servlet

## 8. Frontend Notes
- Login page: `src/main/webapp/index.jsp`
- Login requires selecting role before submit
- Role-based placeholder/hint and live validation are enabled
- TA examples use 10-digit student ID format

## 9. Data File
- User data file: `data/users.jsonl`
- If empty, create user first from Register tab

## 10. Verification Commands
```bash
mvn -DskipTests compile
mvn test
```

Expected:
- compile success
- all tests pass (with existing baseline skipped tests if any)

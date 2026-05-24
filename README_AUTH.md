# Authentication and Role Access Guide

This guide documents login, registration, session behavior, and role-based access control.

## 1. Core Behavior

- Login is session-based and backed by `data/users.jsonl`.
- TA self-registration is enabled.
- MO and HR/Admin accounts are internal accounts and should be pre-created in `data/users.jsonl`.
- Backend role checks are enforced in servlet endpoints, not only in the UI.
- Passwords are stored as SHA-256 hashes.

## 2. Demo Accounts

| Role | Identifier | Email | Password |
|---|---|---|---|
| TA | `ta001` | `ta001@bupt.edu.cn` | `TaDemo@123` |
| MO | `mo001` | `mo001@bupt.edu.cn` | `MoDemo@123` |
| HR/Admin | `hradmin` | `hradmin@bupt.edu.cn` | `HrDemo@123` |

## 3. Login API

Endpoint:

```text
POST /auth/login
```

Request:

```json
{
  "role": "TA",
  "identifier": "ta001",
  "password": "TaDemo@123"
}
```

Behavior:

- Login key can be identifier or email.
- Role must match the selected account role.
- Successful login creates a server session.
- Response includes a role-specific redirect page.

Example redirects:

| Role | Redirect |
|---|---|
| TA | `jobs.jsp` |
| MO | `mo.jsp` |
| ADMIN | `admin.jsp` |

## 4. Register API

Endpoint:

```text
POST /auth/register
```

Current production behavior:

- Only TA self-registration is accepted.
- MO and HR/Admin registration returns a forbidden response because these are internal accounts.

TA request:

```json
{
  "name": "Alice Student",
  "role": "TA",
  "identifier": "2023213149",
  "email": "alice@bupt.edu.cn",
  "password": "yourPassword"
}
```

Validation:

- `name`, `role`, `identifier`, `email`, and `password` are required.
- `role` must be `TA` for self-registration.
- email must be valid.
- password length must be at least 8 characters.
- duplicate email is rejected.
- duplicate `(role, identifier)` is rejected.

## 5. Current User API

Endpoint:

```text
GET /auth/me
POST /auth/me
```

Purpose:

- `GET` returns the current logged-in user's profile.
- `POST` updates display name, email, skills, and resume text.

TA profile updates are used by the apply form, MO candidate review, and HR/Admin screens.

## 6. Logout API

Endpoint:

```text
POST /auth/logout
```

Behavior:

- Invalidates the current session.
- Frontend returns the user to `index.jsp?login=1`.

## 7. Role Isolation

### TA

- Can browse jobs.
- Can submit applications only for the current session user.
- Can read only own applications.
- Can withdraw only own active applications.
- Can update own profile.

### MO

- Can create jobs owned by the current MO account.
- Can edit only own jobs.
- Can view candidates only for own jobs.
- Can update application status only for own jobs.
- Cannot see withdrawn TA applications in review lists.

### HR/Admin

- Can access workload dashboard and HR review workspace.
- Can read candidate/job data for HR decision support.

## 8. Session Attributes

The server stores these values in the HTTP session:

```text
auth.userId
auth.role
auth.displayName
auth.identifier
```

If the session expires or the role is wrong, protected pages redirect or protected APIs return `401`/`403`.

## 9. Troubleshooting

- `401 Not authenticated`: log in again.
- `403 Insufficient permissions`: use the correct role.
- Registering MO/Admin fails: this is expected; use seeded internal accounts.
- Login succeeds but page looks wrong: hard-refresh the browser.
- Password forgotten in demo data: reset by editing `data/users.jsonl` or reseeding data.

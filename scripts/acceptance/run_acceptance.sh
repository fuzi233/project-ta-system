#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"
COOKIE_DIR="$(mktemp -d -t ta-acceptance-cookies.XXXXXX)"
TMP_BODY="$(mktemp -t ta-acceptance-body.XXXXXX)"

cleanup() {
  rm -rf "${COOKIE_DIR}" "${TMP_BODY}"
}
trap cleanup EXIT

log_step() {
  printf '\n[%s] %s\n' "STEP" "$1"
}

log_ok() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

request() {
  local method="$1"
  local path="$2"
  local payload="${3:-}"
  local cookie="${4:-}"
  local code

  if [[ -n "${payload}" ]]; then
    if [[ -n "${cookie}" ]]; then
      code="$(curl -sS \
        -o "${TMP_BODY}" \
        -w '%{http_code}' \
        -X "${method}" \
        -H 'Content-Type: application/json' \
        --data "${payload}" \
        -b "${cookie}" \
        -c "${cookie}" \
        "${BASE_URL}${path}")"
    else
      code="$(curl -sS \
        -o "${TMP_BODY}" \
        -w '%{http_code}' \
        -X "${method}" \
        -H 'Content-Type: application/json' \
        --data "${payload}" \
        "${BASE_URL}${path}")"
    fi
  else
    if [[ -n "${cookie}" ]]; then
      code="$(curl -sS \
        -o "${TMP_BODY}" \
        -w '%{http_code}' \
        -X "${method}" \
        -b "${cookie}" \
        -c "${cookie}" \
        "${BASE_URL}${path}")"
    else
      code="$(curl -sS \
        -o "${TMP_BODY}" \
        -w '%{http_code}' \
        -X "${method}" \
        "${BASE_URL}${path}")"
    fi
  fi

  RESPONSE_CODE="${code}"
  RESPONSE_BODY="$(cat "${TMP_BODY}")"
}

assert_http() {
  local expected="$1"
  local message="$2"
  if [[ "${RESPONSE_CODE}" != "${expected}" ]]; then
    fail "${message} (expected HTTP ${expected}, got ${RESPONSE_CODE}, body=${RESPONSE_BODY})"
  fi
}

assert_jq() {
  local expr="$1"
  local message="$2"
  if ! jq -e "${expr}" >/dev/null 2>&1 <<<"${RESPONSE_BODY}"; then
    fail "${message} (body=${RESPONSE_BODY})"
  fi
}

TA_COOKIE="${COOKIE_DIR}/ta.cookie"
MO_COOKIE="${COOKIE_DIR}/mo.cookie"
ADMIN_COOKIE="${COOKIE_DIR}/admin.cookie"

RUN_ID="$(date +%s)"
TA_IDENTIFIER="$(printf '%010d' $(( (RUN_ID % 9000000000) + 1000000000 )))"
MO_IDENTIFIER="MOA$(printf '%04d' $(( RUN_ID % 10000 )))"
ADMIN_IDENTIFIER="admin_${RUN_ID}"
PASSWORD="Passw0rd!"
JOB_ID="JOB-${RUN_ID}"
APPLICATION_ID="APP-${RUN_ID}"

TA_EMAIL="ta.${RUN_ID}@example.com"
MO_EMAIL="mo.${RUN_ID}@example.com"
ADMIN_EMAIL="admin.${RUN_ID}@example.com"

log_step "0. Check service reachable: ${BASE_URL}"
request GET "/" "" ""
if [[ "${RESPONSE_CODE}" == "000" ]]; then
  fail "Service is unreachable. Start server first: mvn jetty:run"
fi
log_ok "Service reachable"

log_step "1. Register TA, MO, Admin accounts"
request POST "/auth/register" "{\"name\":\"TA Demo\",\"role\":\"TA\",\"identifier\":\"${TA_IDENTIFIER}\",\"email\":\"${TA_EMAIL}\",\"password\":\"${PASSWORD}\"}" ""
assert_http "201" "TA register failed"
log_ok "TA registered"

request POST "/auth/register" "{\"name\":\"MO Demo\",\"role\":\"MO\",\"identifier\":\"${MO_IDENTIFIER}\",\"email\":\"${MO_EMAIL}\",\"password\":\"${PASSWORD}\"}" ""
assert_http "201" "MO register failed"
log_ok "MO registered"

request POST "/auth/register" "{\"name\":\"Admin Demo\",\"role\":\"ADMIN\",\"identifier\":\"${ADMIN_IDENTIFIER}\",\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${PASSWORD}\"}" ""
assert_http "201" "Admin register failed"
log_ok "Admin registered"

log_step "2. MO login and create one job"
request POST "/auth/login" "{\"role\":\"MO\",\"identifier\":\"${MO_IDENTIFIER}\",\"password\":\"${PASSWORD}\"}" "${MO_COOKIE}"
assert_http "200" "MO login failed"
assert_jq '.redirect == "mo.jsp"' "MO redirect mismatch"
MO_USER_ID="$(jq -r '.userId' <<<"${RESPONSE_BODY}")"
log_ok "MO logged in (${MO_USER_ID})"

request POST "/mo/jobs" "{\"jobId\":\"${JOB_ID}\",\"title\":\"Acceptance Test Job\",\"moduleCode\":\"EBU6304\",\"requiredSkills\":\"Java\",\"slots\":2}" "${MO_COOKIE}"
assert_http "201" "Create job failed"
assert_jq ".record.jobId == \"${JOB_ID}\"" "Created jobId mismatch"
log_ok "Job created (${JOB_ID})"

log_step "3. TA login, apply job, and query own applications"
request POST "/auth/login" "{\"role\":\"TA\",\"identifier\":\"${TA_IDENTIFIER}\",\"password\":\"${PASSWORD}\"}" "${TA_COOKIE}"
assert_http "200" "TA login failed"
assert_jq '.redirect == "jobs.jsp"' "TA redirect mismatch"
TA_USER_ID="$(jq -r '.userId' <<<"${RESPONSE_BODY}")"
log_ok "TA logged in (${TA_USER_ID})"

request POST "/applications" "{\"applicationId\":\"${APPLICATION_ID}\",\"jobId\":\"${JOB_ID}\"}" "${TA_COOKIE}"
assert_http "201" "Submit application failed"
assert_jq '.created == true' "Application should be newly created"
log_ok "Application submitted (${APPLICATION_ID})"

request GET "/applications?page=1&size=10" "" "${TA_COOKIE}"
assert_http "200" "Query TA applications failed"
assert_jq ".items | map(.applicationId) | index(\"${APPLICATION_ID}\") != null" "Application not found in TA query result"
log_ok "TA query returned submitted application"

log_step "4. MO screening and status update"
request GET "/mo/candidates?jobId=${JOB_ID}&page=1&size=20" "" "${MO_COOKIE}"
assert_http "200" "MO candidate query failed"
assert_jq ".candidates | map(.applicationId) | index(\"${APPLICATION_ID}\") != null" "Application not found in MO candidate list"
log_ok "MO candidate screening passed"

request PUT "/mo/applications" "{\"applicationId\":\"${APPLICATION_ID}\",\"status\":\"INTERVIEWED\"}" "${MO_COOKIE}"
assert_http "200" "MO status update failed"
assert_jq '.updated == true' "Status update response mismatch"
assert_jq '.record.status == "INTERVIEWED"' "Updated status mismatch"
log_ok "MO status updated to INTERVIEWED"

log_step "5. Admin login and workload check"
request POST "/auth/login" "{\"role\":\"ADMIN\",\"identifier\":\"${ADMIN_IDENTIFIER}\",\"password\":\"${PASSWORD}\"}" "${ADMIN_COOKIE}"
assert_http "200" "Admin login failed"
assert_jq '.redirect == "admin.jsp"' "Admin redirect mismatch"
log_ok "Admin logged in"

request GET "/admin/workload?threshold=0" "" "${ADMIN_COOKIE}"
assert_http "200" "Admin workload query failed"
assert_jq '.totalApplications >= 1' "Expected at least one application in workload"
assert_jq ".overloaded[\"${TA_USER_ID}\"] >= 1" "Expected TA user to appear in overloaded map with threshold=0"
log_ok "Admin workload dashboard data verified"

printf '\nAll acceptance checks passed.\n'

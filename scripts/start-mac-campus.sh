#!/usr/bin/env bash

set -euo pipefail

PORT="${1:-8080}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] Missing command: $1"
    exit 1
  fi
}

detect_ip() {
  local ip=""
  ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
  if [[ -z "${ip}" ]]; then
    ip="$(ipconfig getifaddr en1 2>/dev/null || true)"
  fi
  if [[ -z "${ip}" ]]; then
    ip="$(ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}')"
  fi
  echo "${ip:-127.0.0.1}"
}

require_cmd java
require_cmd mvn

LOCAL_IP="$(detect_ip)"

echo "== TA Recruitment System (Mac Campus Mode) =="
echo "Project: ${ROOT_DIR}"
echo "Port: ${PORT}"
echo "Local:   http://localhost:${PORT}/"
echo "Campus:  http://${LOCAL_IP}:${PORT}/"
echo
echo "[TIP] Keep this terminal open. Stop server with Ctrl+C."
echo

cd "${ROOT_DIR}"

# Bind to all interfaces so devices in the same campus network can access.
exec mvn \
  -DskipTests \
  -Djetty.http.host=0.0.0.0 \
  -Djetty.host=0.0.0.0 \
  -Djetty.http.port="${PORT}" \
  -Djetty.port="${PORT}" \
  jetty:run

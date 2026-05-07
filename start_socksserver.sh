#!/bin/bash
set -e

INTERFACE="cnem_vnic"
CHECK_INTERVAL=5
MAX_CHECKS=60

# Use provided SOCKS credentials only when both username and password are set
SOCKS_USERNAME=${SOCKS_USERNAME:-}
SOCKS_PASSWORD=${SOCKS_PASSWORD:-}

if [ -n "$SOCKS_USERNAME" ] && [ -n "$SOCKS_PASSWORD" ]; then
  SOCKS_CMD=(/usr/local/bin/socksserver -u "$SOCKS_USERNAME" -p "$SOCKS_PASSWORD" -l :1080)
else
  SOCKS_CMD=(/usr/local/bin/socksserver -l :1080)
fi

echo "[Wrapper] Waiting for interface ${INTERFACE} to appear..."
COUNT=0
while ! ip link show "${INTERFACE}" >/dev/null 2>&1; do
  if [ ${COUNT} -ge ${MAX_CHECKS} ]; then
    echo "[Wrapper] ERROR: Interface ${INTERFACE} did not appear after $((MAX_CHECKS * CHECK_INTERVAL)) seconds."
    exit 1
  fi
  echo "[Wrapper] Interface ${INTERFACE} not found yet, waiting ${CHECK_INTERVAL}s... (${COUNT}/${MAX_CHECKS})"
  sleep ${CHECK_INTERVAL}
  COUNT=$((COUNT + 1))
done

echo "[Wrapper] Interface ${INTERFACE} found. Starting socksserver..."
exec "${SOCKS_CMD[@]}"

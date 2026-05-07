#!/bin/bash
set -e

INTERFACE="cnem_vnic"
CHECK_INTERVAL=5
MAX_CHECKS=60

# Set default anonymous credentials if not provided
SOCKS_USERNAME=${SOCKS_USERNAME:-anonymous}
SOCKS_PASSWORD=${SOCKS_PASSWORD:-anonymous}

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
exec /usr/local/bin/socksserver -u "$SOCKS_USERNAME" -p "$SOCKS_PASSWORD" -l :1080

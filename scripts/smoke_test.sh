#!/usr/bin/env bash
set -euo pipefail

ALB_DNS=${1:?ALB_DNS required}

URL="http://${ALB_DNS}/"
echo "Running smoke test against ${URL}"

HTTP_CODE=$(curl -s -o /tmp/smoke_body.txt -w "%{http_code}" "$URL")
cat /tmp/smoke_body.txt

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "Smoke test failed with HTTP ${HTTP_CODE}" >&2
  exit 1
fi

echo "Smoke test passed"

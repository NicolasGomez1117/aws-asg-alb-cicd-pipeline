#!/usr/bin/env bash
set -euo pipefail

ASG_NAME=${1:?ASG_NAME required}

MAX_WAIT_SECONDS=${MAX_WAIT_SECONDS:-900}
SLEEP_SECONDS=15
ELAPSED=0

REFRESH_ID=$(aws autoscaling start-instance-refresh --auto-scaling-group-name "$ASG_NAME" --query "InstanceRefreshId" --output text)
echo "Started instance refresh: ${REFRESH_ID}"

while true; do
  STATUS=$(aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name "$ASG_NAME" \
    --instance-refresh-ids "$REFRESH_ID" \
    --query "InstanceRefreshes[0].Status" \
    --output text)

  echo "Refresh ${REFRESH_ID} status: ${STATUS}"

  case "$STATUS" in
    Successful)
      exit 0
      ;;
    Failed|Cancelled)
      echo "Instance refresh failed with status ${STATUS}" >&2
      exit 1
      ;;
    *)
      if [ "$ELAPSED" -ge "$MAX_WAIT_SECONDS" ]; then
        echo "Instance refresh timed out after ${ELAPSED}s (max ${MAX_WAIT_SECONDS}s). Last status: ${STATUS}" >&2
        aws autoscaling describe-instance-refreshes \
          --auto-scaling-group-name "$ASG_NAME" \
          --instance-refresh-ids "$REFRESH_ID"
        exit 1
      fi
      sleep "$SLEEP_SECONDS"
      ELAPSED=$((ELAPSED + SLEEP_SECONDS))
      ;;
  esac
done

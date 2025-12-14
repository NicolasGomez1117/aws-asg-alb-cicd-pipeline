#!/usr/bin/env bash
set -euo pipefail

VERSION=${1:?Version required}
ARTIFACT_BUCKET=${2:?Artifact bucket required}
ARTIFACT_PREFIX=${3:?Artifact prefix required}
SSM_PARAM_NAME=${4:?SSM parameter name required}
ASG_NAME=${5:?ASG name required}
TARGET_GROUP_ARN=${6:?Target group ARN required}
ALB_DNS=${7:?ALB DNS required}

ARTIFACT_KEY="${ARTIFACT_PREFIX}/app-${VERSION}.zip"

aws ssm put-parameter --name "$SSM_PARAM_NAME" --type String --value "$VERSION" --overwrite
echo "Updated SSM parameter ${SSM_PARAM_NAME} to version ${VERSION}"

scripts/start_refresh_and_wait.sh "$ASG_NAME"

echo "Checking target health for ${TARGET_GROUP_ARN}"
HEALTHY=$(aws elbv2 describe-target-health --target-group-arn "$TARGET_GROUP_ARN" \
  --query 'TargetHealthDescriptions[*].TargetHealth.State' --output text)
echo "Target health states: ${HEALTHY}"

if echo "$HEALTHY" | grep -q "unhealthy"; then
  echo "Not all targets are healthy" >&2
  exit 1
fi

scripts/smoke_test.sh "$ALB_DNS"

cat > deploy_metadata.json <<EOF
{
  "version": "${VERSION}",
  "artifact_bucket": "${ARTIFACT_BUCKET}",
  "artifact_key": "${ARTIFACT_KEY}",
  "ssm_param": "${SSM_PARAM_NAME}",
  "asg_name": "${ASG_NAME}",
  "target_group_arn": "${TARGET_GROUP_ARN}",
  "alb_dns": "${ALB_DNS}"
}
EOF

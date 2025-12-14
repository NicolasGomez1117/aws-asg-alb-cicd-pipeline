#!/usr/bin/env bash
set -euo pipefail

APP_DIR=${1:-app}
ARTIFACT_BUCKET=${2:-build-artifacts}
ARTIFACT_PREFIX=${3:-build-artifacts}

VERSION=${CODEBUILD_RESOLVED_SOURCE_VERSION:-dev}
ARTIFACT_NAME="app-${VERSION}.zip"
ARTIFACT_KEY="${ARTIFACT_PREFIX}/${ARTIFACT_NAME}"
TMP_DIR=$(mktemp -d)

pushd "$APP_DIR" >/dev/null
zip -r "${TMP_DIR}/${ARTIFACT_NAME}" .
popd >/dev/null

aws s3 cp "${TMP_DIR}/${ARTIFACT_NAME}" "s3://${ARTIFACT_BUCKET}/${ARTIFACT_KEY}"

cat > build_metadata.json <<EOF
{
  "version": "${VERSION}",
  "artifact_bucket": "${ARTIFACT_BUCKET}",
  "artifact_key": "${ARTIFACT_KEY}"
}
EOF

echo "Packaged ${ARTIFACT_NAME} to s3://${ARTIFACT_BUCKET}/${ARTIFACT_KEY}"

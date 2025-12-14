## Rollback Notes (Placeholder)

- Identify last known good artifact version in S3 (from `build_metadata.json` history).
- Re-run deploy pipeline with the previous version to update SSM parameter and trigger a new ASG instance refresh.
- Verify ALB target health and smoke test before declaring rollback complete.

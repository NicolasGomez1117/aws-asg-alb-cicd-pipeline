## Deployment Runbook (Placeholder)

- Trigger CodePipeline from GitHub push.
- Build stage runs tests, packages the Flask app, uploads artifact to S3, and emits `build_metadata.json`.
- Deploy stage updates SSM parameter with the artifact version, triggers ASG instance refresh, waits for ALB health, and runs smoke test.

Detailed steps will be documented after Terraform and pipeline wiring are complete.

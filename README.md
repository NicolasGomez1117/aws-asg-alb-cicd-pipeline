# AWS ASG + ALB CI/CD (CodePipeline + CodeBuild)

Production-style pipeline for a Flask app on ASG/ALB with health-gated instance refreshes. Infrastructure (VPC/ALB/ASG/LT) remains Terraform-owned; deploys only update SSM version and trigger instance refreshes.

## Layout
- `app/` – Flask app, requirements, simple test.
- `buildspecs/` – `build.yml` (test + package + upload), `deploy.yml` (update SSM, refresh ASG, health gate, smoke).
- `scripts/` – helper scripts used by buildspecs.
- `infra/` – Terraform control-plane (S3 bucket, SSM param, IAM, CodeBuild, CodePipeline).
- `docs/` – runbook and rollback placeholders.

## Pipeline Flow
1. **Source**: GitHub via CodeStar connection.
2. **Build**: CodeBuild runs pytest, zips app, uploads to S3 with metadata.
3. **Deploy**: CodeBuild sets SSM `/app/current_version`, starts ASG instance refresh, waits with timeout, checks target health, runs ALB smoke test.

## Deploy Scripts (key commands)
- `aws ssm put-parameter --overwrite`
- `aws autoscaling start-instance-refresh` + poll `describe-instance-refreshes` (timeout guarded)
- `aws elbv2 describe-target-health` (fail if any unhealthy)
- `curl http://$ALB_DNS/` smoke test

## Notes
- Terraform here only adds CI/CD control plane + SSM param; no changes to VPC/ALB/ASG.
- Artifact bucket uses versioning + SSE.
- Instance user_data should fetch SSM version, pull matching ZIP from S3, and start Flask app.

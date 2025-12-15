## Deployment Philosophy

### Scope and Non-Goals
- Scope: Deliver a Flask backend to EC2 behind an ALB using Terraform-managed infra and a CI/CD pipeline that refreshes an ASG with new app revisions.
- Non-goals: Building a shared platform, multitenant orchestration, or container/Kubernetes migration. No new abstractions beyond Terraform, ASG, ALB, and CodePipeline/CodeBuild.

### Control Plane vs Application Plane
- Control plane: Terraform-managed resources (VPC, ALB, ASG/Launch Template, IAM, S3/SSM artifacts, CodePipeline/CodeBuild). Slow-changing, reviewed, versioned.
- Application plane: Flask artifact (AMI or package) plus runtime config (SSM parameters). Deployed frequently; roll forward/back without redefining infra.
- Tradeoff: Separating planes slows infra changes but reduces surprises during frequent app deploys.

### Infrastructure as a Stable Contract
- ALB + ASG shape, security groups, IAM trust/policies, and network topology are the contract the app must satisfy.
- App deploys do not mutate load balancer wiring or IAM trust; fewer moving parts per release.
- Tradeoff: Less flexibility at deploy time; new infra needs require a Terraform change and review, not an ad-hoc toggle.

### Runtime State and Configuration (SSM Versioning)
- Runtime config (secrets, env vars) lives in SSM Parameter Store with versioning; deployments pin to explicit versions.
- Rollbacks select prior SSM versions; no baked-in secrets in AMIs.
- Tradeoff: Slightly slower promotion (need to bump/pin versions) but clearer audit and safer rotation.

### IAM Boundaries and Blast Radius
- Instances assume a narrowly scoped role: read runtime params from SSM, pull artifacts, write app logs/metrics. No broad AWS mutations.
- Pipeline roles separated: build vs deploy vs runtime. Terraform state bucket/lock isolated.
- Tradeoff: More roles/policies to manage, but a compromised host cannot mutate infra or other environments.

### Deployment Safety Mechanisms
- ALB health checks gate traffic; targets must pass before full registration.
- ASG instance refresh with rolling strategy; max unavailable kept low to avoid capacity dips.
- Smoke tests run post-refresh against the ALB before marking success.
- Tradeoff: Slower rollout and transient extra capacity, but reduces user-facing errors during deploys.

### Backend Engineer’s Operating Model
- Treat Terraform as the source of truth for infra shape; app deploys iterate quickly against that contract.
- When the app needs new infra (ports, IAM permissions, scaling policy), land a Terraform change first, then ship the app.
- Prefer roll-forward with pinned SSM config and controlled instance refresh; keep rollbacks to config+artifact version selection, not infra churn.

variable "project_name" {
  description = "Name prefix for CI/CD resources."
  type        = string
  default     = "asg-alb-cicd"
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for CodePipeline artifacts and packaged app artifacts."
  type        = string
}

variable "artifact_prefix" {
  description = "Prefix within the artifact bucket for app artifacts."
  type        = string
  default     = "build-artifacts"
}

variable "github_connection_arn" {
  description = "CodeStar Connections ARN for GitHub."
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "github_branch" {
  description = "Branch to build from."
  type        = string
  default     = "main"
}

variable "ssm_param_name" {
  description = "SSM parameter storing the current app version."
  type        = string
  default     = "/app/current_version"
}

variable "asg_name" {
  description = "Target Auto Scaling Group name for instance refresh."
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN for post-refresh health checks."
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name for smoke testing."
  type        = string
}

variable "codebuild_image" {
  description = "CodeBuild image."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "codebuild_compute_type" {
  description = "CodeBuild compute type."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "tags" {
  description = "Additional tags to apply."
  type        = map(string)
  default     = {}
}

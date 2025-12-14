resource "aws_ssm_parameter" "current_version" {
  name        = var.ssm_param_name
  description = "Current approved app version for ASG instances."
  type        = "String"
  value       = "initial"
  tags        = local.tags
}

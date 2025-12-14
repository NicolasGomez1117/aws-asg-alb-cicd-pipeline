locals {
  project_name     = var.project_name
  artifact_prefix  = var.artifact_prefix
  tags             = merge({ Project = local.project_name }, var.tags)
  build_image      = var.codebuild_image
  build_compute    = var.codebuild_compute_type
}

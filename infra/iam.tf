data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${local.project_name}-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [aws_codebuild_project.build.arn, aws_codebuild_project.deploy.arn]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.codebuild_build.arn, aws_iam_role.codebuild_deploy.arn]
  }

  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.github_connection_arn]
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${local.project_name}-codepipeline"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_build" {
  name               = "${local.project_name}-codebuild-build"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  tags               = local.tags
}

resource "aws_iam_role" "codebuild_deploy" {
  name               = "${local.project_name}-codebuild-deploy"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "codebuild_build" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    actions   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
  }
}

resource "aws_iam_role_policy" "codebuild_build" {
  name   = "${local.project_name}-codebuild-build"
  role   = aws_iam_role.codebuild_build.id
  policy = data.aws_iam_policy_document.codebuild_build.json
}

data "aws_iam_policy_document" "codebuild_deploy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions   = ["ssm:PutParameter", "ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter${var.ssm_param_name}"]
  }

  statement {
    actions   = ["autoscaling:StartInstanceRefresh", "autoscaling:DescribeInstanceRefreshes"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/Project"
      values   = [local.project_name]
    }
  }

  statement {
    actions   = ["elasticloadbalancing:DescribeTargetHealth"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_deploy" {
  name   = "${local.project_name}-codebuild-deploy"
  role   = aws_iam_role.codebuild_deploy.id
  policy = data.aws_iam_policy_document.codebuild_deploy.json
}

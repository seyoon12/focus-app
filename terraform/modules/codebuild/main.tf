resource "aws_codebuild_project" "docker_build" {
  name          = "docker-build-project"
  service_role  = var.service_role_arn
  build_timeout = 20

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "GITHUB_USERNAME"
      value = "seyoon12"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = var.github_oauth_token
    }
  }
}

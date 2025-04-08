resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      } 
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Docker_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
        EnvironmentVariables = jsonencode([
          {
            name  = "REPOSITORY_URI"
            value = var.ecr_repository_url
          },
          {
            name  = "AWS_REGION"
            value = var.aws_region
          }
        ])
      }
    }
  }
}

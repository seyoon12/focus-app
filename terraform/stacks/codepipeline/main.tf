provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "codepipeline-ci-seyoon"
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "app-ecr"
}

module "codebuild" {
  source                 = "../../modules/codebuild"
  service_role_arn       = module.codebuild.codebuild_role_arn
  repository_uri         = module.ecr.repository_url
  github_oauth_token     = var.github_oauth_token
  codepipeline_role_name = module.codebuild.codebuild_role_name
}

module "codepipeline" {
  source                   = "../../modules/codepipeline"
  pipeline_name            = "codepipeline"
  artifact_bucket          = module.s3.bucket_name
  codebuild_project_name   = module.codebuild.codebuild_project_name
  role_arn                 = module.codepipeline.codepipeline_role_arn
  ecr_repository_url       = module.ecr.repository_url
  aws_region               = var.aws_region
  github_oauth_token       = var.github_oauth_token
  github_repo              = var.github_repo
  github_owner             = var.github_owner
  github_branch            = var.github_branch
} 

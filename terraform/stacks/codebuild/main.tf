provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "app-ecr"
}

module "codebuild" {
  source            = "../../modules/codebuild"
  service_role_arn  = module.codebuild.codebuild_role_arn
  repository_uri    = module.ecr.repository_url
  codepipeline_role_name = module.codebuild.codebuild_role_name
  github_oauth_token     = var.github_oauth_token    
}
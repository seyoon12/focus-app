variable "pipeline_name" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
}

variable "github_oauth_token" {
  type      = string
  sensitive = true
}

variable "codebuild_project_name" {
  type = string
}

variable "ecr_repository_url" {
  type        = string
}

variable "role_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

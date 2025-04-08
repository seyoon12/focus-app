variable "service_role_arn" {
  type        = string
}

variable "repository_uri" {
  type        = string
}

variable "codepipeline_role_name" {
  type        = string
}

variable "github_oauth_token" {
  type      = string
  sensitive = true
}
variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "admin_user" {
  default = "wntpqhd1326"
  type        = string
}

variable "github_owner" {
  default   = "seyoon12"
  type        = string
}

variable "github_repo" {
  default   = "all-terraform-aws-eks-cicd"
  type        = string
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
}

variable "github_branch" {
  type    = string
  default = "main"
}

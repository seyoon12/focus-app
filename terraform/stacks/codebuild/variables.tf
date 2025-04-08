variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "github_oauth_token" {
  type      = string
  sensitive = true
}

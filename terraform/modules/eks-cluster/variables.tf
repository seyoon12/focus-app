variable "cluster_name" {
  type = string
  default = "kubernetes"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}


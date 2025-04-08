variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "vpc_main"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "vpc_public_subnet" {
  description = "Public Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "Private Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
}

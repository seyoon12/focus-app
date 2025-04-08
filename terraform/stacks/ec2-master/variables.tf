variable "aws_region" {
  type = string
  default = "ap-northeast-2"  
}

variable "master_user_data_path" {
  type        = string
  default     = "../../scripts/master-userdata.sh"
}

variable "ami" {
  description = "ubuntu-22.04"
  type        = string
  default     = "ami-024ea438ab0376a47"
}

variable "instance_type" {
  description = "t3.medium"
  default = "t3.medium"
  type        = string
}


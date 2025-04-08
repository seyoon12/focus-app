# -----------------------------------------------------------------------------
# Required input variables
# -----------------------------------------------------------------------------
variable "eks_cluster_name" {
  type        = string
}

variable "instance_type" {
  type        = string
}

variable "desired_capacity" {
  type        = number
}

variable "min_size" {
  type        = number
}

variable "max_size" {
  type        = number
}

variable "subnets" {
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Optional input variables
# -----------------------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Optional) The name to be used for the self-managed node group. By default, the module will generate a unique name."
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with `name`."
  default     = "node-group"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Tags to apply to all tag-able resources."
  default     = {}
}

variable "node_labels" {
  type        = map(any)
  description = "(Optional) Kubernetes labels to apply to all nodes in the node group."
  default     = {}
}

variable "key_name" {
  type        = string
  description = "(Optional) The name of the EC2 key pair to configure on the nodes."
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "(Optional) A list of security group IDs to associate with the worker nodes. The module automatically associates the EKS cluster security group with the nodes."
  default     = []
}

# -----------------------------------------------------------------------------
# Local variables
# -----------------------------------------------------------------------------
resource "random_id" "name_suffix" {
  byte_length = 8
}

locals {
  node_group_name = coalesce(var.name, "${var.name_prefix}-${random_id.name_suffix.hex}")
}

variable "eks_cluster_endpoint" {
  type = string
}

variable "eks_cluster_ca" {
  type = string
}

variable "eks_cluster_token" {
  type = string
}

# -----------------------------------------------------------------------------
# IRSA kubecost for s3
# -----------------------------------------------------------------------------
variable "enable_kubecost_irsa" {
  type    = bool
  default = false
}

variable "kubecost_service_account" {
  type    = string
  default = "kubecost"
}

variable "kubecost_namespace" {
  type    = string
  default = "kubecost"
}

variable "oidc_provider_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "kubecost_s3_bucket_arn" {
  type = string
}

# -----------------------------------------------------------------------------
# IAM for ebs_csi
# -----------------------------------------------------------------------------
variable "enable_ebs_csi_irsa" {
  type        = bool
  default     = false
}
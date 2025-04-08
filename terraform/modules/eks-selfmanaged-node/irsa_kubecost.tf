# -----------------------------------------------------------------------------
# Kubecost irsa for s3
# -----------------------------------------------------------------------------
resource "aws_iam_role" "kubecost_irsa" {
  count = var.enable_kubecost_irsa ? 1 : 0
  name  = "kubecost-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        "StringEquals" = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.kubecost_namespace}:${var.kubecost_service_account}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "kubecost_s3_access" {
  count = var.enable_kubecost_irsa ? 1 : 0
  role  = aws_iam_role.kubecost_irsa[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = [
        var.kubecost_s3_bucket_arn,
        "${var.kubecost_s3_bucket_arn}/*"
      ]
    }]
  })
}
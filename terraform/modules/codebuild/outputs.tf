output "codebuild_project_name" {
  value = aws_codebuild_project.docker_build.name
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_name" {
  value = aws_iam_role.codebuild_role.name
}

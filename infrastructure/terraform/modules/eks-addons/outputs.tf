# =============================================================================
# EKS Add-ons Module Outputs
# =============================================================================

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IAM role"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

output "external_dns_role_arn" {
  description = "ARN of the External DNS IAM role"
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}

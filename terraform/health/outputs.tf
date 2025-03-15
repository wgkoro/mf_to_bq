# 必要に応じてアウトプットを定義
output "project_id" {
  description = "Google Cloud Project ID"
  value       = local.project_id
}

output "region" {
  description = "Default region"
  value       = local.region
}

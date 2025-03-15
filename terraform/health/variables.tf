# 必要に応じて変数を定義
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "asia-northeast1"
}

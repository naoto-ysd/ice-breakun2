variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ice-breakun2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "ice_breakun2"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "ice_breakun2_user"
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
}

variable "slack_channel" {
  description = "Slack channel name for notifications"
  type        = string
  default     = "#general"
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "ice-breakun2:latest"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "ice-breakun2"
    Environment = "development"
    ManagedBy   = "terraform"
  }
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in"
}

variable "environment" {
  type        = string
  description = "environment label"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be one of: dev, prod."
  }
}

variable "primary_region" {
  type        = string
  description = "The primary region for hosting resources"
  default     = "europe-west2"
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range to use for services"
  default     = "ip-range-svc"
}

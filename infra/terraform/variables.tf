variable "environment" {
  description = "Deployment environment (dev or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "esplake"
}

variable "tags" {
  description = "Common tags applied to every resource (cost tracking relies on these)."
  type        = map(string)
  default = {
    project = "spain-energy-lakehouse"
  }
}

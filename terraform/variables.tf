variable "resource_group_name" {
  description = "Name of the existing resource group to deploy into."
  type        = string
  default     = "rg-todo-app"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "swedencentral"
}

variable "app_name" {
  description = "Base name used for naming resources."
  type        = string
  default     = "todo-app"
}

variable "container_image" {
  description = "Full Docker image reference to deploy (e.g. docker.io/ssajaia/todo-app:latest)."
  type        = string
  default     = "docker.io/ssajaia/todo-app:latest"
}

variable "container_cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.25
}

variable "container_memory" {
  description = "Memory allocated to the container."
  type        = string
  default     = "0.5Gi"
}

variable "genesis_config" {
  type        = string
  description = "Content of genesis config TOML file"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace"
}

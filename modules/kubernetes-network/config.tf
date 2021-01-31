# Upload the genesis config to Kubernetes.
resource "kubernetes_config_map" "genesis_config" {
  metadata {
    namespace = var.namespace
    name      = "genesis-config"
  }
  data = {
    "dev-albatross.toml" = var.genesis_config
  }
} 

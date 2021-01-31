# Store Terraform state in microk8s cluster secret file, in default namespace.
terraform {
  backend "kubernetes" {
    config_path   = "/var/snap/microk8s/current/credentials/client.config"
    secret_suffix = "nimiq-albanet"
  }
}

# Connect to microk8s cluster with local credentials.
provider "kubernetes" {
  config_path = "/var/snap/microk8s/current/credentials/client.config"
}

# Create Kubernetes namespace for hosting resources.
resource "kubernetes_namespace" "albanet" {
  metadata {
    name = "albanet"
  }
}

# Install Albatross dev net.
module "albanet" {
  source = "../../modules/kubernetes-network"

  genesis_config = file("dev-albatross.toml")
  namespace      = "albanet"
}

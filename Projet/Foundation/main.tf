terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  zone   = var.zone
  region = var.region
}

# VPC - Virtual Private Cloud
resource "scaleway_vpc_private_network" "vpc" {
  name   = "my-vpc"
  region = var.region
}

# Kubernetes Cluster
resource "scaleway_k8s_cluster" "cluster" {
  name                        = "my-cluster"
  region                      = var.region
  cni                         = "cilium"
  version                     = "1.21.4"
  delete_additional_resources = false
  private_network_id          = scaleway_vpc_private_network.vpc.id
}

# Container Registry
resource "scaleway_registry_namespace" "container_registry" {
  name   = "my-container-registry"
  region = var.region
}

# Databases
resource "scaleway_rdb_instance" "database" {
  for_each  = var.environments
  name      = "${each.value}-database"
  region    = var.region
  engine    = "Redis"
  node_type = "DEV1-S"
}

#loadbalancer
# LoadBalancer IPs
resource "scaleway_lb_ip" "loadbalancer_ip" {
  for_each = var.environments
}

resource "scaleway_lb" "loadbalancer" {
  for_each = var.environments
  name     = "${each.value}-loadbalancer"
  ip_id    = scaleway_lb_ip.loadbalancer_ip[each.key].id
  type     = "lb-s"
}


# DNS Entries
resource "scaleway_domain_record" "dns_record" {
  for_each = var.environments
  name     = "calculatrice-${each.value == "prod" ? "" : "dev-"}${var.student}-polytech-dijon.kiowy.net"
  type     = "A"
  dns_zone = "polytech-dijon.kiowy.net"
  data     = scaleway_lb_ip.loadbalancer_ip[each.key].ip_address
}


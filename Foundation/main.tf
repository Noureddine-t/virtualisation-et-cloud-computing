terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}

# ==============================================================================
# RESEAU (VCN, Subnet, Gateway, Route, Firewall)
# ==============================================================================
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "calculatrice-vcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
}

resource "oci_core_default_route_table" "route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = "10.0.1.0/24"
  route_table_id    = oci_core_vcn.vcn.default_route_table_id
  security_list_ids = [oci_core_vcn.vcn.default_security_list_id]
}

# Ouverture des ports 22 (SSH), 80 (HTTP) et 443 (HTTPS)
resource "oci_core_default_security_list" "security_list" {
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

# ==============================================================================
# SERVEUR (Instance ARM "Always Free" avec 24Go RAM)
# ==============================================================================
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Trouver la dernière image Ubuntu 22.04 compatible ARM
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "arm_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "calculatrice-k3s-server"
  
  # Machine ARM gratuite
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # Cloud-init : Installation automatique et configuration
    user_data = base64encode(<<EOF
#!/bin/bash

# 1. Ouverture des ports dans le pare-feu interne Ubuntu (iptables)
iptables -I INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW --dport 6443 -j ACCEPT
netfilter-persistent save

# 2. Installation de K3s avec prise en charge de l'IP publique pour le certificat SSL
PUBLIC_IP=$(curl -s ifconfig.me)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $PUBLIC_IP" sh -s -

# 3. Préparation automatique du fichier Kubeconfig
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Remplacement automatique de l'IP locale par l'IP publique pour GitHub Actions
sed -i "s/127.0.0.1/$PUBLIC_IP/g" /home/ubuntu/.kube/config

# 4. Installation de ArgoCD (GitOps)
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
EOF
    )
  }
}

output "public_ip" {
  description = "L'adresse IP publique de votre serveur (A renseigner sur DuckDNS)"
  value       = oci_core_instance.arm_instance.public_ip
}

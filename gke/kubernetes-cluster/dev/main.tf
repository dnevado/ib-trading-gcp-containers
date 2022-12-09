terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.43.1"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "ib_trading_net" {
  provider = google-beta
  project = var.project_id
  name = "ib-trading-net-${var.env}"
  auto_create_subnetworks = false
}

#tfimport-terraform import google_compute_subnetwork.ib_trading_subnet __project__/europe-southwest1/ib-trading-subnet
resource "google_compute_subnetwork" "ib_trading_subnet" {
  provider = google-beta
  name = "ib-trading-subnet-${var.env}"
  ip_cidr_range = "10.172.0.0/20"
  project      = var.project_id
  region       = var.region
  # zone         = var.zone
  private_ip_google_access = true
  network = google_compute_network.ib_trading_net.id
}



#tfimport-terraform import google_compute_router.nat_router  __project__/europe-southwest1/nat-router
resource "google_compute_router" "nat_router" {
  provider = google-beta

  name = "nat-router-${var.env}"
  network = google_compute_network.ib_trading_net.id
  project      = var.project_id
  region       = var.region
  # zone         = var.zone
}
resource "google_compute_router_nat" "nat_config" {
  name = "nat-config-${var.env}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option = "AUTO_ONLY"
  log_config {
    enable = true
    filter = "ALL"
  }

  router = google_compute_router.nat_router.name
  project      = var.project_id
  region       = var.region


  depends_on = [
    google_compute_router.nat_router
  ]
}

#tfimport-terraform import google_container_cluster.ib_trading __project__//ib-trading
resource "google_container_cluster" "ib_trading" {
  provider = google-beta
  # zone = "europe-southwest1-a"
  project      = var.project_id
  # region       = var.region
  # zone         = var.zone
  name = "ib-trading-${var.env}"
  network = google_compute_network.ib_trading_net.id
  subnetwork = google_compute_subnetwork.ib_trading_subnet.id
  min_master_version = "latest"
  location = var.zone
  node_pool {
    name = "default-pool-${var.env}"
    initial_node_count = 1
    node_config {
      machine_type = "e2-small"
      disk_size_gb = 10
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring"
      ]
      tags = [
        "ib-trading-node-${var.env}"
      ]
    }
    management {
      auto_upgrade = true
      auto_repair = true
    }
  }

  ip_allocation_policy {
  }
  master_authorized_networks = [{
    cidr_block   = "${google_compute_instance.bastion_host.ip_address}/32"
    display_name = "Bastion Host Allowed Network CIDR ${var.env} for GKE"
  }]
  private_cluster_config {
    enable_private_nodes = false
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
}

#tfimport-terraform import google_compute_instance.bastion_host  __project__/europe-southwest1-a/bastion-host
resource "google_compute_instance" "bastion_host" {
  provider = google-beta

  name = "bastion-host-${var.env}"
  project      = var.project_id
  # region       = var.region
  zone         = var.zone
  machine_type = "e2-small"
  tags = [
    "bastion-host-${var.env}"
  ]
  boot_disk {
    auto_delete = true
    initialize_params {
      size = 10
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.ib_trading_net.id
    subnetwork = google_compute_subnetwork.ib_trading_subnet.id
  }
  metadata = {
    startup-script = <<-EOT
#!/bin/bash
# With the bastion host and the private cluster configured, you must deploy a proxy daemon in the host to forward traffic to the cluster control plane
# Add localhost as part of the allowed sources 
sudo apt-get -y install kubectl git tinyproxy
gcloud components install kubectl
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials ib-trading-${var.env} --zone ${var.zone} --internal-ip
sudo sed -i 's/\#Allow 10\.0\.0\.0\/8/Allow 0\.0\.0\.0/g' /etc/tinyproxy/tinyproxy.conf 
# sudo sed -i 's/\#Allow 10\.0\.0\.0\/8/Allow localhost/g' /etc/tinyproxy/tinyproxy.conf
sudo service tinyproxy restart  

EOT
  }
  service_account {
    email = "786272790820-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/source.read_only"]
  }
}
# %{for cidr in var.bastion_allowed_ranges}
#   echo "Allow ${cidr}" >> /etc/tinyproxy/tinyproxy.conf
# %{endfor}

resource "google_artifact_registry_repository" "ib-gateway" {
  location      =  var.region
  repository_id = "ib-gateway-${var.env}"
  description   = "ib-gateway ${var.env}"
  format        = "DOCKER" 
}

# And also add a firewall policy for the provided range(s):
# resource "google_compute_firewall" "allow_bastion" {
#  name    = "allow-bastion-proxy-${var.env}"
#  network = google_compute_network.ib_trading_net.id
#  project = var.project_id
#  allow {
#    protocol = "tcp"
#    ports    = ["8888"]
#  }
#  target_tags   = ["bastion"]
#   source_ranges = [
#    "0.0.0.0/0"
#  ]
# }

#tfimport-terraform import google_compute_firewall.ib_trading_net_allow_internal  __project__/ib-trading-net-allow-internal
#resource "google_compute_firewall" "ib_trading_net_allow_internal" {
#  provider = google-beta

#  name = "ib-trading-net-allow-internal-${var.env}"
#  direction = "INGRESS"
#  project      = var.project_id
#  priority = 1000
#  source_ranges = [
#    "10.172.0.0/20"
#  ]
#  network = google_compute_network.ib_trading_net.id
#  allow {
#    protocol = "all"
#  }
# }

#tfimport-terraform import google_compute_firewall.ib_trading_net_allow_ssh_bastion_host  __project__/ib-trading-net-allow-ssh-bastion-host
resource "google_compute_firewall" "ib_trading_net_allow_ssh_bastion_host_iap" {
  provider = google-beta
  project      = var.project_id
  name = "ib-trading-net-allow-ssh-bastion-host-iap-${var.env}"
  direction = "INGRESS"
  priority = 1000
  source_ranges = [
    "35.235.240.0/20"
  ]
  #target_tags = [
  #  "bastion-host-${var.env}"
  #]
  network = google_compute_network.ib_trading_net.id
  allow {
    protocol = "tcp"
    ports = [22,8888]
  }
}
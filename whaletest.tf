# Configure the Hetzner Cloud Provider
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

provider "hcloud" {
  token = "6CyqBPOG2qgaAgP69xhygaxK4w81Cl0UJSpNhnfYaqotPoIYdQOMo2QwJtVwuQsC"
}

# Cloud network configuration
resource "hcloud_network" "TestPrivNet" {
  name = "TestPrivNet"
  ip_range = "10.1.0.0/16"
}

resource "hcloud_network_subnet" "TestSubnet" {
  network_id = hcloud_network.TestPrivNet.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = "10.1.1.0/24"
}

resource "hcloud_server_network" "Connection1" {
  server_id = hcloud_server.node1.id
  network_id = hcloud_network.TestPrivNet.id
  ip = "10.1.1.1"
}

resource "hcloud_server_network" "Connection2" {
  server_id = hcloud_server.node2.id
  network_id = hcloud_network.TestPrivNet.id
  ip = "10.1.1.2"
}

resource "hcloud_load_balancer" "test_load_balancer" {
  name       = "test-load-balancer"
  load_balancer_type = "lb11"
  network_zone = "eu-central"
  target {
    type = "server"
    server_id = hcloud_server.node1.id
  }
  target {
    type = "server"
    server_id = hcloud_server.node2.id
  }
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
    load_balancer_id = hcloud_load_balancer.test_load_balancer.id
    protocol = "http"
}

# Cluster of two nodes and SSH keys addition
resource "hcloud_server" "node1" {
  name = "node1"
  image = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys=["${data.hcloud_ssh_key.ssh_key.id}"]
}

resource "hcloud_server" "node2" {
  name = "node2"
  image = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys=["${data.hcloud_ssh_key.ssh_key.id}"]
}

data "hcloud_ssh_key" "ssh_key" {
  fingerprint = "a6:e9:13:23:97:2b:5e:9d:f6:4c:2a:2b:72:50:72:ea"
}

# Inventory file for Ansible
resource "local_file" "inventory" {
  content = <<EOF
  [node1]
  node1 ansible_host=${hcloud_server.node1.ipv4_address}

  [node2]
  node2 ansible_host=${hcloud_server.node2.ipv4_address}
  
  [nodes:children]
  node1
  node2

  [nodes:vars]
  ansible_user=root
  ansible_ssh_private_key=id_rsa

  EOF
  filename = "hosts"
}

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
  backend "local" {
    path = "/home/amz/tf_tfstates/k3s-cluster/terraform.tfstate"
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pm_host}:8006/api2/json"
  pm_tls_insecure = "true"
}

# Server nodes
resource "proxmox_vm_qemu" "k3s_servers" {
  count       = "${var.k3s_server_nodes.count}"
  vmid        = "${format("%03d", var.k3s_server_nodes.vmid + count.index)}"
  name        = "${var.k3s_server_nodes.name}-${count.index + 1}"
  target_node = "${var.target_node}"
  clone       = "${var.k3s_server_nodes.template}"
  full_clone  = false
  cores       = "${var.k3s_server_nodes.cores}"
  sockets     = 1
  memory      = "${var.k3s_server_nodes.memory}"
  bootdisk    = "virtio0"
  agent       = 1

  disk {
    size    = "${var.k3s_server_nodes.disk_size}"
    type    = "virtio"
    storage = "local-lvm"
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }

  # Cloud init settings
  ipconfig0  = "ip=${var.network.base_ip}${var.network.final_ip + count.index}/${var.network.net},gw=${var.network.gateway}"
  ciuser     = "${var.user.name}"
  cipassword = "${var.user.password}"
  sshkeys    = file("../common/ssh_key/id_rsa.pub")
}

# Worker nodes
resource "proxmox_vm_qemu" "k3s_workers" {
  count       = "${var.k3s_worker_nodes.count}"
  vmid        = "${format("%03d", var.k3s_worker_nodes.vmid + count.index)}"
  name        = "${var.k3s_worker_nodes.name}-${count.index + 1}"
  target_node = "${var.target_node}"
  clone       = "${var.k3s_worker_nodes.template}"
  full_clone  = false
  cores       = "${var.k3s_worker_nodes.cores}"
  sockets     = 1
  memory      = "${var.k3s_worker_nodes.memory}"
  bootdisk    = "virtio0"
  agent       = 1

  disk {
    size    = "${var.k3s_worker_nodes.disk_size}"
    type    = "virtio"
    storage = "local-lvm"
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }

  # Cloud init settings
  ipconfig0  = "ip=${var.network.base_ip}${var.network.final_ip + var.k3s_server_nodes.count + count.index}/${var.network.net},gw=${var.network.gateway}"
  ciuser     = "${var.user.name}"
  cipassword = "${var.user.password}"
  sshkeys    = file("../common/ssh_key/id_rsa.pub")
}


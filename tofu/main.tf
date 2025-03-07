locals {
  sshkey = file(var.pub_key)
}

resource "proxmox_virtual_environment_vm" "proxmox_vm_master" {
  count       = var.num_k3s_masters
  name        = "k3s-master${count.index + 1}"
  node_name   = var.pm_node_name

  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }
  cpu {
    cores = var.cpu_cores
  }
  memory {
    dedicated = var.num_k3s_masters_mem
  }
  disk {
    datastore_id = var.datastore
    interface    = var.disk_interface
    discard      = var.disk_discard
    size         = var.disk_size
    ssd          = var.disk_ssd
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.master_ips[count.index]}/${var.networkrange}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [local.sshkey]
      password = var.pm_password
      username = var.host_user
    }

  }
    network_device {
    bridge = var.net_bridge
  }
}

resource "proxmox_virtual_environment_vm" "proxmox_vm_workers" {
  count       = var.num_k3s_nodes
  name        = "k3s-worker${count.index + 1}"
  node_name   = var.pm_node_name

  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }
  cpu {
    cores = var.cpu_cores
  }
  memory {
    dedicated = var.num_k3s_nodes_mem
  }
  disk {
    datastore_id = var.datastore
    interface    = var.disk_interface
    discard      = var.disk_discard
    size         = var.disk_size
    ssd          = var.disk_ssd
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/${var.networkrange}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [local.sshkey]
      password = var.pm_password
      username = var.host_user
    }

  }
    network_device {
    bridge = var.net_bridge
  }
}

resource "local_file" "k8s_file" {
  content = templatefile("./templates/k8s.tpl", {
    k3s_master_ip = join("\n", [
      for instance in proxmox_virtual_environment_vm.proxmox_vm_master :
         "${instance.ipv4_addresses[1][0]} ansible_ssh_private_key_file=${var.pvt_key}"
    ])
    k3s_node_ip = join("\n", [
      for instance in proxmox_virtual_environment_vm.proxmox_vm_workers :
         "${instance.ipv4_addresses[1][0]} ansible_ssh_private_key_file=${var.pvt_key}"
    ])
  })
  filename = "../inventory/my-cluster/hosts.ini"
}

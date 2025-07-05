terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

provider "proxmox" {
  endpoint            = "https://${var.pm_host}"
  username            = var.pm_user
  password            = var.pm_password
  insecure            = var.pm_tls_insecure
}

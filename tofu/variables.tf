variable "pm_user" {
  description = "The username for the proxmox user"
  type        = string
  sensitive   = false
  default     = "root@pam"

}
variable "pm_password" {
  description = "The password for the proxmox user"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = false
}

variable "pm_host" {
  description = "The hostname or IP of the proxmox server"
  type        = string
}

variable "pm_node_name" {
  description = "name of the proxmox node to create the VMs on"
  type        = string
  default     = "pve"
}

variable "pvt_key" {}

variable "num_k3s_masters" {
  default = 1
}

variable "num_k3s_masters_mem" {
  default = "4096"
}

variable "num_k3s_nodes" {
  default = 2
}

variable "num_k3s_nodes_mem" {
  default = "4096"
}

variable "template_id" {}


variable "master_ips" {
  description = "List of ip addresses for master nodes"
}

variable "worker_ips" {
  description = "List of ip addresses for worker nodes"
}

variable "networkrange" {
  default = 24
}

variable "gateway" {
  default = "192.168.1.254"
}

variable "net_bridge" {
  default = "vmbr0"
}

variable "datastore" {
  default = "local-lvm"
}

variable "disk_interface" {
  default = "scsi0"
}

variable "disk_discard" {
  default = "on"
}

variable "disk_size" {
  default = 10
}
variable "disk_ssd" {
  default = true
}

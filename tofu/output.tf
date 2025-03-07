
output "Master-IPS" {
  value = ["${proxmox_virtual_environment_vm.proxmox_vm_master.*.ipv4_addresses[0][1]}"]
}

output "worker-IPS" {
  value = ["${proxmox_virtual_environment_vm.proxmox_vm_workers.*.ipv4_addresses[0][1]}"]
}

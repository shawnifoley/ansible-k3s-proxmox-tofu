pm_host             = "pve.fol3y.us"
pm_node_name        = "pve"
deployment_name     = "prod"
host_user           = "sfoley"
pub_key             = "~/.ssh/id_ed25519.pub"
pvt_key             = "~/.ssh/id_ed25519"
template_id         = 1002
num_k3s_masters_mem = 4096
num_k3s_workers_mem = 4096
pool_id             = "production"
tags                = ["production", "k8s"]

# Set credentials via environment variables (recommended):
# export TF_VAR_pm_api_password="..."
# export TF_VAR_vm_user_password="..." # optional

master_ips = [
  "192.168.1.231",
  "192.168.1.232",
  "192.168.1.233"
]
worker_ips = [
  "192.168.1.234",
  "192.168.1.235"
]

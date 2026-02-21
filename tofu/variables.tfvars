pm_host             = "pve.fol3y.us"
pm_node_name        = "pve"
host_user           = "sfoley"
pub_key             = "~/.ssh/id_ed25519.pub"
pvt_key             = "~/.ssh/id_ed25519"
template_id         = 1002
num_k3s_workers_mem = 3072
pool_id             = "production"
tags                = ["production", "k8s"]

master_ips = [
  "192.168.1.221",
  "192.168.1.222",
  "192.168.1.223"
]
worker_ips = [
  "192.168.1.224",
  "192.168.1.225"
]

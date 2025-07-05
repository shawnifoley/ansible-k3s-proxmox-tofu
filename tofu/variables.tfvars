pm_host         = "pve.fol3y.us"
host_user       = "sfoley"
template_id     = 1002
num_k3s_workers = 3
pool_id         = "dev"
tags            = ["dev", "k8s"]

master_ips = [
  "192.168.1.20"
]
worker_ips = [
  "192.168.1.21",
  "192.168.1.22",
  "192.168.1.23",
]

# Build a Kubernetes cluster using k3s on Proxmox via Ansible and Tofu

## System requirements

* Ansible
* Tofu
* Proxmox server

### Proxmox setup

Grab and update the image with qemu-guest-agent

```bash
apt-get install libguestfs-tools
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
virt-customize focal-server-cloudimg-amd64.img --install qemu-guest-agent
```

Create the template

```bash
qm create 1002 --name "ubuntu-noble-cloudinit-template" --memory 2048 --net0 virtio,bridge=vmbr0
mv noble-server-cloudimg-amd64.img noble-server-cloudimg-amd64.qcow2
qm importdisk 1002 noble-server-cloudimg-amd64.qcow2 local-lvm
qm set 1002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1002-disk-0
qm set 1002 --ide2 local-lvm:cloudinit
qm set 1002 --bootdisk scsi0
```
On proxmox server edit the `cloud-init` section for `ubuntu-noble-cloudinit-template`

Move VM -> template

```bash
qm template 9000
```

### Tofu setup

edit `tofu/variables.tfvars` then run tofu to bring up the servers

```bash
cd tofu/
tofu init
tofu plan --var-file=variables.tfvars
tofu apply --var-file=variables.tfvars
```

### Ansible setup

Update `inventory/my-cluster/group_vars/all.yml`
Tofu setup the following inventory for ansible `inventory/my-cluster/hosts.ini`

Start provisioning of the cluster using the following command:

```bash
ansible-playbook -i inventory/my-cluster/hosts.ini site.yml
```

k3s cluster should be up and running with the playbook copying `~/.kube/config`

### Kubernetes

[kubectl reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)

### Argocd/Fluxcd
todo

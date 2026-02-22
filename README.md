# Build a Kubernetes cluster using k3s on Proxmox via Ansible and Tofu

## System requirements

* Ansible
* Tofu
* Proxmox server

### Proxmox setup

Grab and update the image with qemu-guest-agent

```bash
apt-get install libguestfs-tools
wget https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img
virt-customize -a ubuntu-22.04-server-cloudimg-amd64.img --install qemu-guest-agent
```

Create the template

```bash
export vmid=1002
qm create $vmid --name "ubuntu-noble-cloudinit-template" --memory 2048 --net0 virtio,bridge=vmbr0
mv ubuntu-22.04-server-cloudimg-amd64.img ubuntu-22.04-server-cloudimg-amd64.gcow2
qm importdisk $vmid ubuntu-22.04-server-cloudimg-amd64.qcow2 local-lvm
qm set $vmid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1002-disk-0
qm set $vmid --ide2 local-lvm:cloudinit
qm set $vmid --bootdisk scsi0
```
On proxmox server edit the `cloud-init` section for `ubuntu-22.04-server-cloudimg-amd64`

Move VM -> template

```bash
qm template $vmid
```

### Tofu setup (multi-deployment)

Use one tfvars file per deployment:
- `tofu/variables.dev.tfvars`
- `tofu/variables.prod.tfvars`

Each deployment writes inventory to:
- `ansible/inventory/dev/hosts.ini`
- `ansible/inventory/prod/hosts.ini`

```bash
cd tofu/
export TF_VAR_pm_api_password="your-proxmox-api-password"
tofu init

# dev
tofu plan --var-file=variables.dev.tfvars
tofu apply --var-file=variables.dev.tfvars

# prod
tofu plan --var-file=variables.prod.tfvars
tofu apply --var-file=variables.prod.tfvars
```

Or from repo root using the provided `Makefile` (separate state files by environment):

```bash
export TF_VAR_pm_api_password="your-proxmox-api-password"

# dev uses tofu/terraform.dev.tfstate
make tofu-plan-dev
make tofu-apply-dev

# prod uses tofu/terraform.prod.tfstate
make tofu-plan-prod
make tofu-apply-prod
```

### Ansible setup (per deployment)

All Ansible vars are environment-specific and live in:
- `ansible/inventory/dev/group_vars/all.yml`
- `ansible/inventory/prod/group_vars/all.yml`

ArgoCD ingress uses external Traefik via Helm (not bundled k3s Traefik).
Enable/install Traefik and set chart version with:
- `traefik: true`
- `traefik_chart_version: "v39.0.2"`

Run with the target inventory:

```bash
cd ansible/

# dev
ansible-playbook -i inventory/dev/hosts.ini main.yml

# prod
ansible-playbook -i inventory/prod/hosts.ini main.yml
```

Or from repo root:

```bash
make ansible-dev
make ansible-prod
```

k3s cluster should be up and running with the playbook copying `~/.kube/kubeconfig-{dev|prod}`

### Kubernetes

[kubectl reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)

### Argocd

## 1. Check if ArgoCD Namespace Exists

```bash
kubectl get namespace argocd
```

## 2. Verify ArgoCD Components

Check if the core ArgoCD pods are running:
```bash
kubectl get pods -n argocd
```

You should see several pods including:
- argocd-application-controller
- argocd-dex-server
- argocd-redis
- argocd-repo-server
- argocd-server

## 3. Check ArgoCD Deployments

```bash
kubectl get deployments -n argocd
```

## 4. Check ArgoCD Services

```bash
kubectl get services -n argocd
```

The service `argocd-server` is the main API and UI server.

## 5. Get ArgoCD Server URL

If using LoadBalancer or NodePort:
```bash
kubectl get svc argocd-server -n argocd
```

## 6. Get Initial Admin Password

For ArgoCD versions 2.x+:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
or
argocd admin initial-password -n argocd
```

## 7. Update Admin Password

```bash
argocd login <server address>
argocd account update-password
```

## 8. Verify ArgoCD CLI (if installed locally)

If you have the ArgoCD CLI installed:
```bash
argocd version
```

## 9. Check ArgoCD Applications

```bash
kubectl get applications -n argocd
```

Or using ArgoCD CLI:
```bash
argocd app list
```

## 10. Check ArgoCD Configuration

```bash
kubectl get configmap argocd-cm -n argocd
kubectl get configmap argocd-rbac-cm -n argocd
```

### MetalLB

## 1. Check if MetalLB Namespace Exists

```bash
kubectl get namespace metallb-system
```

## 2. Verify MetalLB Resources

Check if the controller and speaker pods are running:
```bash
kubectl get pods -n metallb-system
```

Check the deployments:
```bash
kubectl get deployments -n metallb-system
```

Check the DaemonSets (for speaker):
```bash
kubectl get daemonsets -n metallb-system
```

## 3. Check MetalLB Configuration

Verify the MetalLB configuration:
```bash
kubectl get configmap -n metallb-system
```

For newer versions using CRDs:
```bash
kubectl get ipaddresspools.metallb.io -A
kubectl get l2advertisements.metallb.io -A
```

## 4. Check Logs for Issues

Check logs of the controller:
```bash
kubectl logs -n metallb-system -l app=metallb,component=controller
```

Check logs of speaker pods:
```bash
kubectl logs -n metallb-system -l app=metallb,component=speaker
```

## 5. Test with a LoadBalancer Service

Create a test service to verify MetalLB is assigning IPs:
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get service nginx
```

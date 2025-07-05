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

Tofu setup the following inventory for ansible `ansible/hosts.ini`<br>
Verify variables in `ansible/group_vars/all.yml`

Start provisioning of the cluster using the following command:

```bash
ansible-playbook  main.yml
```

k3s cluster should be up and running with the playbook copying `~/.kube/config`

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

For ArgoCD versions before 2.x:
```bash
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

For ArgoCD versions 2.x+:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 7. Check ArgoCD Version

```bash
kubectl exec -it -n argocd deployment/argocd-server -- argocd version
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

# HA k3s cluster with kube-vip, MetalLB, Longhorn and Rancher

- 3 server nodes with embedded etcd database
- 2 optional worker nodes
- 1 VIP exposex kubernetes API
- kube-vip manages the VIP, reassigning it when the leader node gets down (HA)
- metallb to expose the services over a defined IP range
- local storage available in k3s by default
- volumes management and claiming with Longhorn
- Rancher to manage this and/or other clusters

## Infra

Created on Proxmox using Terraform recipes for VMs creation and Ansible playbooks for base configuration.

Based on Debian 11.

Edit terraform/variables.yaml to set your own configuration and replace common/ssh_key/ files with you keys.

```
$ export PM_USER=<YOUR_PROXMOX_USER>
$ export PM_PASSWORD=<YOUR_PROXMOX_PASSWORD>
$ cd terraform
$ terraform init
$ terraform apply
$ cd ../ansible
$ ansible-playbook main.yaml
```


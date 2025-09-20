resource "cloudstack_template" "ubuntu24" {
  name       = "Ubuntu 24.04 LTS x64"
  format     = "QCOW2"
  hypervisor = "KVM"
  os_type    = "Ubuntu 24.04 LTS"
  url        = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  zone       = var.cloudstack_zone
  project    = var.cloudstack_project
}

resource "cloudstack_template" "rocky10" {
  name       = "Rocky Linux 10"
  format     = "QCOW2"
  hypervisor = "KVM"
  os_type    = "Rocky Linux 10"
  url        = "https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2"
  zone       = var.cloudstack_zone
  project    = var.cloudstack_project
}

resource "cloudstack_template" "rocky9" {
  name       = "Rocky Linux 9"
  format     = "QCOW2"
  hypervisor = "KVM"
  os_type    = "Rocky Linux 9"
  url        = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  zone       = var.cloudstack_zone
  project    = var.cloudstack_project
}

resource "cloudstack_template" "alma9" {
  name       = "AlmaLinux 9"
  format     = "QCOW2"
  hypervisor = "KVM"
  os_type    = "AlmaLinux 9"
  url        = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  zone       = var.cloudstack_zone
  project    = var.cloudstack_project
}

resource "cloudstack_template" "alma10" {
  name       = "AlmaLinux 10"
  format     = "QCOW2"
  hypervisor = "KVM"
  os_type    = "AlmaLinux 10"
  url        = "https://repo.almalinux.org/almalinux/10/cloud/x86_64_v2/images/AlmaLinux-10-GenericCloud-latest.x86_64_v2.qcow2"
  zone       = var.cloudstack_zone
  project    = var.cloudstack_project
}


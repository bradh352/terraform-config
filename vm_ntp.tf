resource "cloudstack_affinity_group" "ntp" {
  name    = "ntp"
  type    = "non-strict host anti-affinity"
  project = var.cloudstack_project
}

module "instance_ntp1" {
  source             = "./modules/cloudstack_instance"
  name               = "ntp1"
  group              = "ntp"
  service_offering   = "g1.1c2g"
  network_id         = cloudstack_network.ntp.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.4.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.ntp.id ]
}

module "instance_ntp2" {
  source             = "./modules/cloudstack_instance"
  name               = "ntp2"
  group              = "ntp"
  service_offering   = "g1.1c2g"
  network_id         = cloudstack_network.ntp.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.4.12"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.ntp.id ]
}

module "instance_host7nic" {
  source             = "./modules/cloudstack_instance"
  name               = "host7nic"
  service_offering   = "host7nic"
  network_id         = cloudstack_network.ntp.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.4.13"
  project            = var.cloudstack_project
  root_disk_size     = 20
  extraconfig        = "%3Chostdev%20mode%3D%27subsystem%27%20type%3D%27pci%27%20managed%3D%27yes%27%3E%0A%20%20%3Cdriver%20name%3D%27vfio%27%2F%3E%0A%20%20%3Csource%3E%0A%20%20%20%20%3Caddress%20domain%3D%270x0000%27%20bus%3D%270x05%27%20slot%3D%270x00%27%20function%3D%270x0%27%2F%3E%0A%20%20%3C%2Fsource%3E%0A%20%20%3Ctarget%3E%0A%20%20%20%20%3Caddress%20type%3D%27pci%27%20domain%3D%270x0000%27%20bus%3D%270x05%27%20slot%3D%270x00%27%20function%3D%270x0%27%2F%3E%0A%20%20%3C%2Ftarget%3E%0A%3C%2Fhostdev%3E"
}

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

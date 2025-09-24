resource "cloudstack_affinity_group" "nfs" {
  name    = "nfs"
  type    = "non-strict host anti-affinity"
  project = var.cloudstack_project
}

module "instance_nfs1" {
  source             = "./modules/cloudstack_instance"
  name               = "nfs1"
  group              = "nfs"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.nfs.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.7.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.nfs.id ]
}

module "instance_nfs2" {
  source             = "./modules/cloudstack_instance"
  name               = "nfs2"
  group              = "nfs"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.nfs.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.7.12"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.nfs.id ]
}

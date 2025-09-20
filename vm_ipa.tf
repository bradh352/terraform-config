resource "cloudstack_affinity_group" "ipa" {
  name    = "ipa"
  type    = "non-strict host anti-affinity"
  project = var.cloudstack_project
}

module "instance_ipa1" {
  source           = "./modules/cloudstack_instance"
  name               = "ipa1"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.ipa.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.55.2.11"
  project            = var.cloudstack_project
  root_disk_size     = 40
  affinity_group_ids = [ cloudstack_affinity_group.ipa.id ]
}

module "instance_ipa2" {
  source             = "./modules/cloudstack_instance"
  name               = "ipa2"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.ipa.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.55.2.12"
  project            = var.cloudstack_project
  root_disk_size     = 40
  affinity_group_ids = [ cloudstack_affinity_group.ipa.id ]
}

module "instance_ipa3" {
  source             = "./modules/cloudstack_instance"
  name               = "ipa3"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.ipa.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.55.2.13"
  project            = var.cloudstack_project
  root_disk_size     = 40
  affinity_group_ids = [ cloudstack_affinity_group.ipa.id ]
}

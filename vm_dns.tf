resource "cloudstack_affinity_group" "dns" {
  name    = "dns"
  type    = "non-strict host anti-affinity"
  project = var.cloudstack_project
}

module "instance_dns1" {
  source             = "./modules/cloudstack_instance"
  name               = "dns1"
  service_offering   = "g1.1c2g"
  network_id         = cloudstack_network.dns.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.55.1.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.dns.id ]
}

module "instance_dns2" {
  source             = "./modules/cloudstack_instance"
  name               = "dns2"
  service_offering   = "g1.1c2g"
  network_id         = cloudstack_network.dns.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.55.1.12"
  project            = var.cloudstack_project
  root_disk_size     = 20
  affinity_group_ids = [ cloudstack_affinity_group.dns.id ]
}

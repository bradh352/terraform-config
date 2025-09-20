module "instance_bastion" {
  source           = "./modules/cloudstack_instance"
  name             = "bastion"
  service_offering = "g1.1c2g"
  template         = cloudstack_template.rocky10.id
  ip_address       = "10.55.99.10"
  network_id       = cloudstack_network.su.id
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  root_disk_size   = 20
}

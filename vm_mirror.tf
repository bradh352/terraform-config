module "instance_mirror" {
  source             = "./modules/cloudstack_instance"
  name               = "mirror"
  service_offering   = "g1.1c2g"
  network_id         = cloudstack_network.mirror.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.2.11"
  project            = var.cloudstack_project
  root_disk_size     = 4096
}

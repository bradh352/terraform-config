module "instance_mirror" {
  source             = "./modules/cloudstack_instance"
  name               = "mirror1"
  group              = "mirror"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.mirror.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.2.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
}

resource "cloudstack_disk" "mirror_data_disk" {
  name               = "mirror_data_disk"
  attach             = "true"
  disk_offering      = var.cloudstack_disk_offering
  size               = 8192
  virtual_machine_id = instance_mirror.id
  zone               = var.cloudstack_zone
  project            = var.cloudstack_project
}

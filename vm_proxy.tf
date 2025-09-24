module "instance_secureproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "secureproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.10"
  project            = var.cloudstack_project
  root_disk_size     = 20
}

module "instance_cacheproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "cacheproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.20"
  project            = var.cloudstack_project
  root_disk_size     = 100
}

module "instance_gutproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "gitproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.30"
  project            = var.cloudstack_project
  root_disk_size     = 100
}

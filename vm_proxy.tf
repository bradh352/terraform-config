module "instance_secureproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "secureproxy1"
  group              = "secureproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
}

module "instance_cacheproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "cacheproxy1"
  group              = "cacheproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.21"
  project            = var.cloudstack_project
  root_disk_size     = 100
}

module "instance_gutproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "gitproxy1"
  group              = "gitproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.proxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.5.31"
  project            = var.cloudstack_project
  root_disk_size     = 100
}

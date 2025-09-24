module "instance_ldapproxy" {
  source             = "./modules/cloudstack_instance"
  name               = "ldapproxy1"
  group              = "ldapproxy"
  service_offering   = "g1.2c4g"
  network_id         = cloudstack_network.ldapproxy.id
  template           = cloudstack_template.rocky10.id
  zone               = var.cloudstack_zone
  ip_address         = "10.252.6.11"
  project            = var.cloudstack_project
  root_disk_size     = 20
}

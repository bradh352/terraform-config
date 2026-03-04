resource "cloudstack_instance" "instance" {
  name               = var.name
  service_offering   = var.service_offering
  network_id         = var.network_id
  template           = var.template
  zone               = var.zone
  ip_address         = var.ip_address
  project            = var.project
  root_disk_size     = var.root_disk_size
  expunge            = true
  user_data          = file("cloud-init")
  lifecycle {
    ignore_changes = [ user_data ]
  }
}

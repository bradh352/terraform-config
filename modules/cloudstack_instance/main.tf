terraform {
  required_providers {
    cloudstack = {
      source  = "cloudstack/cloudstack"
    }
  }
}

variable "affinity_group_ids" {
  description = "Affinity group ids"
  type        = list
  default     = null
  nullable    = true
}

variable "name" {
  description = "Instance Name"
  type        = string
}

variable "service_offering" {
  description = "Service Offering"
  type        = string
}

variable "network_id" {
  description = "Network ID"
  type        = string
}

variable "zone" {
  description = "Cloudstack Zone"
  type        = string
}

variable "project" {
  description = "Cloudstack Project"
  type        = string
  nullable    = true
  default     = null
}

variable "template" {
  description = "Instance template"
  type        = string
}

variable "ip_address" {
  description = "IP Address to assign to instance"
  type        = string
  nullable    = true
  default     = null
}

variable "root_disk_size" {
  description = "Root Disk Size"
  type        = string
  default     = "20"
}

resource "cloudstack_instance" "this" {
  name               = var.name
  service_offering   = var.service_offering
  network_id         = var.network_id
  template           = var.template
  zone               = var.zone
  ip_address         = var.ip_address
  project            = var.project
  root_disk_size     = var.root_disk_size
  expunge            = true
  uefi               = true
  user_data          = file("cloud-init")
  lifecycle {
    ignore_changes = [ user_data ]
  }
  details            = {
    "rootDiskController" = "scsi"
    "iothreads"          = "1"
    "io.policy"          = "io_uring"
  }
}

output "id" {
  description = "The ID of the cloudstack instance"
  value       = cloudstack_instance.this.id
}

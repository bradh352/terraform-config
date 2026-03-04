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
}

variable "template" {
  description = "Instance template"
  type        = string
}

variable "ip_address" {
  description = "IP Address to assign to instance"
  type        = string
}

variable "root_disk_size" {
  description = "Root Disk Size"
  type        = string
  default     = "20"
}

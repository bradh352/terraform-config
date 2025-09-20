variable "cloudstack_api_url" {
  description = "Cloudstack API URL Endpoint"
  type        = string
  default     = "https://cs.testenv.bradhouse.dev/client/api"
}

variable "cloudstack_api_key" {
  description = "Cloudstack API Key"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "cloudstack_api_secret" {
  description = "Cloudstack API Secret"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "cloudstack_zone" {
  description = "Cloudstack Zone for deployment"
  type        = string
  default     = "testlab"
}

variable "cloudstack_project" {
  description = "Cloudstack Project to assign resources"
  type        = string
  default     = "infra"
}

variable "cloudstack_networkoffering_isolated" {
  description = "Cloudstack Network Offering to use for Isolated Networks"
  type        = string
  default     = "ConfigDriveIsolatedNetworkOfferingForVpcNetworks"
}

variable "cloudstack_network_domain" {
  description = "Base network domain"
  type        = string
  default     = "pc.testenv.bradhouse.dev"
}

variable "bootstrap" {
  description = "Performing Bootstap.  Will grant some nodes additional egress rules when this is set.  Should be disabled after provisioning."
  type        = bool
  default     = false
}

variable "cloudstack_default_instance_service_offering" {
  description = "Default service offering to use for instances."
  type        = string
  default     = "g1.2c4g"
}

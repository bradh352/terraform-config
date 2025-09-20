# NOTE: Need to debug, Dual Stack throws error of:
#    2025-09-20 12:22:45,814 ERROR [c.c.n.IpAddressManagerImpl] (API-Job-Executor-15:[ctx-6bc4b3f4, job-476, ctx-5149f5da]) (logid:f1180184) Unable to find VLAN IP range that support both IPv4 and IPv6
# 2025-09-20 12:22:45,823 ERROR [c.c.n.IpAddressManagerImpl] (API-Job-Executor-15:[ctx-6bc4b3f4, job-476, ctx-5149f5da]) (logid:f1180184) Unable to get source nat ip address for account

locals {
  subnet_vpc = "10.55.0.0/16"
}

resource "cloudstack_vpc" "infra_vpc" {
  name           = "infra_vpc"
  cidr           = local.subnet_vpc
  vpc_offering   = "VPC HA"
  network_domain = var.cloudstack_network_domain
  zone           = var.cloudstack_zone
  project        = var.cloudstack_project
}


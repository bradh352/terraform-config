locals {
  subnet_dns          = "10.252.1.0/24"

  aclrules_access_dns = {
    start_idx = 1100
    rules     = [
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_dns ]
        protocol     = "tcp"
        port         = "53"
        traffic_type = "egress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ local.subnet_dns ]
        protocol     = "udp"
        port         = "53"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_dns = {
    start_idx = 30000
    rules     = [
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "53"
        traffic_type = "ingress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "53"
        traffic_type = "ingress"
      },
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "53"
        traffic_type = "egress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "53"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_dns_all = concat(local.aclrules_common, [ local.aclrules_dns ])
}

resource "cloudstack_network_acl" "dns" {
  name   = "dns"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_dns" {
  source   = "./modules/cloudstack_network_acl"
  acl_id   = cloudstack_network_acl.dns.id
  managed  = true
  rulelist = local.aclrules_dns_all
}

resource "cloudstack_network" "dns" {
  name             = "dns"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_dns
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.dns.id
}

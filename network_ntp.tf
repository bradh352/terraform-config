locals {
  subnet_ntp = "10.252.4.0/24"
  aclrules_access_ntp = {
    start_idx = 1400
    rules     = [
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ local.subnet_ntp ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ntp = {
    start_idx = 30000
    rules     = [
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "egress"
      },
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_ntp_all = concat(local.aclrules_common, [ local.aclrules_ntp ])
}

resource "cloudstack_network_acl" "ntp" {
  name   = "ntp"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_ntp" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.ntp.id
  managed   = true
  bootstrap = var.bootstrap
  rulelist  = local.aclrules_ntp_all
}

resource "cloudstack_network" "ntp" {
  name             = "ntp"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ntp
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ntp.id
}

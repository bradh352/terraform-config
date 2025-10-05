locals {
  subnet_mirror = "10.252.2.0/24"
  aclrules_access_mirror = {
    start_idx = 1200
    rules     = [
      {
        description  = "http mirror"
        action       = "allow"
        cidr_list    = [ local.subnet_mirror ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "http and https mirror"
        action       = "allow"
        cidr_list    = [ local.subnet_mirror ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_mirror = {
    start_idx = 30000
    rules     = [
      {
        description  = "http mirror"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "80"
        traffic_type = "ingress"
      },
      {
        description  = "https mirror"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "443"
        traffic_type = "ingress"
      },
      {
        description  = "http"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "https"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "443"
        traffic_type = "egress"
      },
      {
        description  = "rsync"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "873"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_mirror_all = concat(local.aclrules_common, [ local.aclrules_access_secureproxy, local.aclrules_mirror ])
}

resource "cloudstack_network_acl" "mirror" {
  name   = "mirror"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_mirror" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.mirror.id
  managed   = true
  bootstrap = var.bootstrap
  rulelist  = local.aclrules_mirror_all
}

resource "cloudstack_network" "mirror" {
  name             = "mirror"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_mirror
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.mirror.id
}

locals {
  subnet_nfs          = "10.252.7.0/24"

  aclrules_access_nfs = {
    start_idx = 1700
    rules     = [
      {
        description  = "nfs"
        action       = "allow"
        cidr_list    = [ local.subnet_nfs ]
        protocol     = "tcp"
        port         = "2049"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_nfs = {
    start_idx = 30000
    rules     = [
      {
        description  = "nfs"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "2049"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_nfs_all = concat(local.aclrules_common, [ local.aclrules_nfs ])
}

resource "cloudstack_network_acl" "nfs" {
  name   = "nfs"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_nfs" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.nfs.id
  managed   = true
  bootstrap = vars.bootstrap
  rulelist  = local.aclrules_nfs_all
}

resource "cloudstack_network" "nfs" {
  name             = "nfs"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_nfs
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.nfs.id
}

locals {
  subnet_hypervisor  = "10.10.100.0/24"
  hypervisors        = [ "10.10.100.0/28" ] # Its really .2-.8 ... but didn't feel like typing them all out

  aclrules_access_ceph = {
    start_idx = 40000
    rules     = [
      {
        description  = "access ceph mon v1"
        action       = "allow"
        cidr_list    = local.hypervisors
        protocol     = "tcp"
        port         = "6789"
        traffic_type = "egress"
      },
      {
        description  = "access ceph mon v2"
        action       = "allow"
        cidr_list    = local.hypervisors
        protocol     = "tcp"
        port         = "3300"
        traffic_type = "egress"
      },
      {
        description  = "access ceph osd and mds"
        action       = "allow"
        cidr_list    = local.hypervisors
        protocol     = "tcp"
        port         = "6800-7568"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_hypervisor = {
    start_idx = 30000
    rules     = [
      {
        description  = "ceph mon v1"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "6789"
        traffic_type = "ingress"
      },
      {
        description  = "ceph mon v2"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "3300"
        traffic_type = "ingress"
      },
      {
        description  = "ceph osd and mds"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "6800-7568"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_hypervisor_all = [ local.aclrules_hypervisor ]
}

resource "cloudstack_network_acl" "hypervisor" {
  name   = "hypervisor"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_hypervisor" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.hypervisor.id
  managed   = true
  bootstrap = var.bootstrap
  rulelist  = local.aclrules_hypervisor_all
}

# Have to create manually because this doesn't create it right for some reason
#
# via UI or :
# cmk createPrivateGateway gateway=10.10.100.1 ipaddress=10.10.100.99 netmask=255.255.255.0 vpcid=62940001-aa31-4da1-abf4-5a8c4f7a7f76 aclid=346df974-6f58-4a8e-94ab-a6559e7bbf2f physicalnetworkid=1b567de0-2a6d-4583-994d-c250b58b5e0d vlan=vlan://untagged
#
#resource "cloudstack_private_gateway" "default" {
#  gateway             = "10.10.100.1"
#  ip_address          = "10.10.100.99"
#  netmask             = "255.255.255.0"
#  vlan                = "vlan://untagged"
#  acl_id              = cloudstack_network_acl.hypervisor.id
#  vpc_id              = cloudstack_vpc.infra_vpc.id
#  physical_network_id = "mgmt"
#}

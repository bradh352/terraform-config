locals {
  subnet_su          = "10.252.0.0/24"

  aclrules_access_su = {
    start_idx = 1000
    rules     = [
      {
        description  = "allow bastion connection to network"
        action       = "allow"
        cidr_list    = [ local.subnet_su ]
        protocol     = "tcp"
        port         = "22"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_su = {
    start_idx = 30000
    rules     = [
      {
        description  = "disallow VPC subnets from SSHing into bastion"
        action       = "deny"
        cidr_list    = [ local.subnet_vpc ]
        protocol     = "tcp"
        port         = "22"
        traffic_type = "ingress"
      },
      {
        description  = "allow public networks to SSH into bastion"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "22"
        traffic_type = "ingress"
      },
      {
        description  = "allow bastion connection to network"
        action       = "allow"
        cidr_list    = [ local.subnet_vpc ]
        protocol     = "tcp"
        port         = "22"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_su_all = concat(local.aclrules_common, [ local.aclrules_su ])
}

resource "cloudstack_network_acl" "su" {
  name   = "su"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_su" {
  source   = "./modules/cloudstack_network_acl"
  acl_id   = cloudstack_network_acl.su.id
  managed  = true
  rulelist = local.aclrules_su_all
}

resource "cloudstack_network" "su" {
  name             = "su"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_su
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.su.id
}

resource "cloudstack_ipaddress" "bastion" {
  vpc_id = cloudstack_vpc.infra_vpc.id
  zone   = var.cloudstack_zone
}

resource "cloudstack_port_forward" "bastion" {
  ip_address_id = cloudstack_ipaddress.bastion.id

  forward {
    protocol           = "tcp"
    private_port       = 22
    public_port        = 5022
    virtual_machine_id = module.instance_bastion.id
  }
}

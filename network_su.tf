locals {
  subnet_su = "10.252.0.0/24"
  aclrules_access_su = [
    {
      description  = "allow bastion connection to network"
      action       = "allow"
      cidr_list    = [ local.subnet_su ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "22" ]
      traffic_type = "ingress"
    }
  ]
  aclrules_access_su_list = [
    {
      start_idx = 0
      rules     = local.aclrules_access_su
    }
  ]
  aclrules_su = {
    start_idx = 50
    rules = [
      {
        description  = "disallow VPC subnets from SSHing into bastion"
        action       = "deny"
        cidr_list    = [ local.subnet_vpc ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        ports        = [ "22" ]
        traffic_type = "ingress"
      },
      {
        description  = "disallow public networks to SSH into bastion"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        ports        = [ "22" ]
        traffic_type = "ingress"
      },
      {
        description  = "allow bastion connection to network"
        action       = "allow"
        cidr_list    = [ local.subnet_vpc ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        ports        = [ "22" ]
        traffic_type = "egress"
      }
    ]
  }
  aclrules_su_all = concat(local.aclrules_common_list, [ local.aclrules_su ])
}

resource "cloudstack_network_acl" "su" {
  name   = "su"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "su" {
  acl_id  = cloudstack_network_acl.su.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_su_all : [
          for rule in list.rules : {
            rule_number  = "${list.start_idx + index(list.rules, rule) + 1}"
            description  = rule.description
            action       = rule.action
            cidr_list    = rule.cidr_list
            protocol     = rule.protocol
            icmp_type    = rule.icmp_type
            icmp_code    = rule.icmp_code
            ports        = rule.ports
            traffic_type = rule.traffic_type
          }
        ]
      ])
    content {
      rule_number  = rule.value.rule_number
      description  = "${rule.value.description}: ${rule.value.action} ${rule.value.traffic_type}"
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      ports        = rule.value.ports
      traffic_type = rule.value.traffic_type
    }
  }

  # Bootstrap-only rules
  dynamic "rule" {
    for_each = var.bootstrap ? local.aclrules_bootstrap : []
    content {
      description  = rule.value.description
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      ports        = rule.value.ports
      traffic_type = rule.value.traffic_type
    }
  }
  # Deny all others
  rule {
    description  = "deny egress by default"
    rule_number  = 65535
    action       = "deny"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "all"
    traffic_type = "egress"
  }
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

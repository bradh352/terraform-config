terraform {
  required_providers {
    cloudstack = {
      source  = "local/cloudstack/cloudstack"
    }
  }
}

variable "acl_id" {
  description = "ACL ID"
  type        = string
}

variable "managed" {
  description = "Managed"
  type        = bool
  default     = true
}

variable "rulelist" {
  description = "Rule List"
  type        = any
}

variable "bootstrap" {
  description = "If true, will allow 443, 80, and 53 to the outside world"
  type        = bool
}

locals {
  aclrules_bootstrap = {
    start_idx = 65000
    rules     = [
      {
        description  = "bootstrap allow http"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap allow https"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap allow dns tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap allow dns udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      }
    ]
  }
}

resource "cloudstack_network_acl_rule" "this" {
  acl_id             = var.acl_id
  managed            = var.managed
  dynamic "ruleset" {
    for_each = flatten([
        for list in concat(var.rulelist, var.bootstrap?[local.aclrules_bootstrap]:[]) : [
          for rule in list.rules : {
            rule_number  = "${list.start_idx + index(list.rules, rule) + 1}"
            description  = try(rule.description, "")
            action       = rule.action
            cidr_list    = rule.cidr_list
            protocol     = rule.protocol
            icmp_type    = try(rule.icmp_type, null)
            icmp_code    = try(rule.icmp_code, null)
            port         = try(rule.port, null)
            traffic_type = rule.traffic_type
          }
        ]
      ])
    content {
      rule_number  = ruleset.value.rule_number
      description  = "${ruleset.value.description}: ${ruleset.value.action} ${ruleset.value.traffic_type}"
      action       = ruleset.value.action
      cidr_list    = ruleset.value.cidr_list
      protocol     = ruleset.value.protocol
      icmp_type    = ruleset.value.icmp_type
      icmp_code    = ruleset.value.icmp_code
      port         = ruleset.value.port
      traffic_type = ruleset.value.traffic_type
    }
  }
}

output "id" {
  description = "The ID of the cloudstack network acl rule"
  value       = cloudstack_network_acl_rule.this.id
}

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
    start_idx = 50000
    rules     = [
      {
        description  = "bootstrap allow all"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "all"
        traffic_type = "egress"
      }
    ]
  }
}

resource "cloudstack_network_acl_ruleset" "this" {
  acl_id             = var.acl_id
  managed            = var.managed
  dynamic "rule" {
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
      rule_number  = rule.value.rule_number
      description  = "${rule.value.description}: ${rule.value.action} ${rule.value.traffic_type}"
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      port         = rule.value.port
      traffic_type = rule.value.traffic_type
    }
  }
}

output "id" {
  description = "The ID of the cloudstack network acl rule"
  value       = cloudstack_network_acl_ruleset.this.id
}

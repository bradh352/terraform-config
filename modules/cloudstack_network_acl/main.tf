terraform {
  required_providers {
    cloudstack = {
      source  = "cloudstack/cloudstack"
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
  type        = list(map)
}

resource "cloudstack_network_acl_rule" "this" {
  acl_id             = var.acl_id
  managed            = var.managed
  dynamic "rule" {
    for_each = flatten([
        for list in var.rulelist : [
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
      ports        = rule.value.port == null ? null : [ rule.value.port ]
      traffic_type = rule.value.traffic_type
    }
  }
}

output "id" {
  description = "The ID of the cloudstack network acl rule"
  value       = cloudstack_network_acl_rule.this.id
}

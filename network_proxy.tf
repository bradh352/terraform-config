locals {
  subnet_proxy   = "10.252.5.0/24"
  ip_secureproxy = "10.252.5.11/24"
  ip_cacheproxy  = "10.252.5.21/24"
  ip_gitproxy    = "10.252.5.31/24"


  aclrules_access_secureproxy = {
    start_idx = 1500
    rules     = [
      {
        description  = "proxy secureproxy"
        action       = "allow"
        cidr_list    = [ local.ip_secureproxy ]
        protocol     = "tcp"
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_access_cacheproxy = {
    start_idx = 1510
    rules     = [
      {
        description  = "proxy cacheproxy"
        action       = "allow"
        cidr_list    = [ local.ip_cacheproxy ]
        protocol     = "tcp"
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_access_gitproxy = {
    start_idx = 1520
    rules     = [
      {
        description  = "proxy gitproxy"
        action       = "allow"
        cidr_list    = [ local.ip_gitproxy ]
        protocol     = "tcp"
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_proxy = {
    start_idx = 30000
    rules     = [
      {
        description  = "Allow ingress proxy"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "8080"
        traffic_type = "ingress"
      },
      {
        description  = "Allow egress to world on 80"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "Allow egress to world on 443"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "443"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_proxy_all = concat(local.aclrules_common, [ local.aclrules_proxy ])
}

resource "cloudstack_network_acl" "proxy" {
  name   = "proxy"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

module "network_acl_proxy" {
  source   = "./modules/cloudstack_network_acl"
  acl_id   = cloudstack_network_acl.proxy.id
  managed  = true
  rulelist = local.aclrules_proxy_all
}

resource "cloudstack_network" "proxy" {
  name             = "proxy"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_proxy
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.proxy.id
}

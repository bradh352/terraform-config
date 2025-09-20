# Terraform for TestEnv Private Cloud

## Install Terraform
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Manual Steps

### Enable ConfigDrive support for guest networks

Enable the ConfigDrive provider within the CloudStack UI's Zone -> Physical Networks -> choose the guest network(s) -> Network Service Providers, then choose Config Drive and enable it.

### Create VPC Offering

VPC HA ConfigDrive:
- IPv4 + IPv6 (Dual Stack) -- TODO, Dual Stack not working right now
- Network Mode: NATTED
- Routing Mode: Static
- Services:
  - DHCP: VpcVirtualRouter
  - DNS: VpcVirtualRouter
  - LB: VpcVirtualRouter
  - Gateway: VpcVirtualRouter
  - StaticNAT: VpcVirtualRouter
  - SourceNAT: VpcVirtualRouter
  - NetworkACL: VpcVirtualRouter
  - PortForwarding: VpcVirtualRouter
  - UserData: ConfigDrive
  - VPN: VpcVirtualRouter
- Redundant Router: Enabled
- Public: Enabled
- Enable VPC Offering: Enabled

### Create Isolated VPC network offering with Config Drive support
IsolatedNetworkOfferingForVpcNetworksConfigDrive:
- IPv4 + IPv6 (Dual Stack) -- TODO, Dual Stack not working right now
- Network Mode: NATTED
- Guest Type: Isolated
- VPC: enabled
- Services:
  - DHCP: VpcVirtualRouter
  - DNS: VpcVirtualRouter
  - LB: VpcVirtualRouter
  - Gateway: VpcVirtualRouter
  - StaticNAT: VpcVirtualRouter
  - SourceNAT: VpcVirtualRouter
  - NetworkACL: VpcVirtualRouter
  - PortForwarding: VpcVirtualRouter
  - UserData: ConfigDrive
  - VPN: VpcVirtualRouter
- Public: Enabled
- Enable Network Offering: Enabled

### Create OS's
* AlmaLinux 10
* Rocky Linux 10

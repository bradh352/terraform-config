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

## SSHing into nodes in private cloud
We are using a Bastion host, which is an intermediate SSH Proxy Jump host.  This must be
configured to instruct SSH that all hosts in the private cloud must flow through this
bastion host.

Edit `~/.ssh/config` and create an appropriate entry like:
```
Host bastion
  User infra
  HostName 192.168.1.93
  Port 5022
  ForwardAgent yes

Host *.pc.testenv.bradhouse.dev
  User infra
  ProxyJump bastion
```

## Bootstrapping the Cluster

1. Terraform deploy with bootstrap=yes
2. Deploy bastion host first.  Initially set DNS to 8.8.8.8 until internal DNS servers are provisioned
3. Deploy Nameservers. Initially set DNS to 8.8.8.8 until these are provisioned.
4. Re-deploy bastion host and Nameservers using internal DNS servers
5. Deploy Mirror, wait for mirror to sync.
6. Deploy FreeIPA
7.

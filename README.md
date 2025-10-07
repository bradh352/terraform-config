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

### Modify physical network

#### Access to Ceph

We need to be able to add a private gateway to access the hypervisor network which is also our management network.

In order to do that we must add a tag to our management network and then add support for guest traffic types and finally set the traffic label to match our interface name.

1. Under Infrastructure -> Zones -> Select Zone -> Physical Networks, choose the mgmt network.
2. Click the pencil button to update the physical network and add a tag.  I just used 'mgmt', not sure the tag matters but it won't let us add multiple guest networks in the zone without them having different tags.
3. Click the `[+]` button to add a traffic type and choose `guest`, set the isolation method to `vlan`
4. Finally click the merge or branch looking button which is really `update traffic labels` then select the Guest network and set the kvm traffic label to the network interface name, in our case `hypervisor`


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
2. Create Private Gateway manually because for some reason it doesn't work via terraform (appears to work but does not)
   * `cmk createPrivateGateway gateway=10.10.100.1 ipaddress=10.10.100.99 netmask=255.255.255.0 vpcid=62940001-aa31-4da1-abf4-5a8c4f7a7f76 aclid=346df974-6f58-4a8e-94ab-a6559e7bbf2f physicalnetworkid=1b567de0-2a6d-4583-994d-c250b58b5e0d vlan=vlan://untagged`
3. Deploy bastion host first.  Initially set DNS to 8.8.8.8 until internal DNS servers are provisioned
4. Deploy Nameservers. Initially set DNS to 8.8.8.8 until these are provisioned.
5. Re-deploy bastion host and Nameservers using internal DNS servers
6. Deploy Mirror, wait for mirror to sync.
6. Deploy FreeIPA
7.

# Azure Networking Plugin

## Overview

The Azure Networking Plugin integrates RightScale Self-Service with the basic functionality of the Azure Load Balancer, network interface and network peering.

## Requirements

- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrieved the RightScale Credential values identified below.
- Azure Service Principal (AKA Azure Active Directory Application) with the appropriate permissions to manage resources in the target subscription
- The following RightScale Credentials
  - `AZURE_APPLICATION_ID`
  - `AZURE_APPLICATION_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Installation

1. Be sure your RightScale account has Self-Service enabled
1. Connect AzureRM Cloud credentials to your RightScale account (if not already completed)
1. Follow steps to [Create an Azure Active Directory Application](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#create-an-azure-active-directory-application)
1. Grant the Azure AD Application access to the necessary subscription(s)
1. [Retrieve the Application ID & Authentication Key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
1. Create RightScale Credentials with values that match the Application ID (Credential name: `AZURE_APPLICATION_ID`) & Authentication Key (Credential name: `AZURE_APPLICATION_KEY`)
1. [Retrieve your Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)
1. Update `rs_azure_networking_plugin.rb` Plugin with your Tenant ID.
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_china_networking.plugin` file located in this repository

## How to Use

The Azure Networking Plugin has been packaged as `plugins/azure_china_networking`. In order to use this plugin you must import this plugin into a CAT.

```ruby

import "plugins/azure_china_networking"
```

For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Load Balancer, network interface and network peering resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources

- rs_azure_lb.load_balancer
- rs_azure_networking.subnet
- rs_azure_networking.vnet
- rs_azure_networking.interface
- rs_azure_networking.network
- rs_azure_networking.peering
- rs_azure_networking.public_ip_address
- rs_azure_networking.local_network_gateway
- rs_azure_networking.virtual_network_gateway
- rs_azure_networking.virtual_network_gateway_connections

## Usage

```ruby

#Creates an load_balancer

parameter "subscription_id" do
  like $rs_azure_lb.subscription_id
end

parameter "resource_group" do
  type  "string"
  label "Resource Group"
end

permission "read_credentials" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_pub_lb", type: "rs_azure_lb.load_balancer" do
  name join(["my-pub-lb-", last(split(@@deployment.href, "/"))])
  resource_group "azure-example"
  location "Central US"
  frontendIPConfigurations do [
    {
     "name" => "ip1",
     "properties" => {
        "publicIPAddress" => {
           "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/publicIPAddresses/example"])
        }
      }
    }
  ] end

  backendAddressPools do [
    {
      "name" => "pool1"
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/ip1"])
         },
         "backendAddressPool" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/backendAddressPool/pool1"])
         },
         "protocol" => "Http",
         "frontendPort" => 80,
         "backendPort" => 8080,
         "probe" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/probes/probe1"])
         },
         "enableFloatingIP" => false,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }
  ] end

  probes do [
    {
      "name" =>  "probe1",
      "properties" => {
        "protocol" =>  "Http",
        "port" =>  8080,
        "requestPath" =>  "/",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end
end

# connect to lb definition
define add_to_lb(@server,@my_pub_lb) return @server1,@updated_nic do
  @nics = rs_azure_networking.interface.list(resource_group: @@deployment.name)
  @my_target_nic = rs_azure_networking.interface.empty()
  foreach @nic in @nics do
    call sys_log.detail("nic:" + to_s(@nic))
    if @nic.name =~ @server.name +"-default"
      @my_target_nic = @nic
    end
  end
  $object = to_object(@my_target_nic)
  $fields = $object["details"]
  $nic = $fields[0]
  $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"] = []
  $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0] = {}
  $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0]["id"] = @my_pub_lb.backendAddressPools[0]["id"]
  @updated_nic = @my_target_nic.update($nic)
end
```

## Resources

## rs_azure_lb.load_balancer

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the load_balancer.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|frontendIPConfigurations|No|Object representing the Frontend IPs to be used for the Load Balancer|
|backendAddressPools|No|Collection of Backend Address Pools used by this Load Balancer|
|loadBalancingRules|No|Object collection representing the Load Balancing Rules for this Load Balancer|
|probes|No|Collection of Probe objects used in the Load Balancer|
|inboundNatPools|No|Defines an external port range for Inbound Nat to a single backend port on NICs associated with this Load Balancer. Inbound Nat Rules are created automatically for each NIC associated with the Load Balancer using an external port from this range. Defining an Inbound Nat Pool on your Load Balancer is mutually exclusive with defining Inbound Nat Rules. Inbound Nat Pools are referenced from Virtual Machine Scale Sets. NICs that are associated with individual Virtual Machines cannot reference an Inbound Nat Pool. They have to reference individual Inbound Nat Rules.|
|inboundNatRules|No|Collection of Inbound Nat Rules used by this Load Balancer. Defining Inbound Nat Rules on your Load Balancer is mutually exclusive with defining an Inbound Nat Pool. Inbound Nat Pools are referenced from Virtual Machine Scale Sets. NICs that are associated with individual Virtual Machines cannot reference an Inbound Nat Pool. They have to reference individual Inbound Nat Rules.|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/create-or-update-a-load-balancer#request) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/delete-a-load-balancer) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/get-information-about-a-load-balancer)| Supported |

### Supported Outputs

- id
- name
- type
- location
- kind

## rs_azure_networking.network

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the vnet.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties| Hash of vNet properties|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/VirtualNetworks/CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks/list)| Supported |
| list_all | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks/listall)| Supported |

### Supported Outputs

- id
- name
- type
- location
- properties
- tags

## rs_azure_networking.subnet

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the NIC.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|vnet_name|Yes|Name of the vNet that contains the subnet|
|location|Yes|Datacenter to launch in|
|properties| Hash of subnet properties|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/Subnets/CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/subnets/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/subnets/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/subnets/list)| Supported |

### Supported Outputs

- id
- name
- type
- location
- properties
- tags

## rs_azure_networking.interface

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the NIC.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties| Hash of NIC properties|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network/virtualnetwork/create-or-update-a-network-interface-card) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network/virtualnetwork/delete-a-network-interface-card) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network/virtualnetwork/get-information-about-a-network-interface-card)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/network/virtualnetwork/list-network-interface-cards-within-a-resource-group)| Supported |

### Supported Outputs

- id
- name
- type
- location
- properties
- tags

## rs_azure_networking.peering

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the peering.|
|subscription_id|Yes|Azure Subscription ID|
|resource_group|Yes|Name of resource group in which the network resides|
|local_vnet|Yes|The VNET name of local peer|
|remote_vnet|Yes|The VNET name of remote peer|
|properties.allowVirtualNetworkAccess|No|Whether the VMs in the linked virtual network space would be able to access all the VMs in local Virtual network space. Defaults to true|
|properties.allowForwardedTraffic|No|Whether the forwarded traffic from the VMs in the remote virtual network will be allowed/disallowed. Defaults to false|
|properties.useRemoteGateways|No|If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Defaults to false|
|properties.allowGatewayTransit|No|If gateway links can be used in remote virtual networking to link to this virtual network. Defaults to false|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/VirtualNetworkPeerings/CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworkpeerings/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworkpeerings/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworkpeerings/list)| Supported |

### Supported Outputs

- id
- name
- allowVirtualNetworkAccess
- allowForwardedTraffic
- allowGatewayTransit
- useRemoteGateways
- remoteVirtualNetwork
- peeringState
- provisioningState

## rs_azure_networking.public_ip_address

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the public IP address.|
|subscription_id|Yes|Azure Subscription ID|
|resource_group|Yes|Name of resource group in which the network resides|
|location|Yes|Resource location.|
|properties|Yes|Resource Properties|
|sku|Yes|Sku of IP|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses/list)| Supported |

### Supported Outputs

- id
- name
- location
- tags
- etag
- properties

## rs_azure_networking.local_network_gateway

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the local network gateway.|
|subscription_id|Yes|Azure Subscription ID|
|resource_group|Yes|Name of resource group in which the network resides|
|location|Yes|Resource location.|
|properties|Yes|Resource Properties|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network-gateway/localnetworkgateways/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network-gateway/localnetworkgateways/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/localnetworkgateways/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/localnetworkgateways/list)| Supported |

### Supported Outputs

- id
- name
- location
- tags
- etag
- sku
- properties

## rs_azure_networking.virtual_network_gateway

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the virtual network gateway address.|
|subscription_id|Yes|Azure Subscription ID|
|resource_group|Yes|Name of resource group in which the network resides|
|location|Yes|Resource location.|
|properties|Yes|Resource Properties|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgateways/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgateways/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgateways/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgateways/list)| Supported |

### Supported Outputs

- id
- name
- location
- tags
- etag
- properties

## rs_azure_networking.virtual_network_gateway_connections

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the virtual network gateway connection.|
|subscription_id|Yes|Azure Subscription ID|
|resource_group|Yes|Name of resource group in which the network resides|
|location|Yes|Resource location.|
|properties|Yes|Resource Properties|
|sku|Yes|Sku of connection|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgatewayconnections/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgatewayconnections/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgatewayconnections/get)| Supported |
| list | [Get](https://docs.microsoft.com/en-us/rest/api/network-gateway/virtualnetworkgatewayconnections/list)| Supported |

### Supported Outputs

- id
- name
- location
- tags
- etag
- properties

## Implementation Notes

- The Azure Networking Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an LB resource.)

Full list of possible actions can be found on the

- [Azure Load Balancer API Documentation](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/)
- [Azure Network Interface Card API Documentation](https://docs.microsoft.com/en-us/rest/api/network/virtualnetwork/network-interface-cards)
- [Azure Virtual Network Peerings](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworkpeerings)
- [Azure Virtual Networks](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks)
- [Azure Subnets](https://docs.microsoft.com/en-us/rest/api/virtualnetwork/subnets)

## Examples

Please review

- [lb_test_cat.rb](../rs_azure_networking/lb_test_cat.rb) for a basic load balancer example implementation.
- [peering_test_cat.rb](../rs_azure_networking/peering_test_cat.rb) for a basic network peering example.
- [nsg_to_subnet_test_cat.rb](../rs_azure_networking/nsg_to_subnet_test_cat.rb) for an example of attaching a Network Security Group to a subnet
- [vnet_dns_test_cat.rb](../rs_azure_networking/vnet_dns_test_cat.rb) for an example of setting custom dns servers and tags on a vnet

## Known Issues / Limitations

## License

The Azure Networking Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

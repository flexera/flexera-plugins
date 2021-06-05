# Azure Compute Plugin

## Overview

The Azure Compute Plugin integrates RightScale Self-Service with the basic functionality of the Azure Compute

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
1. Update `azure_compute_plugin.rb` Plugin with your Tenant ID.
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_compute_plugin.rb` file located in this repository

## How to Use

The Azure Compute Plugin has been packaged as `plugins/azure_china_compute`. In order to use this plugin you must import this plugin into a CAT.

```ruby

import "plugins/azure_china_compute"
```

For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Compute resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources

- availability_set
- virtualmachine
- extensions

## Usage

```ruby

parameter "subscription_id" do
  like $rs_azure_compute.subscription_id
end

permission "read_credentials" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_availability_set", type: "rs_azure_compute.availability_set" do
  name @@deployment.name
  resource_group "rs-default-central-us"
  location "Central US"
  sku do {
    "name" => "Aligned"
  } end
  properties do {
      "platformUpdateDomainCount" => 5,
      "platformFaultDomainCount" => 3
  } end
end
```

## Resources

## availability_set

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the availability_set|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|sku.name|Yes|Specifies whether the availability set is managed or not. Possible values are: Aligned or Classic. An Aligned availability set is managed, Classic is not.|
|properties|No| Hash of availability_set properties(<https://docs.microsoft.com/en-us/rest/api/compute/availabilitysets/availabilitysets-create>)|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/compute/availabilitysets/availabilitysets-create) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/compute/availabilitysets/availabilitysets-delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/compute/availabilitysets/availabilitysets-get)| Supported |

### Supported Outputs

- id
- name
- type
- location
- sku
- properties

## virtualmachine

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Specifies name of vm|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [Get](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/virtualmachines-get)| Supported |
| update| [Update](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/virtualmachines-create-or-update)| Supported |
| vmSizes | [vmSizes](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/virtualmachines-list-sizes-for-resizing)| Supported |
| list | [List](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/list)| Supported |
| list_all | [List All](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/listall) | Supported |
| stop | [Deallocate](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/deallocate) | Supported |
| start | [Start](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/start) | Supported |
| instance_view | [Instance View](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/instanceview) | Supported |

### Supported Outputs

- id
- name
- type
- location
- properties
- tags

## extensions

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Specifies name of vm|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|virtualMachineName|Yes|Name of virtual machine to add extension to|
|properties|Yes|Hash of extension options|
|protectedSettings|Yes|Private configuration for the Extension that is encrypted. For example,pass a database password to the script. NOTE: This value is not returned on the GET.|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [Get](https://docs.microsoft.com/en-us/rest/api/compute/extensions/extensions-get)| Supported |
| create | [Put](https://docs.microsoft.com/en-us/rest/api/compute/extensions/extensions-add-or-update)|Supported|
| delete | [Delete](https://docs.microsoft.com/en-us/rest/api/compute/extensions/extensions-delete)| Supported|

### Supported Outputs

- id
- name
- type
- location
- properties

## scale_set

### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Specifies name of vm scale set|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|Hash of extension options|
|sku|Yes|The virtual machine scale set sku.|
|plan|No|Specifies information about the marketplace image used to create the virtual machine. This element is only used for marketplace images. Before you can use a marketplace image from an API, you must enable the image for programmatic use. In the Azure portal, find the marketplace image that you want to use and then click Want to deploy programmatically, Get Started ->. Enter any required information and then click Save.|

### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [Get](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachinescalesets/get)| Supported |
| create | [Put](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachinescalesets/createorupdate)|Supported|
| delete | [Delete](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachinescalesets/delete)| Supported|

### Supported Outputs

- id
- identity
- location
- name
- type
- plan
- properties
- sku
- zones
- tags
- properties

## Implementation Notes

- The Azure Compute Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an LB resource.)

Full list of possible actions can be found on the [Azure Compute API Documentation](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/)

## Examples

Please review [compute_test_cat.rb](./rs_azure_compute/compute_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations

## License

The Azure Compute Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

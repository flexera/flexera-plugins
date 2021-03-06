# Azure Databricks Plugin

## Overview

The Azure Databricks Plugin integrates RightScale Self-Service with the basic functionality of the Azure Databricks  API.

## Requirements

- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrieve the RightScale Credential values identified below.
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
1. Update `azure_databricks_plugin.rb` Plugin with your Tenant ID.
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_databricks_plugin.rb` file located in this repository

## How to Use

The Azure Databricks Plugin has been packaged as `plugins/rs_azure_databricks`. In order to use this plugin you must import this plugin into a CAT.

```ruby

import "plugins/rs_azure_databricks"
```

For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Databricks resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources

- workspaces

## Usage

```ruby

resource "databricks", type: "rs_azure_databricks.workspace" do
  name join(["databricks-",last(split(@@deployment.href, "/"))])
  resource_group $resource_group
  location "central us"
  sku do {
    "name" => "trial"
  } end
  properties do {
    "managedResourceGroupId" => join(["/subscriptions/",$subscription_id,"/resourceGroups/databricks-foo-test"])
  } end
  tags do {
      "cost_center" => "12345",
      "environment" => "dev",
      "department" => "engineering"
  } end
end

```

## Resources

### workspace

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the Databricks Workspace in the specified subscription and resource group.|
|resource_group|Yes|The name of the resource group.|
|location|Yes|Datacenter to launch in|
|properties|Yes| Properties of the [Databricks Workspace object](https://docs.microsoft.com/en-us/rest/api/databricks/workspaces/createorupdate#request-body)|
|tags|No|Tag values|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create & update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/databricks/workspaces/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/databricks/workspaces/delete) | Supported |
| get & show | [Get](https://docs.microsoft.com/en-us/rest/api/databricks/workspaces/get)| Supported |

#### Supported Outputs

- id
- name
- location
- tags
- properties
- type
- kind
- sku
- authorizations
- createdBy
- createdDateTime
- managedResourceGroupId
- parameters
- state
- uiDefinitionUri
- updatedBy
- workspaceId
- workspaceUrl

## Implementation Notes

- The Azure Databricks Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to a Databricks resource.)

## Examples

Please review [databricks_test_cat.rb](./databricks_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations

## License

The Azure Databricks Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

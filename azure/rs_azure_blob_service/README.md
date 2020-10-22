# Azure Blob Service Plugin

## Overview

The Azure Blob Service Plugin consumes the Azure Blob Service Account and Objects API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to show Cloud storage resource.

## Requirements

For general understanding of CAT development and definitions

- Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
- the `admin` role is needed to set/retrieve the RightScale Credentials for the Azure Cloud Storage API.

GCP Service Account credentials

- Refer to the Getting Started section for details on creating this account.

## Installation

Be sure your RightScale account has Self-Service enabled

1. Connect AzureRM Cloud credentials to your RightScale account (if not already completed)
1. Follow steps to [Create an Azure Active Directory Application](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#create-an-azure-active-directory-application)
1. Grant the Azure AD Application access to the necessary subscription(s)
1. [Retrieve the Application ID & Authentication Key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
1. Create RightScale Credentials with values that match the Application ID (Credential name: `AZURE_APPLICATION_ID`) & Authentication Key (Credential name: `AZURE_APPLICATION_KEY`)
1. [Retrieve your Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)
1. Update `azure_blob_service.plugin` Plugin with your Tenant ID. 
   1. Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   1. For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_blob_service.rb` file located in this repository

## How to Use

The Azure Blob Service Plugin has been packaged as `plugins/rs_azure_blob_service`. In order to use this plugin you must import this plugin into a CAT.

```
import "plugins/azure_blob_service"
```

For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources

### Parameters

| Parameter Name | Required? | Description |
|----------------|-----------|-------------|
| project_id | Yes | Project identifier for which storage bucket details are fetched |

### blob_services

#### Supported fields for resource blob_services`

| Field Name | Required? | Description |
|------------|-----------|-------------|
| comp | Yes | comp |

#### Supported Outputs for resource `blob_services`

- name
- id
- public_access
- last_modified

#### Usage for resource blob_services

It fetches the required information of each container that is present in a storage account.

#### Supported Actions for resource blob_services

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| list | [list](https://storageAccount_name.blob.core.windows.net/?comp=list) | Supported

#### Supported Links for resource blob_services

N/A

### container_size

#### Supported Fields for resource container_size

| Field Name | Required? | Description |
|------------|-----------|-------------|
| container_name | Yes | Container Name |
| comp | Yes |  |
| restype | Yes | |

#### Supported Outputs for resource container_size

- size

#### Usage for resource container_size

It fetches all the blob objects inside the container which provides the total size of the bucket.

#### Supported Actions for resource container_size

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| list | [list](https://storageAccount_name.blob.core.windows.net/container_name&comp=list&restype=container) | Supported

#### Supported Links for resource container_size

N/A

## Known Issues / Limitations

N/A

## Getting Help

Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit <http://chat.rightscale.com/> to join!

## License

The Azure Blobs Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

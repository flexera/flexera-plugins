# Google Cloud Storage Plugin

## Overview

The Google Cloud Storage Plugin consumes the Google Cloud Storage Bucket and Objects API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to show Cloud storage resource.

## Requirements

For general understanding of CAT development and definitions

- Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
- the `admin` role is needed to set/retrieve the RightScale Credentials for the GCP Cloud Storage API.

GCP Service Account credentials

- Refer to the Getting Started section for details on creating this account.

## Getting Started

### Creating a GCP Service Account

This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
Follow the section named _Creating a service account_
Required permissions:

- `storage.buckets.list`
- `storage.buckets.getIamPolicy`
- `storage.objects.list`
- `storage.objects.getIamPolicy`

Furnish a new private key selecting the JSON option

Download the Private Key

### Creating the RightScale Credentials

This procedure will setup the Credentials required for the GCE Plugin to interact with the GCE API

Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.

To Create a credential in the desired RightScale Account, follow below steps:

- click `New Credential` button under the `Credentials` tab
- select the `Google Compute Engine Service Account` under `Credential Type` box.
- provide a value to identify the credential under `Credential Name` box(By default the same value is used under `Credential Identifier`)
- click Validate to save the credentials

## Installation

Be sure your RightScale account has Self-Service enabled
Follow the Getting Started section to create a Service Account and RightScale Credentials
Navigate to the appropriate Self-Service portal for more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
In the Design section, use the `Upload CAT` interface to complete the following:

- Upload each of packages listed in the Requirements Section
- Upload the `google_cloud_storage.rb` file located in this repository

## How to Use

The Cloud DNS Plugin has been packaged as `plugins/google_cloud_storage`. In order to use this plugin you must import this plugin into a CAT.

```
import "plugins/google_cloud_storage"
```

For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources

### Parameters

| Parameter Name | Required? | Description |
|----------------|-----------|-------------|
| project_id | Yes | Project identifier for which storage bucket details are fetched |

### storage_buckets

#### Supported Fields for resource storage_buckets

| Field Name | Required? | Description |
|------------|-----------|-------------|
| projectId | Yes | Project identifier for which storage bucket details are fetched | 

#### Supported Outputs for resource storage_buckets

- name
- id
- region
- updated
- labels 
- storage class

#### Usage for resource storage_buckets

Google Cloud storage bucket resources details are fetched using this. See the Supported Actions section for a full list of supported actions.

#### Supported Actions for resource storage_buckets

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| list | [list](https://cloud.google.com/storage/docs/json_api/v1/buckets/list) | Supported

#### Supported Links for resource storage_buckets

| Link | Resource Type | 
|------|---------------|
| bucket_permission() | bucket_permission |
| bucket_size() | bucket_size |

### bucket_permission

#### Supported fields for resource bucket_permission`

| Field Name | Required? | Description |
|------------|-----------|-------------|
| bucket_name | Yes | Bucket Name |

#### Supported Outputs for resource `bucket_permission`

- public_access

#### Usage for resource bucket_permission

It fetches the permissions assigned to the bucket which provides the public_access value. If bucket is publicly accessible then the value is true else it is false.

#### Supported Actions for resource bucket_permission

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| list | [list](https://cloud.google.com/storage/docs/json_api/v1/buckets/getIamPolicy) | Supported

#### Supported Links for resource bucket_permission

N/A

### bucket_size

#### Supported Fields for resource bucket_size

| Field Name | Required? | Description |
|------------|-----------|-------------|
| bucket_name | Yes | Bucket Name |

#### Supported Outputs for resource bucket_size

- size

#### Usage for resource bucket_size

It fetches all the objects inside the bucket which provides the total size of objects inside the bucket.

#### Supported Actions for resource bucket_size

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| list | [list](https://cloud.google.com/storage/docs/json_api/v1/objects/list) | Supported

#### Supported Links for resource bucket_size

N/A

## Known Issues / Limitations

N/A

## Getting Help

Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit <http://chat.rightscale.com/> to join!

## License

The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

# GCP Cloud DNS Plugin

## Overview

The GCP Cloud DNS Plugin consumes the Google Cloud DNS API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to create, delete, and manage Cloud DNS resource.

## Requirements

- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
  - the `admin` role is needed to set/retrieve the RightScale Credentials for the GCP Cloud DNS API.
- GCP Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GOOGLE_DNS_PLUGIN_ACCOUNT`
  - `GOOGLE_DNS_PLUGIN_PRIVATE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started

### Creating a GCP Service Account

This procedure will create a GCE Service account with the appropriate permissions to use this plugin.

1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - `DNS Administrator`
    - Permissions can be restricted but may effect the permissions required to interact with certain resources with this plugin. Doing so is unsupported
   - Enabling G Suite Domain-wide Delegation is not required
   - Furnish a new private key selecting the JSON option
1. Download the Private Key and record the Service account ID (These will be stored in a RightScale Credential in a future step)

### Creating the RightScale Credentials

This procedure will setup the Credentials required for the GCE Plugin to interact with the GCE API

1. Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_DNS_PLUGIN_ACCOUNT`
1. Paste the Service Account Id into the value of this credential and save
1. Extract/Copy the private_key from the JSON downloaded when you created the GCE Service Account
   - You will need to replace "\n" in the private_key with actual line returns to paste into the credential 
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_DNS_PLUGIN_PRIVATE_KEY`
1. Paste the private_key into the value of the credential making sure to replace "\n" with actual line returns and save

## Installation

1. Be sure your RightScale account has Self-Service enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate Self-Service portal
   1. For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `google_cloud_dns.rb` file located in this repository

## How to Use

The Cloud DNS Plugin has been packaged as `plugins/googledns`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/googledns"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Implementation Notes

- The Cloud DNS Plugin makes no attempt to support non-Cloud DNS resources. (i.e. Allow the passing the RightScale or other resources as arguments to a GCE resource.) 

## Supported Resources

### managedZone

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | Zone Name | 
| description | no | Zone Description |
| dns_name | yes | Zone DNS Name | 
| nameserver_set | no | Nameservers to use for the newly created Zone. If left empty, nameservers will be auto-populated by GCP |

#### Supported Outputs

- creationTime
- description
- dnsName
- id
- kind
- name
- nameServerSet
- nameServers

#### Usage

GCP Cloud DNS resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```

#### Creates a new Managed Zone

resource "my_zone", type: clouddns.managedZone do
  name "zoneA"
  description "DNS Zone A"
  dns_name "example.com."
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [create](https://cloud.google.com/dns/api/v1/managedZones/create) | Supported
| delete | [delete](https://cloud.google.com/dns/api/v1/managedZones/delete) | Supported
| get | [get](https://cloud.google.com/dns/api/v1/managedZones/get) | Supported
| list | [list](https://cloud.google.com/dns/api/v1/managedZones/list) | Supported

#### Supported Links

| Link | Resource Type | 
|------|---------------|
| project() | project |
| resourceRecordSets() | resourceRecordSet |

### resourceRecordSet

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | Full DNS Record name |
| type | yes | Record Type (ie. A, CNAME, etc) |
| ttl | yes | number value |
| rrdatas | yes | IP address, hostname, etc |

See Google documentation [here](https://cloud.google.com/dns/records/json-record)

#### Supported Outputs

- kind
- name
- type 
- ttl 
- rrdatas

#### Usage

```
# Creates an Address Record

resource "my_recordset", type: "clouddns.resourceRecordSet" do
    name "foobar.example.com."
    ttl 300
    type "A"
    rrdatas "192.168.1.33"
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [create](https://cloud.google.com/dns/api/v1/changes/create) | Supported
| delete | [create](https://cloud.google.com/dns/api/v1/changes/create) | Supported
| get | [list](https://cloud.google.com/dns/api/v1/resourceRecordSets/list) | Supported
| list | [list](https://cloud.google.com/dns/api/v1/resourceRecordSets/list) | Supported

#### Supported Links

| Link | Resource Type | 
|------|---------------|
| project() | project |
| managedZone() | managedZone |

### project

#### Supported Fields

N/A

#### Supported Outputs

- kind
- number
- id
- managedZones_quota
- resourceRecordsPerRrset_quota
- rrsetAdditionsPerChange_quota
- rrsetDeletionsPerChange_quota
- rrsetsPerManagedZone_quota
- totalRrdataSizePerChange_quota

#### Usage

Project resources cannot be created via the Cloud DNS API, however by using the `project()` link, you can retrieve the associate Project information available via the Cloud DNS API.

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [get](https://cloud.google.com/dns/api/v1/projects/get) | Supported

#### Supported Links

N/A

## Examples

- [test_cat-record_only.rb](./test_cat-record_only.rb)
- [test_cat-zone&record.rb](./test_cat-zone&record.rb)

## Known Issues / Limitations

- Project resources only allow a GET actions, which will return DNS Quotas allowed for the associated GCP Project.

## Getting Help

Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License

The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.

# Flexera CMP Plugins

This repository contains the library of open source Flexera CMP plugins.

## Released Plugins

### Amazon Web Services

- [AWS Elastic Load Balancer (Classic LB)](./aws/rs_aws_elb/)
- [AWS Elastic Load Balancer (Application LB)](./aws/rs_aws_alb/)
- [AWS Elastic File System](./aws/rs_aws_efs/)
- [AWS Relational Database Service](./aws/rs_aws_rds/)
- [AWS CloudFormation](./aws/rs_aws_cft/)
- [AWS EC2](./aws/rs_aws_compute/)
- [AWS ElastiCache](./aws/rs_aws_elasticache)
- [AWS Lambda](./aws/rs_aws_lambda)
- [AWS MQ](./aws/rs_aws_mq)
- [AWS IAM](./aws/rs_aws_iam)
- [AWS CloudFront](./aws/rs_aws_cloudfront)
- [AWS Route53](./aws/rs_aws_route53)
- [AWS EKS](./aws/rs_aws_eks)

### Azure

- [Azure SQL Database](./azure/rs_azure_sql/)
- [Azure ARM Templates](./azure/rs_azure_template)
- [Azure Compute](./azure/rs_azure_compute)
- [Azure Database for MySQL](./azure/rs_azure_mysql)
- [Azure Storage](./azure/rs_azure_storage/)
- [Azure Container Services](./azure/rs_azure_containerservices/)
- [Azure Load Balancer](./azure/rs_azure_networking/)
- [Azure Networking Interface](./azure/rs_azure_networking/)
- [Azure PostgreSQL](./azure/rs_azure_pgsql/)
- [Azure Redis Cache](./azure/rs_azure_cache/)
- [Azure Key Vault](./azure/rs_azure_key_vault/)
- [Azure Service Diagnostic Settings](./azure/rs_azure_diagnostic_settings/)
- [Azure Resources](./azure/rs_azure_resources/)
- [Azure CosmosDB](./azure/rs_azure_cosmosdb/)
- [Azure AKS](./azure/rs_azure_aks/)
- [Azure Databricks](./azure/rs_azure_databricks/)

### Google Cloud Platform

- [GCP Google Compute Engine](./google/gce/)
- [GCP Cloud DNS](./google/google_cloud_dns/)
- [GCP Cloud SQL](./google/google_cloud_sql/)
- [GCP Bigtable](./google/google_bigtable/)
- [GKE](./google/gke/)
- [Google Deployment Manager](./google/google_deployment_manager/)
- [Google Cloud Storage](./google/google_cloud_storage/)

### Fastly

- [Fastly IP Address](./fastly/ipaddresslist/)

### Infoblox

- [Infoblox IPAM Appliance](./infoblox/ipam/)

### VMWare

- [VMWare NSX](./vmware/nsx)

### Other Clouds

- [Digital Ocean](./digital_ocean)

## Flexera CMP Plugin Documentation

- [Guide](http://docs.rightscale.com/ss/guides/ss_plugins.html)
- [Reference Documentation](http://docs.rightscale.com/ss/reference/cat/v20161221/ss_plugins.html)

## Getting Help

Support for these plugin will be provided though GitHub Issues and the
[Flexera Community](https://community.flexera.com/t5/Cloud-Management-Platform/ct-p/Cloud-Management-Platform).

### Opening an Issue

Github issues contain a template for three types of requests(Bugs, New Features to an existing Plugin, New Plugin Request)

- Bugs: Any issue you are having with an existing plugin not functioning correctly, this does not include missing features, or actions.
- New Feature Request: Any feature(Field, Action, Link, Output, etc) that are to be added to an existing plugin.
- New Plugin Request: Request for a new plugin based off of a new Resource(i.e Cloud Resource Type(`rds`,`elb`), Third Party Service(`riverbed`,`f5`,`cisco`), etc.

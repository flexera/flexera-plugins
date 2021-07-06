name 'Amazon EC2 Service (Amazon EC2)'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services (AWS) - Amazon EC2"
long_description ""
package "plugin/aws_compute"
import "sys_log"
info(
  provider: "AWS",
  service: "EC2"
)

parameter 'param_region' do
  type 'string'
  label 'AWS Region'
  default 'us-east-1'
end

pagination 'aws_pagination' do
  get_page_marker do
    body_path '/*/nextToken'
  end

  set_page_marker do
    query 'NextToken'
  end
end

plugin "aws_compute" do

  short_description 'AWS-EC2 plugin'
  long_description 'Supports AWS EC2'
  version '2.1.0'

  documentation_link 'source' do
    label 'Source'
    url 'https://github.com/flexera/flexera-plugins/blob/master/aws/rs_aws_compute/aws_compute_plugin.rb'
  end

  documentation_link 'readme' do
    label 'readme'
    url 'https://github.com/flexera/flexera-plugins/blob/master/aws/rs_aws_compute/README.md'
  end

  parameter 'region' do
    type 'string'
    label 'AWS Region'
    default 'us-east-1'
    allowed_values "us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-northeast-2","ap-southeast-1","ap-southeast-2","ap-northeast-1","ca-central-1","eu-central-1","eu-west-1","eu-west-2","eu-west-3", "sa-east-1","eu-north-1"
    description 'The region in which the resources are created'
  end

  parameter 'page_size' do
    type 'string'
    label 'Page size for AWS responses'
    default '200'
    description 'The maximum results count for each page of AWS data received.'
  end

  endpoint do
      default_host 'ec2.$region.amazonaws.com'
      default_scheme 'https'
      path '/'
      query do {
      'Version' => '2016-11-15'
      } end
      request_content_type 'application/x-www-form-urlencoded; charset=utf-8'
  end

  type "vpc" do
    # HREF is set to the correct template in the provision definition due to a lack of usable fields in the response to build the href
    href_templates "/?Action=DescribeVpcs&VpcId.1={{//CreateVpcResponse/vpc/vpcId}}","/?DescribeVpcs&VpcId.1={{//DescribeVpcsResponse/vpcSet/item/vpcId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    field "amazon_provided_ipv6_cidr_block" do
      alias_for "AmazonProvidedIpv6CidrBlock"
      type      "string"
      location  "query"
    end

    field "cidr_block" do
      alias_for "CidrBlock"
      type      "string"
      location  "query"
    end

    field "instance_tenancy" do
      alias_for "InstanceTenancy"
      type      "string"
      location  "query"
    end

    field "page_size" do
      type 'string'
      location 'query'
      alias_for 'MaxResults'
    end

    output 'id' do
      body_path 'vpcId'
    end

    output 'name' do
    end

    output 'region' do
    end

    output 'state' do
      body_path 'state'
    end

    output 'tags' do
      body_path 'tagSet'
    end

    output "cidrBlock" do
      type "simple_element"
    end

    output "ipv6CidrBlockAssociationSet" do
      type "simple_element"
    end

    output "dhcpOptionsId" do
      type "simple_element"
    end

    output "instanceTenancy" do
      type "simple_element"
    end

    output "isDefault" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVpc"
      output_path "//CreateVpcResponse/vpc"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVpc&VpcId=$vpcId"
    end

    action "get" do
      verb "POST"
      output_path "//DescribeVpcsResponse/vpcSet/item"
    end

    action "show" do
      path "/?Action=DescribeVpcs"
      verb "POST"
      output_path "//DescribeVpcsResponse/vpcSet/item"
      field "vpcId" do
        alias_for "VpcId.1"
        location "query"
      end
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcs"
      output_path "//DescribeVpcsResponse/vpcSet/item"
    end

    action "routeTables" do
      type "route_table"
      verb "POST"
      path "/?Action=DescribeRouteTables&Filter.1.Name=vpc-id&Filter.1.Value=$vpcId"
    end

    action "enablevpcclassiclink" do
      verb "POST"
      path "/?Action=EnableVpcClassicLink&VpcId=$vpcId"
    end

    action "disablevpcclassiclink" do
      verb "POST"
      path "/?Action=DisableVpcClassicLink&VpcId=$vpcId"
    end

    action "enablevpcclassiclinkdnssupport" do
      verb "POST"
      path "/?Action=EnableVpcClassicLinkDnsSupport&VpcId=$vpcId"
    end

    action "disablevpcclassiclinkdnssupport" do
      verb "POST"
      path "/?Action=DisableVpcClassicLinkDnsSupport&VpcId=$vpcId"
    end

    action "create_tag" do
      path "/?Action=CreateTags&ResourceId.1=$vpcId"
      verb "POST"
      field "tag_1_key" do
        alias_for "Tag.1.Key"
        location "query"
      end

      field "tag_1_value" do
        alias_for "Tag.1.Value"
        location "query"
      end
    end

    action "delete_tag" do
      path "/?Action=CreateTags&ResourceId.1=$vpcId"
      verb "POST"
      field "tag_1_key" do
        alias_for "Tag.1.Key"
        location "query"
      end
    end

    polling do
      field_values do
      end
      period 60
	    action 'list'
    end
  end

  type "endpoint" do
    href_templates "/?Action=DescribeVpcEndpoints&VpcEndpointId.1={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}","/?Action=DescribeVpcEndpoints&VpcEndpointId.1={{//DescribeVpcEndpointsResponse/vpcEndpointSet/item/vpcEndpointId}}"
    #href_templates "/?Action=DescribeVpcEndpoints?Filter.1.Name=vpc-endpoint-id&Filter.1.Value={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    field "vpc_id" do
      alias_for "VpcId"
      type      "string"
      location  "query"
    end

    field "service_name" do
      alias_for "ServiceName"
      type      "string"
      location  "query"
    end

    field "route_table_id_1" do
      alias_for "RouteTableId.1"
      type      "string"
      location  "query"
    end

    field "vpc_endpoint_type" do
      alias_for "VpcEndpointType"
      type "string"
      location "query"
    end

    field "private_dns_enabled" do
      alias_for "PrivateDnsEnabled"
      type "string"
      location "query"
    end

    field "security_group_id_1" do
      alias_for "SecurityGroupId.1"
      type "string"
      location "query"
    end

    output "vpcEndpointId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "routeTableIdSet" do
      type "array"
    end

    output "creationTimestamp" do
      type "simple_element"
    end

    output "policyDocument" do
      type "simple_element"
    end

    output "serviceName" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVpcEndpoint"
      output_path "//CreateVpcEndpointResponse/vpcEndpoint"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVpcEndpoints&VpcEndpointId.1=$vpcEndpointId"
    end

    action "get" do
      verb "POST"
      output_path "//DescribeVpcEndpointsResponse/vpcEndpointSet/item"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcEndpoints"
      output_path "//DescribeVpcEndpointsResponse/vpcEndpointSet/item"
    end
  end

  type "route_table" do
    href_templates "/?Action=DescribeRouteTables&RouteTableId.1={{//CreateRouteTableResponse/routeTable/routeTableId}}","/?Action=DescribeRouteTables&RouteTableId.1={{//DescribeRouteTablesResponse/routeTableSet/item/routeTableId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    field "vpc_id" do
      alias_for "VpcId"
      type      "string"
      location  "query"
    end

    output "routeTableId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "routeSet" do
      type "array"
    end

    output "associationSet" do
      type "simple_element"
    end

    output "tagSet" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateRouteTable"
      output_path "//CreateRouteTableResponse/routeTable"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteRouteTables&RouteTableId.1=$routeTableId"
    end

    action "get" do
      verb "POST"
      output_path "//DescribeRouteTablesResponse/routeTableSet/item"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcEndpoints"
      output_path "//DescribeRouteTablesResponse/routeTableSet/item"
    end
  end

  type "nat_gateway" do
    href_templates "/?Action=DescribeNatGateways&NatGatewayId.1={{//CreateNatGatewayResponse/natGateway/natGatewayId}}","/?Action=DescribeNatGateways&NatGatewayId.1={{//DescribeNatGatewaysResponse/natGatewaySet/item/natGatewayId}}"
    provision 'provision_resource_available_state'
    delete    'delete_nat_gateway'

    field "allocation_id" do
      alias_for "AllocationId"
      type      "string"
      location  "query"
    end

    field "subnet_id" do
      alias_for "SubnetId"
      type      "string"
      location  "query"
    end

    output "natGatewayId" do
      type "simple_element"
    end

    output "subnetId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "natGatewayAddressSet" do
      type "array"
    end

    output 'id' do
     body_path 'natGatewayId'
    end

    output 'name' do
     body_path 'subnetId'
    end

    output "region", "tags"

    action "create" do
      verb "POST"
      path "/?Action=CreateNatGateway"
      output_path "//CreateNatGatewayResponse/natGateway"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteNatGateway&NatGatewayId=$natGatewayId"
    end

    action "get" do
      verb "POST"
      output_path "//DescribeNatGatewaysResponse/natGatewaySet/item"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeNatGateways"
      output_path "//DescribeNatGatewaysResponse/natGatewaySet/item"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'MaxResults'
      end
      pagination $aws_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end
  end

  type "addresses" do
    href_templates "/?Action=DescribeAddresses&AllocationId.1={{//DescribeAddressesResponse/addressesSet/item/allocationId}}","/?Action=DescribeAddresses&AllocationId.1={{//AllocateAddressResponse/allocationId}}"
    provision 'provision_resources_no_check'
    delete    'delete_resource'

    field "allocation_id_1" do
      alias_for "AllocationId.1"
      type "string"
      location "query"
    end

    field "public_ip_1" do
      alias_for "PublicIp.1"
      type "string"
      location "query"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
      field "allocation_id_1" do
        alias_for "AllocationId.1"
        location "query"
      end

      field "public_ip_1" do
        alias_for "PublicIp.1"
        location "query"
      end
    end
    action "list" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
    end

    output 'instance_id'

    output 'name' do
     body_path 'publicIp'
    end

    output 'region' do
    end

    output 'state' do
      body_path 'state'
    end

    output 'tags' do
     body_path 'tagSet'
    end

    output "publicIP" do
      type "simple_element"
    end

    output "domain" do
      type "simple_element"
    end

    output "allocationId" do
      type "simple_element"
    end

    polling do
      field_values do
      end
      period 60
	    action 'list'
    end
  end

  type "tags" do
    href_templates "/?Action=DescribeTags&Filter.1.Name=key&Filter.1.Value={{//DescribeTagsResponse/tagSet/item/key}}&Filter.2.Name=value&Filter.2.Value={{//DescribeTagsResponse/tagSet/item/value}}&Filter.3.Name=resource-id&Filter.3.Value.1={{//DescribeTagsResponse/tagSet/item/resourceId}}","/?Action=DescribeTags&Filter.1.Name=key&Filter.1.Value=$tag_1_key&Filter.2.Name=value&Filter.2.Value=$tag_1_value&Filter.3.Name=resource-id&Filter.3.Value.1=$resource_id_1"
    provision 'provision_resources_no_check'
    delete    'delete_resource'

    field "resource_id_1" do
      alias_for "ResourceId.1"
      type "string"
      location "query"
    end

    field "tag_1_key" do
      alias_for "Tag.1.Key"
      type "string"
      location "query"
    end

    field "tag_1_value" do
      alias_for "Tag.1.Value"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateTags"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeTags"
      output_path "//DescribeTagsResponse/tagSet/item"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteTags"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeTags"
      output_path "//DescribeTagsResponse/tagSet/item"
    end

    output "resourceId" do
      type "simple_element"
    end

    output "resourceType" do
      type "simple_element"
    end

    output "key" do
      type "simple_element"
    end

    output "value" do
      type "simple_element"
    end
  end

  type "volume" do
    href_templates "/?Action=DescribeVolumes&VolumeId.1={{//CreateVolumeResponse/volumeId}}","/?Action=DescribeVolumes&VolumeId.1={{//DescribeVolumesResponse/volumeSet/item/volumeId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    field "availability_zone" do
      alias_for "AvailabilityZone"
      type "string"
      location "query"
    end

    field "encrypted" do
      alias_for "Encrypted"
      type "string"
      location "query"
    end

    field "iops" do
      alias_for "Iops"
      type "string"
      location "query"
    end

    field "kms_key_id" do
      alias_for "KmsKeyId"
      type "string"
      location "query"
    end

    field "size" do
      alias_for "Size"
      type "string"
      location "query"
    end

    field "snapshot_id" do
      alias_for "SnapshotId"
      type "string"
      location "query"
    end

    field "volume_type" do
      alias_for "VolumeType"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVolume"
      output_path "//CreateVolumeResponse"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeVolumes"
      output_path "//DescribeVolumesResponse/volumeSet/item"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'MaxResults'
      end
     pagination $aws_pagination
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVolume&VolumeId=$volumeId"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVolumes"
      output_path "//DescribeVolumesResponse/volumeSet/item"
      field "page_size" do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
     pagination $aws_pagination
    end

    output 'id' do
      body_path 'volumeId'
    end

    output 'name' do
    end

    output 'region' do
      body_path 'substring(availabilityZone,0, string-length(availabilityZone))'
    end

    output 'state' do
      body_path 'status'
    end

    output 'tags' do
      body_path 'tagSet'
    end

    output "size" do
      type "simple_element"
    end

    output "createTime" do
      type "simple_element"
    end

    output "attachmentSet" do
      type "complex_element"
    end

    output "volumeType" do
      type "simple_element"
    end

    output "encrypted" do
      type "simple_element"
    end

    polling do
      field_values do
        page_size $page_size
      end
      period 60
      action 'list'
    end

  end

  type "volume_modification" do
    href_templates "/?Action=DescribeVolumesModifications&VolumeId.1={{//DescribeVolumesModificationsResponse/volumeModificationSet/item/volumeId}}"
    provision 'provision_volume_modification'
    delete    'no_operation'

    field "volume_id" do
      alias_for "VolumeId"
      type "string"
      location "query"
    end

    field "iops" do
      alias_for "Iops"
      type "string"
      location "query"
    end

    field "size" do
      alias_for "Size"
      type "string"
      location "query"
    end

    field "volume_type" do
      alias_for "VolumeType"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=ModifyVolume"
      output_path "//ModifyVolumeResponse/volumeModification"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeVolumesModifications"
      output_path "//DescribeVolumesModificationsResponse/volumeModificationSet/item"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVolumesModifications"
      output_path "//DescribeVolumesModificationsResponse/volumeModificationSet/item"
    end

    output "volumeId" do
      type "simple_element"
    end

    output "targetIops" do
      type "simple_element"
    end

    output "originalIops" do
      type "simple_element"
    end

    output "modificationState" do
      type "simple_element"
    end

    output "targetSize" do
      type "simple_element"
    end

    output "targetVolumeType" do
      type "simple_element"
    end

    output "progress" do
      type "simple_element"
    end

    output "startTime" do
      type "simple_element"
    end

    output "originalSize" do
      type "simple_element"
    end

    output "originalVolumeType" do
      type "simple_element"
    end
  end

  type "instances" do
    href_templates "/?Action=DescribeInstances&InstanceId.1={{//DescribeInstancesResponse/reservationSet/item/instancesSet/item/instanceId}}","/?Action=DescribeInstances&InstanceId.1={{//RunInstancesResponse/instancesSet/item/instanceId}}"
    provision 'provision_instance'
    delete    'delete_instance'

    field "additional_info" do
      alias_for "AdditionalInfo"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_device_name" do
      alias_for "BlockDeviceMapping.1.DeviceName"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_virtual_name" do
      alias_for "BlockDeviceMapping.1.VirtualName"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_delete_on_termination" do
      alias_for "BlockDeviceMapping.1.Ebs.DeleteOnTermination"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_encrypted" do
      alias_for "BlockDeviceMapping.1.Ebs.Encrypted"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_iops" do
      alias_for "BlockDeviceMapping.1.Ebs.Iops"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_kms_key_id" do
      alias_for "BlockDeviceMapping.1.Ebs.KmsKeyId"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_snapshot_id" do
      alias_for "BlockDeviceMapping.1.Ebs.SnapshotId"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_volume_size" do
      alias_for "BlockDeviceMapping.1.Ebs.VolumeSize"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_ebs_volume_type" do
      alias_for "BlockDeviceMapping.1.Ebs.VolumeType"
      type "string"
      location "query"
    end

    field "block_device_mapping_1_no_device" do
      alias_for "BlockDeviceMapping.1.NoDevice"
      type "string"
      location "query"
    end

    field "capacity_reservation_specification_capacity_reservation_preference" do
      alias_for "CapacityReservationSpecification.CapacityReservationPreference"
      type "string"
      location "query"
    end

    field "capacity_reservation_specification_capacity_reservation_target_capacity_reservation_id" do
      alias_for "CapacityReservationSpecification.CapacityReservationTarget.CapacityReservationId"
      type "string"
      location "query"
    end

    field "capacity_reservation_specification_capacity_reservation_target_capacity_reservation_resource_group_arn" do
      alias_for "CapacityReservationSpecification.CapacityReservationTarget.CapacityReservationResourceGroupArn"
      type "string"
      location "query"
    end

    field "client_token" do
      alias_for "ClientToken"
      type "string"
      location "query"
    end

    field "cpu_options_core_count" do
      alias_for "CpuOptions.CoreCount"
      type "string"
      location "query"
    end

    field "cpu_options_threads_per_core" do
      alias_for "CpuOptions.ThreadsPerCore"
      type "string"
      location "query"
    end

    field "credit_specification_cpu_credits" do
      alias_for "CreditSpecification.CpuCredits"
      type "string"
      location "query"
    end

    field "disable_api_termination" do
      alias_for "DisableApiTermination"
      type "string"
      location "query"
    end

    field "ebs_optimized" do
      alias_for "EbsOptimized"
      type "string"
      location "query"
    end

    field "elastic_gpu_specification_1_type" do
      alias_for "ElasticGpuSpecification.1.Type"
      type "string"
      location "query"
    end

    field "elastic_inference_accelerator_1_count" do
      alias_for "ElasticInferenceAccelerator.1.Count"
      type "string"
      location "query"
    end

    field "elastic_inference_accelerator_1_type" do
      alias_for "ElasticInferenceAccelerator.1.Type"
      type "string"
      location "query"
    end

    field "hibernation_options" do
      alias_for "HibernationOptions"
      type "string"
      location "query"
    end

    field "iam_instance_profile" do
      alias_for "IamInstanceProfile"
      type "string"
      location "query"
    end

    field "image_id" do
      alias_for "ImageId"
      type "string"
      location "query"
    end

    field "instance_initiated_shutdown_behavior" do
      alias_for "InstanceInitiatedShutdownBehavior"
      type "string"
      location "query"
    end

    field "instance_market_options_market_type" do
      alias_for "InstanceMarketOptions.MarketType"
      type "string"
      location "query"
    end

    field "instance_market_options_spot_options" do
      alias_for "InstanceMarketOptions.SpotOptions"
      type "string"
      location "query"
    end

    field "instance_type" do
      alias_for "InstanceType"
      type "string"
      location "query"
    end

    field "ipv6_address_1" do
      alias_for "Ipv6Address.1.Ipv6Address"
      type "string"
      location "query"
    end

    field "ipv6_address_count" do
      alias_for "Ipv6AddressCount"
      type "string"
      location "query"
    end

    field "kernel_id" do
      alias_for "KernelId"
      type "string"
      location "query"
    end

    field "key_name" do
      alias_for "KeyName"
      type "string"
      location "query"
    end

    field "launch_template_launch_template_id" do
      alias_for "LaunchTemplate.LaunchTemplateId"
      type "string"
      location "query"
    end

    field "launch_template_launch_template_name" do
      alias_for "LaunchTemplate.LaunchTemplateName"
      type "string"
      location "query"
    end

    field "launch_template_version" do
      alias_for "LaunchTemplate.Version"
      type "string"
      location "query"
    end

    field "license_specification_1_license_configuration_arn" do
      alias_for "LicenseSpecification.1.LicenseConfigurationArn"
      type "string"
      location "query"
    end

    field "max_count" do
      alias_for "MaxCount"
      type "string"
      location "query"
    end

    field "metadata_options_http_endpoint" do
      alias_for "MetadataOptions.HttpEndpoint"
      type "string"
      location "query"
    end

    field "metadata_options_http_put_response_hop_limit" do
      alias_for "MetadataOptions.HttpPutResponseHopLimit"
      type "string"
      location "query"
    end

    field "metadata_options_http_tokens" do
      alias_for "MetadataOptions.HttpTokens"
      type "string"
      location "query"
    end

    field "min_count" do
      alias_for "MinCount"
      type "string"
      location "query"
    end

    field "monitoring_enabled" do
      alias_for "Monitoring.Enabled"
      type "string"
      location "query"
    end

    field "network_interface_1_associate_carrier_ip_address" do
      alias_for "NetworkInterface.1.AssociateCarrierIpAddress"
      type "string"
      location "query"
    end

    field "network_interface_1_associate_public_ip_address" do
      alias_for "NetworkInterface.1.AssociatePublicIpAddress"
      type "string"
      location "query"
    end

    field "network_interface_1_delete_on_termination" do
      alias_for "NetworkInterface.1.DeleteOnTermination"
      type "string"
      location "query"
    end

    field "network_interface_1_description" do
      alias_for "NetworkInterface.1.Description"
      type "string"
      location "query"
    end

    field "network_interface_1_device_index" do
      alias_for "NetworkInterface.1.DeviceIndex"
      type "string"
      location "query"
    end

    field "network_interface_1_interface_type" do
      alias_for "NetworkInterface.1.InterfaceType"
      type "string"
      location "query"
    end

    field "network_interface_1_ipv6_address_count" do
      alias_for "NetworkInterface.1.Ipv6AddressCount"
      type "string"
      location "query"
    end

    field "network_interface_1_ipv6_addresses" do
      alias_for "NetworkInterface.1.Ipv6Addresses"
      type "string"
      location "query"
    end

    field "network_interface_1_network_interface_id" do
      alias_for "NetworkInterface.1.NetworkInterfaceId"
      type "string"
      location "query"
    end

    field "network_interface_1_private_ip_address" do
      alias_for "NetworkInterface.1.PrivateIpAddress"
      type "string"
      location "query"
    end

    field "network_interface_1_private_ip_addresses" do
      alias_for "NetworkInterface.1.PrivateIpAddresses"
      type "string"
      location "query"
    end

    field "network_interface_1_secondary_private_ip_address_count" do
      alias_for "NetworkInterface.1.SecondaryPrivateIpAddressCount"
      type "string"
      location "query"
    end

    field "network_interface_1_groups" do
      alias_for "NetworkInterface.1.Groups"
      type "string"
      location "query"
    end

    field "network_interface_1_subnet_id" do
      alias_for "NetworkInterface.1.SubnetId"
      type "string"
      location "query"
    end

    field "placement_affinity" do
      alias_for "Placement.Affinity"
      type "string"
      location "query"
    end

    field "placement_availability_zone" do
      alias_for "Placement.AvailabilityZone"
      type "string"
      location "query"
    end

    field "placement_group_name" do
      alias_for "Placement.GroupName"
      type "string"
      location "query"
    end

    field "placement_host_id" do
      alias_for "Placement.HostId"
      type "string"
      location "query"
    end

    field "placement_host_resource_group_arn" do
      alias_for "Placement.HostResourceGroupArn"
      type "string"
      location "query"
    end

    field "placement_partition_number" do
      alias_for "Placement.PartitionNumber"
      type "string"
      location "query"
    end

    field "placement_spread_domain" do
      alias_for "Placement.SpreadDomain"
      type "string"
      location "query"
    end

    field "placement_tenancy" do
      alias_for "Placement.Tenancy"
      type "string"
      location "query"
    end

    field "private_ip_address" do
      alias_for "PrivateIpAddress"
      type "string"
      location "query"
    end

    field "ramdisk_id" do
      alias_for "RamdiskId"
      type "string"
      location "query"
    end

    field "security_group_1" do
      alias_for "SecurityGroup.1"
      type "string"
      location "query"
    end

    field "security_group_id_1" do
      alias_for "SecurityGroupId.1"
      type "string"
      location "query"
    end

    field "subnet_id" do
      alias_for "SubnetId"
      type "string"
      location "query"
    end

    field "tag_specification_1_resource_type" do
      alias_for "TagSpecification.1.ResourceType"
      type "string"
      location "query"
    end

    field "tag_specification_1_tag_1_key" do
      alias_for "TagSpecification.1.Tag.1.Key"
      type "string"
      location "query"
    end

    field "tag_specification_1_tag_1_value" do
      alias_for "TagSpecification.1.Tag.1.Value"
      type "string"
      location "query"
    end

    field "user_data" do
      alias_for "UserData"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=RunInstances"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=TerminateInstances"
      field "instance_id" do
        alias_for "InstanceId.1"
        location "query"
      end
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeInstances&InstanceId.1=$instanceId"
      output_path "//DescribeInstancesResponse/reservationSet/item/instancesSet/item"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeInstances"
      output_path "//DescribeInstancesResponse/reservationSet/item/instancesSet/item"

      field "instance_id" do
        alias_for "InstanceId.1"
        location "query"
      end
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeInstances"
      output_path "//DescribeInstancesResponse/reservationSet/item/instancesSet/item"
      field "page_size" do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $aws_pagination
    end

    action "create_image" do
      verb "POST"
      path "/?Action=CreateImage&InstanceId=$instanceId"
      output_path "//CreateImageResponse"

      field "name" do
        alias_for "Name"
        location "query"
        required true
      end

      field "description" do
        alias_for "Description"
        location "query"
      end

      field "no_reboot" do
        alias_for "NoReboot"
        location "query"
      end
      type "images"
    end

    action "stop" do
      verb "POST"
      path "/?Action=StopInstances"
      output_path "//StopInstancesResponse/instancesSet/item"

      field "instance_id" do
        alias_for "InstanceId.1"
        location "query"
      end
    end

    action "start" do
      verb "POST"
      path "/?Action=StartInstances"
      output_path "//StartInstancesResponse/instancesSet/item"

      field "instance_id" do
        alias_for "InstanceId.1"
        location "query"
      end
    end

    action "attach_volume" do
      verb "POST"
      path "/?Action=AttachVolume"
      output_path "//AttachVolumeResponse"

      field "instance_id" do
        alias_for "InstanceId"
        location "query"
      end

      field "volume_id" do
        alias_for "VolumeId"
        location "query"
      end

      field "device" do
        alias_for "Device"
        location "query"
      end
    end

    output "ipAddress","vpcId","imageId","privateDnsName"

    output 'id' do
     body_path 'instanceId'
    end

    output 'name' do
    end

    output 'region' do
      body_path 'substring(placement.availabilityZone,0, string-length(placement.availabilityZone))'
    end

    output 'instance_state' do
      body_path "//instanceState/name"
    end

    output 'state' do
      body_path '//instanceState/name'
    end

    output 'tags' do
      body_path 'tagSet'
    end

    polling do
      field_values do
        page_size $page_size
      end
      period 60
      action 'list'
    end

  end

  type "snapshots" do
    href_templates "/?Action=DescribeSnapshots&SnapshotId.1={{//DescribeSnapshotsResponse/snapshotSet/item/snapshotId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    action "get" do
      verb "POST"
      path "/?Action=DescribeSnapshots&InstanceId.1=$snapshotId"
      output_path "//DescribeSnapshotsResponse/snapshotSet/item"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeSnapshots"
      output_path "//DescribeSnapshotsResponse/snapshotSet/item"

      field "snapshot_Id" do
        alias_for "SnapshotId.1"
        location "query"
      end
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeSnapshots"
      output_path "//DescribeSnapshotsResponse/snapshotSet/item"
     field "page_size" do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $aws_pagination
    end

    output "volumeId","startTime"

    output 'id' do
     body_path 'snapshotId'
    end

    output 'name' do
    end

    output 'region' do
    end

    output 'state' do
      body_path 'status'
    end

    output 'tags' do
     body_path 'tagSet'
    end

    polling do
      field_values do
        page_size $page_size
      end
      period 60
      action 'list'
    end

  end

  type "images" do
    href_templates "/?Action=DescribeImages&ImageId.1={{//DescribeImagesResponse/imagesSet/item/imageId}}","/?Action=DescribeImages&ImageId.1={{//CreateImageResponse/imageId}}"
    provision 'no_operation'
    delete    'no_operation'

    action "get" do
      verb "POST"
      path "/?Action=DescribeImages&ImageId.1=$imageId"
      output_path "//DescribeImagesResponse/imagesSet/item"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeImages"
      output_path "//DescribeImagesResponse/imagesSet/item"

      field "image_id" do
        alias_for "ImageId.1"
        location "query"
      end
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeImages&Filter.1.Name=is-public&Filter.1.Value.1=false"
      output_path "//DescribeImagesResponse/imagesSet/item"
    end

    action "deregister_image" do
      verb "POST"
      path "/?Action=DeregisterImage&ImageId=$imageId"
    end

    output 'id' do
      body_path 'imageId'
    end

    output 'name' do
      body_path 'name'
    end

    output 'platform' do
      body_path 'platformDetails'
    end

    output 'state' do
      body_path 'imageState'
    end

    output 'region' do
    end

    output 'ena_support' do
      body_path 'enaSupport'
    end

    output 'description' do
      body_path 'description'
    end

    output 'virtualization_type' do
      body_path 'virtualizationType'
    end

    output 'tags' do
      body_path 'tagSet'
    end

    output "imageLocation","imageState","imageOwnerId","isPublic","architecture","imageType","kernelId","ramdiskId","imageOwnerAlias","rootDeviceType","rootDeviceName"

    polling do
      field_values do
      end
      period 60
      action 'list'
    end

  end

  type "subnets" do
    href_templates "/?Action=DescribeSubnets&subnetId.1={{//DescribeSubnetsResponse/subnetSet/item/subnetId}}","/?Action=DescribeSubnets&subnetId.1={{//CreateSubnetResponse/subnetId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    action "list" do
      verb "POST"
      path "/?Action=DescribeSubnets"
      output_path "//DescribeSubnetsResponse/subnetSet/item"
      field "page_size" do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $aws_pagination
    end

    output 'id' do
      body_path 'subnetId'
    end

    output 'name' do
      body_path 'subnetId'
    end

    output 'state' do
      body_path 'state'
    end

    output 'region' do
      body_path 'substring(availabilityZone,0, string-length(availabilityZone))'
    end

    output 'tags' do
      body_path 'tagSet'
    end

    output "description", "vpcId", "cidrBlock", "availableIpAddressCount", "availabilityZone"

    polling do
      field_values do
        page_size $page_size
      end
      period 60
      action 'list'
    end

  end

  type "security_groups" do
    href_templates "/?Action=DescribeSecurityGroups&groupId.1={{//DescribeSecurityGroupsResponse/securityGroupInfo/item/groupId}}","/?Action=DescribeSecurityGroups&groupId.1={{//CreateImageResponse/groupId}}"
    provision 'provision_resource_available_state'
    delete    'delete_resource'

    action "list" do
      verb "POST"
      path "/?Action=DescribeSecurityGroups"
      output_path "//DescribeSecurityGroupsResponse/securityGroupInfo/item"
      field "page_size" do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $aws_pagination
    end

    output 'id' do
      body_path 'groupId'
    end

    output 'name' do
      body_path 'groupName'
    end

    output 'description' do
      body_path 'groupDescription'
    end

    output "ipPermissions", "vpcId", "tags", "region"

    polling do
      field_values do
        page_size $page_size
      end
      period 60
      action 'list'
    end

  end

end

resource_pool "compute_pool" do
  plugin $aws_compute
  parameter_values do
    region $param_region
  end
  auth "key", type: "aws" do
    version     4
    service    'ec2'
    region     $param_region
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_resources_no_check(@declaration) return @resources do
  $object = to_object(@declaration)
  $fields = $object["fields"]
  $name = $fields['name']
  $type = $object["type"]
  $counter = 1
  $copies = $object["copies"]
  @resources = aws_compute.$type.empty()
  while $counter <= $copies do
    sub on_error: stop_debugging() do
      call start_debugging()
      @resource = aws_compute.$type.create($fields)
      call stop_debugging()
      $object = to_object(@resource)
      call sys_log.detail(join([$type, ":", to_s($object)]))
      @resources = @resources + @resource
      $counter = $counter + 1
    end
  end
end

define provision_resource_available_state(@declaration) return @resources do
  $object = to_object(@declaration)
  $fields = $object["fields"]
  $type = $object["type"]
  $name = $fields['name']
  $counter = 1
  $copies = $object["copies"]
  @resources = aws_compute.$type.empty()
  while $counter <= $copies do
    sub on_error: stop_debugging() do
      call start_debugging()
      @resource = aws_compute.$type.create($fields)
      call stop_debugging()
      $resource = to_object(@resource)
      call sys_log.detail(join([$type, ": ", to_s($resource)]))
      $state = @resource.state
      while $state != "available" do
        sleep(10)
        call sys_log.detail(join(["state: ", $state]))
        call start_debugging()
        $state = @resource.state
        call stop_debugging()
      end
      @resources = @resources + @resource
      $counter = $counter + 1
    end
  end
end

define provision_instance(@declaration) return @resources do
  $object = to_object(@declaration)
  call sys_log.detail(to_s($object))
  $fields = $object["fields"]
  $type = $object["type"]
  $name = $fields['name']
  $counter = 1
  $copies = $object["copies"]
  call sys_log.detail(join(["copies: ", $copies]))
  @resources = aws_compute.$type.empty()
  while $counter <= $copies do
    sub on_error: stop_debugging() do
      call start_debugging()
      @resource = aws_compute.$type.create($fields)
      call stop_debugging()
      $resource = to_object(@resource)
      call sys_log.detail(join([$type, ": ", to_s($resource)]))
      @created_resource = aws_compute.$type.show(instance_id: @resource.id)
      @resource = @created_resource
      $state = @resource.instance_state
      while $state != "running" do
        sleep(10)
        call sys_log.detail(join(["state: ", $state]))
        call start_debugging()
        $state = @resource.instance_state
        call stop_debugging()
      end
      @resources = @resources + @resource
      $counter = $counter + 1
    end
  end
end

define provision_volume_modification(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = aws_compute.volume.create($fields)
    call stop_debugging()
    $volume_modification = to_object(@resource)
    call sys_log.detail(join(["volume:", to_s($volume_modification)]))
    call start_debugging()
    $state = @resource.modificationState
    call stop_debugging()
    while $state != "completed" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @resource.modificationState
      call stop_debugging()
    end
  end
end

define delete_resource(@resources) do
  foreach @resource in @resources do
    sub on_error: stop_debugging() do
      call start_debugging()
      @resource.destroy()
      sleep(30)
      call stop_debugging()
    end
  end
end

define delete_instance(@resources) do
  foreach @resource in @resources do
    sub on_error: stop_debugging() do
      call start_debugging()
      @resource.destroy(instance_id: @resource.id)
      sleep(30)
      call stop_debugging()
    end
  end
end

define delete_nat_gateway(@nat_gateways) do
  foreach @nat_gateway in @nat_gateways do
    sub on_error: stop_debugging() do
      call start_debugging()
      @nat_gateway.destroy()
      sleep(30)
      $state = @nat_gateway.state
      while $state != "deleted" do
        sleep(10)
        call sys_log.detail(join(["state: ", $state]))
        call start_debugging()
        $state = @nat_gateway.state
        call stop_debugging()
      end
      call stop_debugging()
    end
  end
end

define no_operation(@resource) return @resource do
  @resource=@resource
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end

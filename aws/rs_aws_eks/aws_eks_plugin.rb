name 'AWS EKS Plugin'
type 'plugin'
rs_ca_ver 20161221
package "plugins/rs_aws_eks"
import "sys_log"

pagination 'aws_pagination' do
  get_page_marker do
    body_path '/*/nextToken'
  end

  set_page_marker do
    query 'NextToken'
  end
end

plugin "aws_eks" do
  short_description 'Amazon Elastic Kubernetes Service (Amazon EKS) is a fully managed Kubernetes service'
  long_description 'Amazon Elastic Kubernetes Service (Amazon EKS) is a fully managed Kubernetes service with support for pagination, etc.'
  version '0.0.1'

  documentation_link 'source' do
    label 'Source'
    url 'https://github.com/rightscale/rightscale-plugins/blob/master/aws/rs_aws_eks/aws_eks_plugin.rb'
  end

  documentation_link 'readme' do
    label 'Readme'
    url 'https://github.com/rightscale/rightscale-plugins/blob/master/aws/rs_aws_eks/README.md'
  end

  documentation_link 'changelog' do
    label 'Changelog'
    url 'https://github.com/rightscale/rightscale-plugins/blob/master/aws/rs_aws_eks/CHANGELOG.md'
  end

  parameter 'region' do
    type 'string'
    label 'AWS Region'
    description 'The region in which the resources are created'
    allowed_values "us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-northeast-2","ap-southeast-1","ap-southeast-2","ap-northeast-1","ca-central-1","eu-central-1","eu-west-1","eu-west-2","eu-west-3", "sa-east-1","eu-north-1"
  end

  parameter 'page_size' do
    type 'string'
    label 'Page size for AWS responses'
    default '200'
    description 'The maximum results count for each page of AWS data received.'
  end

  endpoint do
    default_host join(["eks.",$region,".amazonaws.com"])
    default_scheme "https"
  end

  type "clusters" do
    href_templates "/clusters/{{cluster.name}}"
    provision "provision_cluster"
    delete    "delete_resource"

    field "client_request_token" do
      alias_for "clientRequestToken"
      type "string"
    end

    field "name" do
      type "string"
      required true
    end

    field "resources_vpc_config" do
      alias_for "resourcesVpcConfig"
      type "composite"
      required true
    end

    field "role_arn" do
      alias_for "roleArn"
      type "string"
      required true
    end

    field "version" do
      type "string"
    end

    field "next_token" do
      alias_for "nextToken"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/clusters"
    end

    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    action "get" do
      verb "GET"
      path "$href"
    end

    action "list" do
      verb "GET"
      path "/clusters"

      output_path "clusters[]"
    end

    output_path "cluster"

    output "endpoint","status","createdAt","certificateAuthority","arn","roleArn","clientRequestToken","version","name","resourcesVpcConfig"

  end

end

resource_pool "aws_eks" do
  plugin $aws_eks

  parameter_values do
    region $region
  end

  host join(["eks.",$region,".amazonaws.com"])
  auth "key", type: "aws" do
    version     4
    service    'eks'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define no_operation() do
end

define provision_cluster(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_eks.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    sub timeout: 20m, on_timeout: skip do
      sleep_until(@operation.status =~ "^(ACTIVE|DELETING|FAILED)")
    end
    if @operation.status != "ACTIVE"
      @operation.destroy()
      raise "Failed to provision EKS Cluster"
    end
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  @declaration.destroy()
  call stop_debugging()
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

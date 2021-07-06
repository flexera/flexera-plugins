name 'AWS EC2 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/aws_compute"

parameter "param_region" do
  like $aws_compute.param_region
end

parameter "param_instance_count" do
  label "Instance Count"
  type "number"
  default 2
end

resource "instances", type: "aws_compute.instances", copies: $param_instance_count do
  image_id "ami-0b898040803850657"
  instance_type "t2.large"
  subnet_id "subnet-e7eb98ac"
  key_name "Kube"
  min_count "1"
  max_count "1"
  placement_availability_zone "us-east-1b"
  placement_tenancy "default"
  tag_specification_1_resource_type "instance"
  tag_specification_1_tag_1_key "Name"
  tag_specification_1_tag_1_value @@deployment.name
end

output_set "output_instance_ids" do
  label "Instance Id"
  default_value @instances.id
end
operation "launch" do
  definition "generated_launch"
end

operation "stop" do
  definition "defn_stop"
end

operation "start" do
  definition "defn_start"
end

operation "terminate" do
  definition "generated_terminate"
end

define generated_launch($param_region, @instances) return @instances do
  provision(@instances)
end

define defn_stop(@instances) return @instances do
  foreach @instance in @instances do
    @instance.stop(instance_id: @instance.id)
  end
end

define defn_start(@instances) return @instances do
  foreach @instance in @instances do
    @instance.start(instance_id: @instance.id)
  end
end

define generated_terminate(@instances) do
  delete(@instances)
end

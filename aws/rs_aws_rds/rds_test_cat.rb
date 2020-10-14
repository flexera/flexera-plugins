name 'rds test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Relational Database Service"
import "plugins/flexera_aws_rds"


output "rds_endpoint" do
  label "rds_endpoint"
  default_value @my_rds.endpoint_address
end

output "rds_instance_name" do
  label "rds_instance_name"
  default_value @my_rds.DBInstanceIdentifier
end

output "list_db_instances" do
  label "list_action"
end

output "db" do
  label "db"
end

output "empty" do
  label "empty?"
end

parameter "db_href" do
  label "db_href"
  type "string"
  operations "get_db","check_if_empty"
end

#FROM Snapshot:
#resource "my_rds", type: "flexera_aws_rds.db_instance" do
#  availability_zone "us-east-1a"
#  db_instance_class "db.t2.small"
#  db_instance_identifier join(["my-rds-", last(split(@@deployment.href, "/"))])
#  db_subnet_group_name "db-sub-grp-8172a6f8"
#  db_snapshot_identifier "arn:aws:rds:us-east-1:041819229125:snapshot:my-rds-937549003-final-snapshot"
#  storage_type "standard"
#end

#New Instance:
resource "my_rds", type: "flexera_aws_rds.db_instance" do
  allocated_storage "10"
  availability_zone "us-east-1a"
  db_instance_class "db.t2.small"
  db_instance_identifier join(["my-rds-", last(split(@@deployment.href, "/"))])
  db_name join(["mydb", last(split(@@deployment.href, "/"))])
  db_subnet_group_name "db-sub-grp-8172a6f8"
  engine "mysql"
  engine_version "5.7" 
  master_username "my_user"
  master_user_password "pa$$w0rd1"
  storage_encrypted "false"
  storage_type "standard"
  tag_key_1 "foo"
  tag_value_1 "bar"
  tag_key_2 "Name"
  tag_value_2 "my_app"
  tag_key_3 "Project"
  tag_value_3 "my_project"
  tag_key_4 "Tenant"
  tag_value_4 "my_tenant"
end

operation "list_db_instances" do
  definition "list_db_instances"
  output_mappings do {
    $list_db_instances => $object
  } end
end

define list_db_instances() return $object do
  @rds = flexera_aws_rds.db_instance.list()

  $object = to_object(@rds)

  $object = to_s($object)
end

operation "get_db" do
  definition "get_db"
  output_mappings do {
    $db => $object
  } end
end

define get_db($db_href) return $object do
  @rds = flexera_aws_rds.db_instance.get(href: $db_href)
    $object = to_object(@rds)

  $object = to_s($object)
end

operation "check_if_empty" do
  definition "check_if_empty"
  output_mappings do {
    $empty => $value
  } end
end

define check_if_empty($db_href) return $value do
    @rds = flexera_aws_rds.db_instance.get(href: $db_href)
    if empty?(@rds)
      $value = "EMPTY!"
    else 
      $value = "NOT EMPTY!"
    end
end
  
operation "start" do
  definition "start_db"
end

define start_db(@my_rds) do
  @my_rds.start()
end

operation "stop" do
  definition "stop_db"
end

define stop_db(@my_rds) do
  @my_rds.stop()
end

operation "reboot" do
  definition "reboot_db"
end

define reboot_db(@my_rds) do
  @my_rds.reboot()
end
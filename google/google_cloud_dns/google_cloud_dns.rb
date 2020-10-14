name "Google Cloud DNS"
rs_ca_ver 20161221
short_description "Google Cloud DNS"
long_description ""
type 'plugin'
package "plugins/googledns"
import "sys_log"
info(
  provider: "Google",
  service: "CloudDNS"
)

parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

pagination "google_pagination" do
  get_page_marker do
    body_path "nextPageToken"
  end
  set_page_marker do
    query "pageToken"
  end
end

plugin "clouddns" do
  short_description "Google Cloud DNS"
  long_description "Supports Google Cloud DNS ManagedZones and RecordSets"
  version "2.0.0"

  documentation_link 'source' do
    label 'Source'
    url 'https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_dns/google_cloud_dns.rb'
  end

  documentation_link 'readme' do
    label "ReadMe"
    url 'https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_dns/README.md'
  end

  endpoint do
    default_scheme "https"
    default_host "www.googleapis.com"
    path "/dns/v1"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCP Project to create/manage resources"
  end
  
  # https://cloud.google.com/dns/api/v1/managedZones
  type "managedZone" do
    href_templates "{{managedZones[*].id}}"

    field "name" do
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "dns_name" do
      alias_for "dnsName"
      required true
      type "string"
    end

    field "nameserver_set" do 
      alias_for "nameServerSet"
      type "string"
    end

    field "kind" do
      type "string"
    end

    #Optional fields for non-create calls
    field "max_results" do 
      type "number"
      location "query"
      alias_for "maxResults"
    end

    output "creationTime","description","dnsName","id","kind","name","nameServerSet","nameServers"

    # https://cloud.google.com/dns/api/v1/managedZones/create
    action "create" do 
      verb "POST"
      path "/projects/$project/managedZones"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/delete
    action "delete" do 
      verb "DELETE"
      path "$href"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/get 
    action "get" do 
      verb "GET"
      path "$href"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/list
    action "list" do 
      verb "GET"
      path "/projects/$project/managedZones"
      output_path "managedZones[]"

      field "max_results" do
        location "query"
        alias_for "maxResults"
      end 
      pagination $google_pagination
    end 

    polling do
      field_values do
        max_results '200'
      end
      period 60
      action 'list'
    end

    link "project" do
      path "/projects/$project"
      type "project"
    end

    link "resourceRecordSets" do
      path "projects/$project/managedZones/{{id}}/rrsets"
      type "resourceRecordSet"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # https://cloud.google.com/dns/api/v1/projects 
  type "project" do
    href_templates "/projects/{{id}}"

    # https://cloud.google.com/dns/api/v1/projects/get
    action "get" do 
      verb "GET"
      path "/projects/$project"
    end 

    output "kind","number","id"

    output "managedZones_quota" do
      body_path "quota.managedZones"
    end 

    output "resourceRecordsPerRrset_quota" do
      body_path "quota.resourceRecordsPerRrset"
    end 

    output "rrsetAdditionsPerChange_quota" do
      body_path "quota.rrsetAdditionsPerChange"
    end 

    output "rrsetDeletionsPerChange_quota" do
      body_path "quota.rrsetDeletionsPerChange"
    end 

    output "rrsetsPerManagedZone_quota" do
      body_path "quota.rrsetsPerManagedZone"
    end 

    output "totalRrdataSizePerChange_quota" do
      body_path "quota.totalRrdataSizePerChange"
    end 

    provision "no_operation"

    delete "no_operation"

  end

type "resourceRecordSet" do
    href_templates "{{rrsets[*].join('-', [@.name, @.rrdatas[0]])}}"
   
    field "record" do
      type "array"
    end

    field "name" do
      type "string"
      required true
    end 

    field "type" do
      type "string"
      required true
    end

    field "ttl" do
      type "number"
      required true
    end

    field "rrdatas" do
      type "array"
      required true
    end 

    #Optional fields for non-create calls
    field "max_results" do 
      type "number"
      location "query"
      alias_for "maxResults"
    end 

    # https://cloud.google.com/dns/api/v1/changes/create
    action "create" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"
      output_path "additions[]"

      field "managed_zone" do
        location "path"
      end

      field "record" do
        alias_for "additions"
      end
    end

    # https://cloud.google.com/dns/api/v1/changes/create
    action "delete" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"

      field "managed_zone" do
        location "path"
      end

      field "record" do
        alias_for "deletions"
      end 

    end

    # https://cloud.google.com/dns/api/v1/resourceRecordSets/list
    action "list" do
      verb "GET"
      path "/projects/$project/managedZones/$managed_zone/rrsets"

      field "max_results" do
        location "query"
        alias_for "maxResults"
      end

      field "managed_zone" do
        location "path"
      end

      field "name" do
        location "query"
        # Note: Required if "type" field is specified
      end 

      field "type" do
        location "query"
      end
      pagination $google_pagination
    end

    polling do
      field_values do
        managed_zone parent_field('name')
        max_results '200'
      end
      parent "managedZone"
      period 60
      action 'list'
    end

    action "get" do 
      verb "GET"
    end

    output "kind","name","type","ttl","rrdatas"

    output_path "rrsets[]" 

    link "project" do
      path "/projects/$project"
      type "project"
    end

    link "managedZone" do
      path "/projects/$project/managedZones/$managed_zone"
      type "managedZone"
    end

    provision "provision_rrset"

    delete "delete_rrset"
  
  end  

end 

resource_pool "clouddns" do
  plugin $clouddns
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_DNS_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/ndev.clouddns.readwrite"
      } end
      signing_key cred("GOOGLE_DNS_PLUGIN_PRIVATE_KEY")
    end
  end
end

define no_operation() do
end

define provision_resource(@raw) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  @operation = clouddns.$type.create($fields)
  call sys_log.detail(to_object(@operation))
  if $type == "change"
    sub timeout: 2m, on_timeout: skip do
      sleep_until @operation.status == "done"
    end
  end 
  @resource = @operation.get()
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define delete_resource(@resource) on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@resource)
  $type = $raw["type"]
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    sub on_error: skip_not_found_error() do
      @operation = @resource.delete()
      if $type == "change"
        sub timeout: 2m, on_timeout: skip do
          sleep_until(@operation.status == "done")
        end
      end 
      call sys_log.detail(to_object(@operation))
    end
  end
  call stop_debugging()
end

define provision_rrset(@raw) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  call sys_log.detail(join(["fields: ", $fields]))
  @operation = clouddns.resourceRecordSet.create(record: [$fields])
  call sys_log.detail(to_object(@operation))
  @resource = @operation.get()
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define delete_rrset(@resource) on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@resource)
  $type = $raw["type"]
  $fields = $raw["details"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Delete: ",$type]))
  call sys_log.detail(join(["fields: ", $fields]))
  sub on_error: stop_debugging() do
    @operation = clouddns.resourceRecordSet.delete(record: $fields)
    call sys_log.detail(to_object(@operation))
  end
  call stop_debugging()
end

define skip_not_found_error() do
  if $_error["message"] =~ "/not found/i"
    log_info($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "skip"
  end
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
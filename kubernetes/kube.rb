name 'kubernetes'
rs_ca_ver 20161221
short_description "kubernetes"
long_description ""
type 'plugin'
package "kubernetes"
import "sys_log"
info(
  provider: "Kubernetes"
)

permission "pft_general_permissions" do
  resources "rs_cm.tags", "rs_cm.instances", "rs_cm.audit_entries", "rs_cm.credentials", "rs_cm.clouds", "rs_cm.sessions", "rs_cm.accounts", "rs_cm.publications"
  actions   "rs_cm.*"
end

permission "pft_sensitive_views" do
  resources "rs_cm.credentials" # Currently these actions are not support for instance resources, "rs_cm.instances"
  actions "rs_cm.index_sensitive", "rs_cm.show_sensitive"
end

parameter "kubernetes_host" do
  type "string"
  label "kubernetes host"
end

parameter "kubernetes_key" do
  type "string"
  label "kubernetes_key"
end

pagination "kubernetes_pagination" do
  get_page_marker do
    body_path "metadata.continue"
  end
  set_page_marker do
    query "continue"
  end
end

plugin "kubernetes" do
  short_description "Kubernetes plugin"
  long_description "Supports a Kubernetes cluster and select resources."
  version "2.0.0"

  documentation_link 'source' do
    label 'Source'
    url 'https://github.com/flexera/flexera-plugins/blob/master/kubernetes/kube.rb'
  end

  documentation_link 'readme' do
    label 'ReadMe'
    url 'https://github.com/flexera/flexera-plugins/blob/master/kubernetes/README.md'
  end

  endpoint do
    default_scheme "https"
    default_host '$kubernetes_host'
    path "/api/v1"
    no_cert_check true
  end

  parameter "kubernetes_host" do
    type "string"
    label "kubernetes host"
  end
  
  parameter "kubernetes_key" do
    type "string"
    label "kubernetes_key"
  end  

  type "pods" do
    href_templates "{{items[].metadata[].uid}}"
    provision "provision_resource"
    delete    "delete_resource"

    action "create" do
      type "pods"
      path "/api/v1/namespaces/default/pods/"
      verb "PUT"
    end

    action "show" do
      path "/api/v1/namespaces/default/pods/"
      verb "GET"
    end

    action "get" do
      type "pods"
      path "$href"
      verb "GET"
    end

    action "list" do
      type "pods"
      path "/pods"
      verb "GET"
      pagination $kubernetes_pagination
      output_path "items[*]"
    end

    polling  do
      period 60
      action 'list'
    end

    action "destroy" do
      type "pods"
      path "$href"
      verb "DELETE"
    end

    output "metadata","spec", "status"

    output "selfLink" do
      body_path "metadata.selfLink"
    end

    output "name" do
      body_path "metadata.name"
    end

    output "labels" do
      body_path "metadata.labels"
    end

    output "containers" do
      body_path "spec.containers"
    end

    output "volumes" do
      body_path "spec.volumes"
    end

    output "volumeMounts" do
      body_path "spec.volumeMounts"
    end
  end
end

resource_pool "kubernetes" do
  plugin $kubernetes

  parameter_values do
    kubernetes_host $kubernetes_host
    kubernetes_key $kubernetes_key
  end

  host $kubernetes_host
  auth "kubernetes_api_key", type: "api_key" do
    # API key value
    # Uses standard CAT field syntax
    key $kubernetes_key
    # Location of the authorization, "header" or "query" - defaults to "header"
    location "header"
    # Name of either the authorization header key or the query parameter field (defaults to "Authorization")
    field "Authorization"
    # Type of authorization header, prefixes the key value (defaults to "Bearer")
    type "Bearer"
  end
end

define skip_known_error() do
  # If all errors were concurrent resource group errors, skip
  $_error_behavior = "skip"
  foreach $e in $_errors do
    call sys_log.detail($e)
    if $e["error_details"]["summary"] !~ /Concurrent process is creating resource group/
      $_error_behavior = "raise"
    end
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    call sys_log.detail(join(["fields", $fields]))
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_aks.$type.create($fields)
    call stop_debugging()
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for aks created")
    sub on_error: retry, timeout: 30m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      call start_debugging()
      @new_resource = @operation.show(name: $name, resource_group: $resource_group )
      call stop_debugging()
    end
    call sys_log.detail("Checking that aks state is online")
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    $status = @new_resource.state
    call sys_log.detail(join(["Status: ", $status]))
    sub on_error: skip, timeout: 30m do
      while $status != "Succeeded" do
        $status = @operation.show(name: $name, resource_group: $resource_group).state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    @resource = @new_resource
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do 
    $delete_count = $delete_count + 1
    @declaration.destroy()
  end
  call stop_debugging()
end

define no_operation(@declaration) do
  $object = to_object(@declaration)
  call sys_log.detail("declaration:" + to_s($object))
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

output "output_pods" do
  label "Pods"
end

output "output_pod_names" do
  label "Pod Names"
end

output "output_containers" do
  label "Containers"
end

operation "get_pods" do
  definition "get_pods"
  output_mappings do {
    $output_pods => $pods,
    $output_pod_names => $podnames,
    $output_containers => $containers
  } end
end

define get_pods() return @pods,$pods,$podnames,$containers do
  call sys_log.summary("List Pods")
  call sys_log.detail("running get pods")
  call start_debugging()
  @pods = kubernetes.pods.empty()
  sub on_error: stop_debugging() do
    @pods = kubernetes.pods.list()
  end
  call sys_log.detail(to_s(@pods))
  call stop_debugging()
  $pods = to_s(@pods)
  $arr_pod_names = []
  $arr_container_names = []
  foreach @pod in @pods do
    $arr_pod_names << @pod.name
    foreach $container in @pod.containers do
      $arr_container_names << $container["name"]
    end
  end
  $podnames = to_s($arr_pod_names)
  $containers = to_s($arr_container_names)
end
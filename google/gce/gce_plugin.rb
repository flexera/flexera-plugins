name "Google Compute Engine (GCE)"
rs_ca_ver 20161221
short_description "Google Compute Engine (GCE)"
long_description ""
type 'plugin'
package "plugins/gce"
import "sys_log"
info(
      provider: "Google",
      service: "Compute"
    )

parameter "gce_project" do
  type "string"
  label "GCE Project"
  category "GCE Plugin"
end

pagination "google_pagination" do
  get_page_marker do
    body_path ".nextPageToken"
  end
  set_page_marker do
    query "pageToken"
  end
end

plugin "gce" do

  short_description 'Google Compute Engine (GCE) plugin'
  long_description 'Plugin support for Google Compute Engine (GCE) compute resources.'
  version '2.0.0'
  json_query_language 'jq'  

  documentation_link 'source' do
    label 'Source'
    url 'https://github.com/flexera/flexera-plugins/blob/master/google/gce/gce_plugin.rb'
  end

  documentation_link 'readme' do
    label 'Readme'
    url 'https://github.com/flexera/flexera-plugins/blob/master/google/gce/README.md'
  end

  parameter 'page_size' do
    type 'string'
    label 'Page size for google responses'
    default '200'
    description 'The maximum results count for each page of google data received.'
  end

  endpoint do
    default_scheme "https"
    default_host "www.googleapis.com"
    path "/compute/v1"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCE project to create resources in"
  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses.
  type "address" do
    href_templates "{{.id}}","{{.items| .[].id}}","{{.items | .[].addresses // [] | .[].id}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "address" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    output "address","creationTimestamp","description","kind","selfLink","users"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
      body_path '.region /"/" | .[8]'
    end

    output 'state' do
	 body_path '.status'
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/addresses"
      type "address"
      output_path ".items | .[].addresses // [] | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/get.
    action "get" do
      verb "GET"
      path "$href"
      type "address"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/addresses"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/addresses"
      type "address"
      output_path "items"
          field "page_size" do
          type 'string'
        location 'query'
        alias_for 'maxResults'
      end
     pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'aggregatedList'
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers.
  type "autoscaler" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.autoscalers[].selfLink}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "autoscalingPolicy" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "target" do
      type "string"
    end

    output "autoscalingPolicy","creationTimestamp","description","id","kind","name","region","selfLink","target","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/autoscalers"
      type "autoscaler"
      output_path "items.*.autoscalers[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/get.
    action "get" do
      verb "GET"
      path "$href"
      type "autoscaler"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/autoscalers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/autoscalers"
      type "autoscaler"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/patch.
    action "patch" do
      verb "PATCH"
      path "/projects/$project/zones/$zone/autoscalers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/autoscalers/update.
    action "update" do
      verb "PUT"
      path "/projects/$project/zones/$zone/autoscalers"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets.
  type "backendBucket" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "bucketName" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "enableCdn" do
      type "boolean"
    end

    field "kind" do
      type "string"
    end

    field "name" do
      type "string"
    end

    output "bucketName","creationTimestamp","description","enableCdn","id","kind","name","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/get.
    action "get" do
      verb "GET"
      path "$href"
      type "backendBucket"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/backendBuckets"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/backendBuckets"
      type "backendBucket"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendBuckets/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices.
  type "backendService" do
    href_templates "{{.id}}","{{.items | .[].id}}","{{.items | .[].backendServices // [] | .[].id}}"

    field "affinityCookieTtlSec" do
      type "number"
    end

    field "backends" do
      type "array"
    end

    field "cdnPolicy" do
      type "object"
    end

    field "connectionDraining" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "enableCDN" do
      type "boolean"
    end

    field "fingerprint" do
      type "string"
    end

    field "healthChecks" do
      type "array"
    end

    field "loadBalancingScheme" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "port" do
      type "number"
    end

    field "portName" do
      type "string"
    end

    field "protocol" do
      type "string"
    end

    field "sessionAffinity" do
      type "string"
    end

    field "timeoutSec" do
      type "number"
    end

    output "affinityCookieTtlSec","backends","cdnPolicy","connectionDraining","creationTimestamp","description","enableCDN","fingerprint","healthChecks","kind","loadBalancingScheme","port","portName","protocol","selfLink","sessionAffinity","timeoutSec"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
      body_path '.region /"/" | .[8]'
    end

    output 'state' do
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/backendServices"
      type "backendService"
      output_path ".items | .[].backendServices // [] | .[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/get.
    action "get" do
      verb "GET"
      path "$href"
      type "backendService"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/getHealth.
    action "getHealth" do
      verb "POST"
      path "$href/getHealth"
      type "backendServiceGroupHealth"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/backendServices"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/backendServices"
      type "backendService"
      output_path ".items | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/backendServices/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/diskTypes.
  type "diskType" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.diskTypes[].selfLink}}"

    output "creationTimestamp","defaultDiskSizeGb","deprecated","description","id","kind","name","selfLink","validDiskSize","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/diskTypes/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/diskTypes"
      type "diskType"
      output_path "items.*.diskTypes[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/diskTypes/get.
    action "get" do
      verb "GET"
      path "$href"
      type "diskType"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/diskTypes/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/diskTypes"
      type "diskType"
      output_path "items"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks.
  type "disk" do
    href_templates "{{.id}}","{{.items | .[].id}}","{{.items | .[].disks // [] | .[].id}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "sourceImage" do
      location "query"
      type "string"
    end

    field "description" do
      type "string"
    end

    field "diskEncryptionKey" do
      type "object"
    end

    field "licenses" do
      type "array"
    end

    field "name" do
      required true
      type "string"
    end

    field "options" do
      type "string"
    end

    field "sizeGb" do
      type "number"
    end

    field "sourceImageEncryptionKey" do
      type "object"
    end

    field "sourceSnapshot" do
      type "string"
    end

    field "sourceSnapshotEncryptionKey" do
      type "object"
    end

    field "type" do
      type "string"
    end

    output "creationTimestamp","description","diskEncryptionKey","kind","lastAttachTimestamp","lastDetachTimestamp","licenses","options","selfLink","sizeGb","sourceImage","sourceImageEncryptionKey","sourceImageId","sourceSnapshot","sourceSnapshotEncryptionKey","sourceSnapshotId","type","users"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
      body_path '.zone /"/" | .[8] [:-2]'
    end

    output 'state' do
      body_path '.status'
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/disks"
      type "disk"
      output_path ".items | .[].disks // [] | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/createSnapshot.
    action "createSnapshot" do
      verb "POST"
      path "$href/createSnapshot"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "disk"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/disks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/disks"
      type "disk"
      output_path "items"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'aggregatedList'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/disks/resize.
    action "resize" do
      verb "POST"
      path "$href/resize"
      type "operation"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls.
  type "firewall" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "allowed" do
      type "array"
    end

    field "description" do
      type "string"
    end

    field "kind" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    field "network" do
      type "string"
    end

    field "sourceRanges" do
      type "array"
    end

    field "sourceTags" do
      type "array"
    end

    field "targetTags" do
      type "array"
    end

    output "allowed","creationTimestamp","description","id","kind","name","network","selfLink","sourceRanges","sourceTags","targetTags"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/get.
    action "get" do
      verb "GET"
      path "$href"
      type "firewall"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/firewalls"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/firewalls"
      type "firewall"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/firewalls/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    link "network" do
      url "$network"
      type "network"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules.
  type "forwardingRule" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.forwardingRules[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "ipAddress" do
      alias_for "IPAddress"
      type "string"
    end

    field "ipProtocol" do
      alias_for "IPProtocol"
      type "string"
    end

    field "backendService" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "loadBalancingScheme" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "network" do
      type "string"
    end

    field "portRange" do
      type "string"
    end

    field "ports" do
      type "array"
    end

    field "subnetwork" do
      type "string"
    end

    field "target" do
      type "string"
    end

    output "IPAddress","IPProtocol","backendService","creationTimestamp","description","id","kind","loadBalancingScheme","name","network","portRange","ports","region","selfLink","subnetwork","target"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/forwardingRules"
      type "forwardingRule"
      output_path "items.*.forwardingRules[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/get.
    action "get" do
      verb "GET"
      path "$href"
      type "forwardingRule"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/forwardingRules"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/forwardingRules"
      type "forwardingRule"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/forwardingRules/setTarget.
    action "setTarget" do
      verb "POST"
      path "$href/setTarget"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalAddresses.
  type "globalAddress" do
    field "address" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    output "address","creationTimestamp","description","id","kind","name","region","selfLink","status","users"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalAddresses/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/addresses"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalAddresses/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/addresses"
      type "address"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalForwardingRules.
  # type "globalForwardingRule" do
  #   href_templates "{{id}}","{{items[*].id}}"
  #
  #   field "ipAddress" do
  #     alias_for "IPAddress"
  #     type "string"
  #   end
  #
  #   field "ipProtocol" do
  #     alias_for "IPProtocol"
  #     type "string"
  #   end
  #
  #   field "backendService" do
  #     type "string"
  #   end
  #
  #   field "description" do
  #     type "string"
  #   end
  #
  #   field "loadBalancingScheme" do
  #     type "string"
  #   end
  #
  #   field "name" do
  #     type "string"
  #   end
  #
  #   field "network" do
  #     type "string"
  #   end
  #
  #   field "portRange" do
  #     type "string"
  #   end
  #
  #   field "ports" do
  #     type "array"
  #   end
  #
  #   field "subnetwork" do
  #     type "string"
  #   end
  #
  #   field "target" do
  #     type "string"
  #   end
  #
  #   output "IPAddress","IPProtocol","backendService","creationTimestamp","description","kind","loadBalancingScheme","network","portRange","ports","selfLink","subnetwork","target"
  #
  #   output 'id' do
  #    body_path 'id'
  #   end
  #
  #   output 'name' do
	#   body_path 'name'
  #   end
  #
  #   output 'region' do
  #     body_path 'region'
  #   end
  #
  #   output 'state' do
  #   end
  #
  #   output 'tags' do
  #   end
  #
  #   # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalForwardingRules/get.
  #   action "get" do
  #     verb "GET"
  #     path "$href"
  #     type "forwardingRule"
  #   end
  #
  #   # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalForwardingRules/insert.
  #   action "insert" do
  #     verb "POST"
  #     path "/projects/$project/global/forwardingRules"
  #     type "operation"
  #   end
  #
  #   # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalForwardingRules/list.
  #   action "list" do
  #     verb "GET"
  #     path "/projects/$project/global/forwardingRules"
  #     type "forwardingRule"
  #     output_path "items"
  #     field "page_size" do
  #         type 'string'
  #         location 'query'
  #         alias_for 'maxResults'
  #     end
  #     pagination $google_pagination
  #   end
  #
  #   polling do
  #     field_values do
  #     page_size $page_size
  #   end
  #     period 60
  #     action 'list'
  #   end
  #
  #   link "region" do
  #     url "$region"
  #     type "region"
  #   end
  #
  #   provision "provision_resource"
  #
  #   delete "delete_resource"
  #
  # end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations.
  type "globalOperation" do
    output "clientOperationId","creationTimestamp","description","endTime","error","httpErrorMessage","httpErrorStatusCode","id","insertTime","kind","name","operationType","progress","region","selfLink","startTime","status","statusMessage","targetId","targetLink","user","warnings","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "$href/operations"
      type "operation"
      output_path "items.*.globalOperations[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/list.
    action "list" do
      verb "GET"
      path "$href/operations"
      type "operation"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "no_operation"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks.
  type "healthCheck" do
    href_templates "{{.id}}","{{.items | .[].id}}"

    field "checkIntervalSec" do
      type "number"
    end

    field "description" do
      type "string"
    end

    field "healthyThreshold" do
      type "number"
    end

    field "httpHealthCheck" do
      type "object"
    end

    field "httpsHealthCheck" do
      type "object"
    end

    field "kind" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "sslHealthCheck" do
      type "object"
    end

    field "tcpHealthCheck" do
      type "object"
    end

    field "timeoutSec" do
      type "number"
    end

    field "type" do
      type "string"
    end

    field "unhealthyThreshold" do
      type "number"
    end

    output "checkIntervalSec","creationTimestamp","description","healthyThreshold","httpHealthCheck","httpsHealthCheck","kind","selfLink","sslHealthCheck","tcpHealthCheck","timeoutSec","type","unhealthyThreshold"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
	  body_path '.selfLink /"/" | .[7]'	
    end

    output 'state' do
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "healthCheck"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/healthChecks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/healthChecks"
      type "healthCheck"
      output_path ".items | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/healthChecks/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks.
  type "httpHealthCheck" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "checkIntervalSec" do
      type "number"
    end

    field "description" do
      type "string"
    end

    field "healthyThreshold" do
      type "number"
    end

    field "host" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "port" do
      type "number"
    end

    field "requestPath" do
      type "string"
    end

    field "timeoutSec" do
      type "number"
    end

    field "unhealthyThreshold" do
      type "number"
    end

    output "checkIntervalSec","creationTimestamp","description","healthyThreshold","host","id","kind","name","port","requestPath","selfLink","timeoutSec","unhealthyThreshold"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "httpHealthCheck"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/httpHealthChecks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/httpHealthChecks"
      type "httpHealthCheck"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks.
  type "httpsHealthCheck" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "checkIntervalSec" do
      type "number"
    end

    field "description" do
      type "string"
    end

    field "healthyThreshold" do
      type "number"
    end

    field "host" do
      type "string"
    end

    field "kind" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "port" do
      type "number"
    end

    field "requestPath" do
      type "string"
    end

    field "timeoutSec" do
      type "number"
    end

    field "unhealthyThreshold" do
      type "number"
    end

    output "checkIntervalSec","creationTimestamp","description","healthyThreshold","host","id","kind","name","port","requestPath","selfLink","timeoutSec","unhealthyThreshold"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "httpsHealthCheck"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/httpsHealthChecks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/httpsHealthChecks"
      type "httpsHealthCheck"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images.
  type "image" do
    href_templates "{{.id}}","{{.items| .[].id}}"

    field "archiveSizeBytes" do
      type "number"
    end

    field "deprecated" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "diskSizeGb" do
      type "number"
    end

    field "family" do
      type "string"
    end

    field "guestOsFeatures" do
      type "array"
    end

    field "imageEncryptionKey" do
      type "object"
    end

    field "licenses" do
      type "array"
    end

    field "name" do
      required true
      type "string"
    end

    field "rawDisk" do
      type "object"
    end

    field "sourceDisk" do
      type "string"
    end

    field "sourceDiskEncryptionKey" do
      type "object"
    end

    field "sourceDiskId" do
      type "string"
    end

    field "sourceType" do
      type "string"
    end

    output "archiveSizeBytes","creationTimestamp","deprecated","description","diskSizeGb","family","guestOsFeatures","imageEncryptionKey","kind","licenses","rawDisk","selfLink","sourceDisk","sourceDiskEncryptionKey","sourceDiskId","sourceType","status"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
	  body_path '.selfLink /"/" | .[7]'	
    end

    output 'state' do
	  body_path '.status'	
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/deprecate.
    action "deprecate" do
      verb "POST"
      path "$href/deprecate"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/get.
    action "get" do
      verb "GET"
      path "$href"
      type "image"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/getFromFamily.
    action "getFromFamily" do
      verb "GET"
      path "$href/$family"
      type "image"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/images"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/images/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/images"
      type "image"
      output_path ".items| .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers.
  type "instanceGroupManager" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.instanceGroupManagers[].selfLink}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "baseInstanceName" do
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "instanceTemplate" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    field "namedPorts" do
      type "array"
    end

    field "targetPools" do
      type "array"
    end

    field "targetSize" do
      required true
      type "number"
    end

    output "baseInstanceName","creationTimestamp","currentActions","description","fingerprint","id","instanceGroup","instanceTemplate","kind","name","namedPorts","region","selfLink","targetPools","targetSize","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/abandonInstances.
    action "abandonInstances" do
      verb "POST"
      path "$href/abandonInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/instanceGroupManagers"
      type "instanceGroupManager"
      output_path "items.*.instanceGroupManagers[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/deleteInstances.
    action "deleteInstances" do
      verb "POST"
      path "$href/deleteInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/get.
    action "get" do
      verb "GET"
      path "$href"
      type "instanceGroupManager"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/instanceGroupManagers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/instanceGroupManagers"
      type "instanceGroupManager"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/recreateInstances.
    action "recreateInstances" do
      verb "POST"
      path "$href/recreateInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/resize.
    action "resize" do
      verb "POST"
      path "$href/resize"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/setInstanceTemplate.
    action "setInstanceTemplate" do
      verb "POST"
      path "$href/setInstanceTemplate"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers/setTargetPools.
    action "setTargetPools" do
      verb "POST"
      path "$href/setTargetPools"
      type "operation"
    end

    link "instanceGroup" do
      url "$instanceGroup"
      type "instanceGroup"
    end

    link "instanceTemplate" do
      url "$instanceTemplate"
      type "instanceTemplate"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups.
  type "instanceGroup" do
    href_templates "{{.id}}","{{.items| .[].id}}","{{.items | .[].instanceGroups // [] | .[].id}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "namedPorts" do
      type "array"
    end

    field "network" do
      type "string"
    end

    field "region" do
      type "string"
    end

    field "subnetwork" do
      type "string"
    end

    output "creationTimestamp","description","fingerprint","kind","namedPorts","network","selfLink","size","subnetwork","zone"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
      body_path '.region /"/" | .[8]'
    end

    output 'state' do
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/addInstances.
    action "addInstances" do
      verb "POST"
      path "$href/addInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/instanceGroups"
      type "instanceGroup"
      output_path ".items | .[].instanceGroups // [] | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/get.
    action "get" do
      verb "GET"
      path "$href"
      type "instanceGroup"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/instanceGroups"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/instanceGroups"
      type "instanceGroup"
      output_path "items"
        field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'aggregatedList'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/listInstances.
    action "listInstances" do
      verb "POST"
      path "$href/listInstances"
      type "instanceGroupsListInstances"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/removeInstances.
    action "removeInstances" do
      verb "POST"
      path "$href/removeInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/setNamedPorts.
    action "setNamedPorts" do
      verb "POST"
      path "$href/setNamedPorts"
      type "operation"
    end

    link "network" do
      url "$network"
      type "network"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "subnetwork" do
      url "$subnetwork"
      type "subnetwork"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceTemplates.
  type "instanceTemplate" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "description" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    field "properties" do
      type "object"
    end

    output "creationTimestamp","description","id","kind","name","properties","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceTemplates/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceTemplates/get.
    action "get" do
      verb "GET"
      path "$href"
      type "instanceTemplate"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceTemplates/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/instanceTemplates"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceTemplates/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/instanceTemplates"
      type "instanceTemplate"
      output_path "items"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances.
  type "instance" do
    href_templates "{{.id}}","{{.items| .id}}","{{.items | .[].instances // [] | .[].id}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "canIpForward" do
      type "boolean"
    end

    field "description" do
      type "string"
    end

    field "disks" do
      type "array"
    end

    field "machineType" do
      required true
      type "string"
    end

    field "metadata" do
      type "object"
    end

    field "name" do
      required true
      type "string"
    end

    field "networkInterfaces" do
      type "array"
    end

    field "scheduling" do
      type "object"
    end

    field "serviceAccounts" do
      type "array"
    end

    field "tags" do
      type "object"
    end

    output "canIpForward","cpuPlatform","creationTimestamp","description","disks","kind","machineType","metadata","networkInterfaces","scheduling","selfLink","serviceAccounts","statusMessage"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
     body_path '.zone /"/" | .[8] [:-2]'
    end

    output 'state' do
	 body_path '.status'
    end

    output 'tags' do
     body_path '.tags'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/addAccessConfig.
    action "addAccessConfig" do
      verb "POST"
      path "$href/addAccessConfig"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/instances"
      type "instance"
      output_path ".items | .[].instances // [] | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/attachDisk.
    action "attachDisk" do
      verb "POST"
      path "$href/attachDisk"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/deleteAccessConfig.
    action "deleteAccessConfig" do
      verb "POST"
      path "$href/deleteAccessConfig"
      type "operation"

      field "accessConfig" do
        location "query"
      end
      field "networkInterface" do
        location "query"
      end
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/detachDisk.
    action "detachDisk" do
      verb "POST"
      path "$href/detachDisk"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/get.
    action "get" do
      verb "GET"
      path "$href"
      type "instance"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/getSerialPortOutput.
    action "getSerialPortOutput" do
      verb "GET"
      path "$href/serialPort"
      type "serialPortOutput"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/instances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/instances"
      type "instance"
      output_path "items"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'aggregatedList'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/reset.
    action "reset" do
      verb "POST"
      path "$href/reset"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setDiskAutoDelete.
    action "setDiskAutoDelete" do
      verb "POST"
      path "$href/setDiskAutoDelete"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setMachineType.
    action "setMachineType" do
      verb "POST"
      path "$href/setMachineType"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setMetadata.
    action "setMetadata" do
      verb "POST"
      path "$href/setMetadata"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setScheduling.
    action "setScheduling" do
      verb "POST"
      path "$href/setScheduling"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setTags.
    action "setTags" do
      verb "POST"
      path "$href/setTags"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/start.
    action "start" do
      verb "POST"
      path "$href/start"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/startWithEncryptionKey.
    action "startWithEncryptionKey" do
      verb "POST"
      path "$href/startWithEncryptionKey"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/stop.
    action "stop" do
      verb "POST"
      path "$href/stop"
      type "operation"
    end

    link "machineType" do
      url "$machineType"
      type "machineType"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/licenses.
  type "license" do
    href_templates "{{selfLink}}"

    output "chargesUseFee","kind","name","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/licenses/get.
    action "get" do
      verb "GET"
      path "$href"
      type "license"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/machineTypes.
  type "machineType" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.machineTypes[].selfLink}}"

    output "creationTimestamp","deprecated","description","guestCpus","id","imageSpaceGb","isSharedCpu","kind","maximumPersistentDisks","maximumPersistentDisksSizeGb","memoryMb","name","scratchDisks","selfLink","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/machineTypes/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/machineTypes"
      type "machineType"
      output_path "items.*.machineTypes[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/machineTypes/get.
    action "get" do
      verb "GET"
      path "$href"
      type "machineType"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/machineTypes/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/machineTypes"
      type "machineType"
      output_path "items"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks.
  type "network" do
    href_templates "{{.id}}","{{.items| .[].id}}"

    field "ipv4Range" do
      alias_for "IPv4Range"
      type "string"
    end

    field "autoCreateSubnetworks" do
      type "boolean"
    end

    field "description" do
      type "string"
    end

    field "gatewayIPv4" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    output "IPv4Range","autoCreateSubnetworks","creationTimestamp","description","gatewayIPv4","kind","selfLink","subnetworks"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
	  body_path '.selfLink /"/" | .[7]'
    end

    output 'state' do
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "network"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/networks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/networks"
      type "network"
      output_path ".items | .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/networks/switchToCustomMode.
    action "switchToCustomMode" do
      verb "POST"
      path "$href/switchToCustomMode"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations.
  type "operation" do
    href_templates "{{selfLink}}"

    output "clientOperationId","creationTimestamp","description","endTime","error","httpErrorMessage","httpErrorStatusCode","id","insertTime","kind","name","operationType","progress","region","selfLink","startTime","status","statusMessage","targetId","targetLink","user","warnings","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/get.
    action "get" do
      verb "GET"
      path "$href"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "targetLink" do
      url "$targetLink"
    end

    provision "no_operation"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects.
  type "project" do
    href_templates "{{selfLink}}"

    field "commonInstanceMetadata" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "enabledFeatures" do
      type "array"
    end

    field "name" do
      type "string"
    end

    field "usageExportLocation" do
      type "object"
    end

    output "commonInstanceMetadata","creationTimestamp","defaultServiceAccount","description","enabledFeatures","id","kind","name","quotas","selfLink","usageExportLocation"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects/get.
    action "get" do
      verb "GET"
      path "$href"
      type "project"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects/moveDisk.
    action "moveDisk" do
      verb "POST"
      path "$href/moveDisk"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects/moveInstance.
    action "moveInstance" do
      verb "POST"
      path "$href/moveInstance"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects/setCommonInstanceMetadata.
    action "setCommonInstanceMetadata" do
      verb "POST"
      path "$href/setCommonInstanceMetadata"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/projects/setUsageExportBucket.
    action "setUsageExportBucket" do
      verb "POST"
      path "$href/setUsageExportBucket"
      type "operation"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionAutoscalers.
  type "regionAutoscaler" do
    field "region" do
      location "path"
      required true
      type "string"
    end

    field "autoscalingPolicy" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "target" do
      type "string"
    end

    output "autoscalingPolicy","creationTimestamp","description","id","kind","name","region","selfLink","target","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionAutoscalers/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/autoscalers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionAutoscalers/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/autoscalers"
      type "regionAutoscalerList"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionBackendServices.
  type "regionBackendService" do
    field "region" do
      location "path"
      required true
      type "string"
    end

    field "affinityCookieTtlSec" do
      type "number"
    end

    field "backends" do
      type "array"
    end

    field "connectionDraining" do
      type "object"
    end

    field "description" do
      type "string"
    end

    field "enableCDN" do
      type "boolean"
    end

    field "fingerprint" do
      type "string"
    end

    field "healthChecks" do
      type "array"
    end

    field "loadBalancingScheme" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "port" do
      type "number"
    end

    field "portName" do
      type "string"
    end

    field "protocol" do
      type "string"
    end

    field "sessionAffinity" do
      type "string"
    end

    field "timeoutSec" do
      type "number"
    end

    output "affinityCookieTtlSec","backends","connectionDraining","creationTimestamp","description","enableCDN","fingerprint","healthChecks","id","kind","loadBalancingScheme","name","port","portName","protocol","region","selfLink","sessionAffinity","timeoutSec"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionBackendServices/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/backendServices"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionBackendServices/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/backendServices"
      type "backendService"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroupManagers.
  type "regionInstanceGroupManager" do
    field "region" do
      location "path"
      required true
      type "string"
    end

    field "baseInstanceName" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "instanceTemplate" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "namedPorts" do
      type "array"
    end

    field "targetPools" do
      type "array"
    end

    field "targetSize" do
      type "number"
    end

    output "baseInstanceName","creationTimestamp","currentActions","description","fingerprint","id","instanceGroup","instanceTemplate","kind","name","namedPorts","region","selfLink","targetPools","targetSize","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroupManagers/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/instanceGroupManagers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroupManagers/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/instanceGroupManagers"
      type "regionInstanceGroupManagerList"
    end

    link "instanceGroup" do
      url "$instanceGroup"
      type "instanceGroup"
    end

    link "instanceTemplate" do
      url "$instanceTemplate"
      type "instanceTemplate"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroups.
  type "regionInstanceGroup" do
    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "namedPorts" do
      type "array"
    end

    field "network" do
      type "string"
    end

    field "region" do
      type "string"
    end

    field "subnetwork" do
      type "string"
    end

    output "creationTimestamp","description","fingerprint","id","kind","name","namedPorts","network","region","selfLink","size","subnetwork","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroups/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/instanceGroups"
      type "regionInstanceGroupList"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroups/listInstances.
    action "listInstances" do
      verb "POST"
      path "$href/listInstances"
      type "regionInstanceGroupsListInstances"
    end

    link "network" do
      url "$network"
      type "network"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "subnetwork" do
      url "$subnetwork"
      type "subnetwork"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionOperations.
  type "regionOperation" do
    output "clientOperationId","creationTimestamp","description","endTime","error","httpErrorMessage","httpErrorStatusCode","id","insertTime","kind","name","operationType","progress","region","selfLink","startTime","status","statusMessage","targetId","targetLink","user","warnings","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regionOperations/list.
    action "list" do
      verb "GET"
      path "$href/operations"
      type "operation"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "no_operation"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regions.
  type "region" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    output "creationTimestamp","deprecated","description","id","kind","name","quotas","selfLink","status","zones"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regions/get.
    action "get" do
      verb "GET"
      path "$href"
      type "region"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/regions/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions"
      type "region"
      output_path "items"
    end

    provision "no_operation"

    delete "no_operation"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers.
  type "router" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.routers[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "bgp" do
      type "object"
    end

    field "bgpPeers" do
      type "array"
    end

    field "description" do
      type "string"
    end

    field "interfaces" do
      type "array"
    end

    field "name" do
      required true
      type "string"
    end

    field "network" do
      required true
      type "string"
    end

    output "bgp","bgpPeers","creationTimestamp","description","id","interfaces","kind","name","network","region","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/routers"
      type "router"
      output_path "items.*.routers[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/get.
    action "get" do
      verb "GET"
      path "$href"
      type "router"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/routers"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/routers"
      type "router"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routers/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routes.
  type "route" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "description" do
      type "string"
    end

    field "destRange" do
      required true
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    field "network" do
      required true
      type "string"
    end

    field "nextHopGateway" do
      required true
      type "string"
    end

    field "nextHopInstance" do
      required true
      type "string"
    end

    field "nextHopIp" do
      required true
      type "string"
    end

    field "nextHopVpnTunnel" do
      required true
      type "string"
    end

    field "priority" do
      required true
      type "number"
    end

    field "tags" do
      type "array"
    end

    output "creationTimestamp","description","destRange","id","kind","name","network","nextHopGateway","nextHopInstance","nextHopIp","nextHopNetwork","nextHopVpnTunnel","priority","selfLink","tags","warnings"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routes/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routes/get.
    action "get" do
      verb "GET"
      path "$href"
      type "route"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routes/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/routes"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/routes/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/routes"
      type "route"
      output_path "items"
    end

    link "network" do
      url "$network"
      type "network"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/snapshots.
  type "snapshot" do
    href_templates "{{.id}}","{{.items| .[].id}}"

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "snapshotEncryptionKey" do
      type "object"
    end

    field "sourceDiskEncryptionKey" do
      type "object"
    end

    output "creationTimestamp","description","diskSizeGb","kind","licenses","selfLink","snapshotEncryptionKey","sourceDisk","sourceDiskEncryptionKey","sourceDiskId","storageBytes","storageBytesStatus"

    output 'id' do
     body_path '.id'
    end

    output 'name' do
	  body_path '.name'
    end

    output 'region' do
	  body_path '.selfLink /"/" | .[7]'
    end

    output 'state' do
	 body_path '.status'
    end

    output 'tags' do
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/snapshots/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/snapshots/get.
    action "get" do
      verb "GET"
      path "$href"
      type "snapshot"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/snapshots/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/snapshots"
      type "snapshot"
      output_path ".items| .[]"
      field "page_size" do
          type 'string'
          location 'query'
          alias_for 'maxResults'
      end
      pagination $google_pagination
    end

    polling do
      field_values do
      page_size $page_size
    end
      period 60
      action 'list'
    end

    provision "no_operation"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/sslCertificates.
  type "sslCertificate" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "certificate" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "privateKey" do
      type "string"
    end

    field "selfLink" do
      type "string"
    end

    output "certificate","creationTimestamp","description","id","kind","name","privateKey","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/sslCertificates/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/sslCertificates/get.
    action "get" do
      verb "GET"
      path "$href"
      type "sslCertificate"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/sslCertificates/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/sslCertificates"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/sslCertificates/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/sslCertificates"
      type "sslCertificate"
      output_path "items"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks.
  type "subnetwork" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.subnetworks[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "ipCidrRange" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "network" do
      type "string"
    end

    output "creationTimestamp","description","gatewayAddress","id","ipCidrRange","kind","name","network","region","selfLink"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/subnetworks"
      type "subnetwork"
      output_path "items.*.subnetworks[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/expandIpCidrRange.
    action "expandIpCidrRange" do
      verb "POST"
      path "$href/expandIpCidrRange"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/get.
    action "get" do
      verb "GET"
      path "$href"
      type "subnetwork"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/subnetworks"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/subnetworks/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/subnetworks"
      type "subnetwork"
      output_path "items"
    end

    link "network" do
      url "$network"
      type "network"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies.
  type "targetHttpProxy" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "urlMap" do
      type "string"
    end

    output "creationTimestamp","description","id","kind","name","selfLink","urlMap"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetHttpProxy"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/targetHttpProxies"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/targetHttpProxies"
      type "targetHttpProxy"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies/setUrlMap.
    action "setUrlMap" do
      verb "POST"
      path "$href/setUrlMap"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies.
  type "targetHttpsProxy" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "sslCertificates" do
      type "array"
    end

    field "urlMap" do
      type "string"
    end

    output "creationTimestamp","description","id","kind","name","selfLink","sslCertificates","urlMap"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetHttpsProxy"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/targetHttpsProxies"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/targetHttpsProxies"
      type "targetHttpsProxy"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/setSslCertificates.
    action "setSslCertificates" do
      verb "POST"
      path "$href/setSslCertificates"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies/setUrlMap.
    action "setUrlMap" do
      verb "POST"
      path "$href/setUrlMap"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances.
  type "targetInstance" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.targetInstances[].selfLink}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "instance" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "natPolicy" do
      type "string"
    end

    output "creationTimestamp","description","id","instance","kind","name","natPolicy","selfLink","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/targetInstances"
      type "targetInstance"
      output_path "items.*.targetInstances[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetInstance"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/zones/$zone/targetInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetInstances/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/targetInstances"
      type "targetInstance"
      output_path "items"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools.
  type "targetPool" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.targetPools[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "backupPool" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "failoverRatio" do
      type "string"
    end

    field "healthChecks" do
      type "array"
    end

    field "instances" do
      type "array"
    end

    field "name" do
      type "string"
    end

    field "sessionAffinity" do
      type "string"
    end

    output "backupPool","creationTimestamp","description","failoverRatio","healthChecks","id","instances","kind","name","region","selfLink","sessionAffinity"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/addHealthCheck.
    action "addHealthCheck" do
      verb "POST"
      path "$href/addHealthCheck"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/addInstance.
    action "addInstance" do
      verb "POST"
      path "$href/addInstance"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/targetPools"
      type "targetPool"
      output_path "items.*.targetPools[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetPool"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/getHealth.
    action "getHealth" do
      verb "POST"
      path "$href/getHealth"
      type "targetPoolInstanceHealth"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/targetPools"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/targetPools"
      type "targetPool"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/removeHealthCheck.
    action "removeHealthCheck" do
      verb "POST"
      path "$href/removeHealthCheck"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/removeInstance.
    action "removeInstance" do
      verb "POST"
      path "$href/removeInstance"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetPools/setBackup.
    action "setBackup" do
      verb "POST"
      path "$href/setBackup"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies.
  type "targetSslProxy" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "proxyHeader" do
      type "string"
    end

    field "service" do
      type "string"
    end

    field "sslCertificates" do
      type "array"
    end

    output "creationTimestamp","description","id","kind","name","proxyHeader","selfLink","service","sslCertificates"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetSslProxy"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/targetSslProxies"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/targetSslProxies"
      type "targetSslProxy"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/setBackendService.
    action "setBackendService" do
      verb "POST"
      path "$href/setBackendService"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/setProxyHeader.
    action "setProxyHeader" do
      verb "POST"
      path "$href/setProxyHeader"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetSslProxies/setSslCertificates.
    action "setSslCertificates" do
      verb "POST"
      path "$href/setSslCertificates"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways.
  type "targetVpnGateway" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.targetVpnGateways[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      required true
      type "string"
    end

    field "network" do
      required true
      type "string"
    end

    output "creationTimestamp","description","forwardingRules","id","kind","name","network","region","selfLink","status","tunnels"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/targetVpnGateways"
      type "targetVpnGateway"
      output_path "items.*.targetVpnGateways[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways/get.
    action "get" do
      verb "GET"
      path "$href"
      type "targetVpnGateway"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/targetVpnGateways"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/targetVpnGateways"
      type "targetVpnGateway"
      output_path "items"
    end

    link "network" do
      url "$network"
      type "network"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps.
  type "urlMap" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    field "defaultService" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "fingerprint" do
      type "string"
    end

    field "hostRules" do
      type "array"
    end

    field "name" do
      type "string"
    end

    field "pathMatchers" do
      type "array"
    end

    field "tests" do
      type "array"
    end

    output "creationTimestamp","defaultService","description","fingerprint","hostRules","id","kind","name","pathMatchers","selfLink","tests"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/get.
    action "get" do
      verb "GET"
      path "$href"
      type "urlMap"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/global/urlMaps"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/invalidateCache.
    action "invalidateCache" do
      verb "POST"
      path "$href/invalidateCache"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/list.
    action "list" do
      verb "GET"
      path "/projects/$project/global/urlMaps"
      type "urlMap"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/patch.
    action "patch" do
      verb "PATCH"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/urlMaps/update.
    action "update" do
      verb "PUT"
      path "$href"
      type "operation"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels.
  type "vpnTunnel" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.vpnTunnels[].selfLink}}"

    field "region" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "ikeVersion" do
      type "number"
    end

    field "localTrafficSelector" do
      type "array"
    end

    field "name" do
      required true
      type "string"
    end

    field "peerIp" do
      type "string"
    end

    field "remoteTrafficSelector" do
      type "array"
    end

    field "router" do
      type "string"
    end

    field "sharedSecret" do
      type "string"
    end

    field "sharedSecretHash" do
      type "string"
    end

    field "targetVpnGateway" do
      required true
      type "string"
    end

    output "creationTimestamp","description","detailedStatus","id","ikeVersion","kind","localTrafficSelector","name","peerIp","region","remoteTrafficSelector","router","selfLink","sharedSecret","sharedSecretHash","status","targetVpnGateway"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels/aggregatedList.
    action "aggregatedList" do
      verb "GET"
      path "/projects/$project/aggregated/vpnTunnels"
      type "vpnTunnel"
      output_path "items.*.vpnTunnels[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels/get.
    action "get" do
      verb "GET"
      path "$href"
      type "vpnTunnel"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels/insert.
    action "insert" do
      verb "POST"
      path "/projects/$project/regions/$region/vpnTunnels"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/vpnTunnels/list.
    action "list" do
      verb "GET"
      path "/projects/$project/regions/$region/vpnTunnels"
      type "vpnTunnel"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "targetVpnGateway" do
      url "$targetVpnGateway"
      type "targetVpnGateway"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/zoneOperations.
  type "zoneOperation" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    output "clientOperationId","creationTimestamp","description","endTime","error","httpErrorMessage","httpErrorStatusCode","id","insertTime","kind","name","operationType","progress","region","selfLink","startTime","status","statusMessage","targetId","targetLink","user","warnings","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/zoneOperations/list.
    action "list" do
      verb "GET"
      path "$href/operations"
      type "operation"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "no_operation"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/zones.
  type "zone" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}"

    output "creationTimestamp","deprecated","description","id","kind","name","region","selfLink","status"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/zones/get.
    action "get" do
      verb "GET"
      path "$href"
      type "zone"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/zones/list.
    action "list" do
      verb "GET"
      path "/projects/$project/zones"
      type "zone"
      output_path "items"
    end

    provision "no_operation"

    delete "no_operation"

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
  @operation = gce.$type.insert($fields)
  call sys_log.detail(to_object(@operation))
  sub timeout: 2m, on_timeout: skip do
    sleep_until @operation.status == "DONE"
  end
  call sys_log.detail(to_object(@resource))
  @resource = @operation.targetLink()
  call stop_debugging()
end

define delete_resource(@resource) on_error: stop_debugging() do
  call start_debugging()
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    sub on_error: skip_not_found_error() do
      @operation = @resource.delete()
      sub timeout: 2m, on_timeout: skip do
        sleep_until(@operation.status == "DONE")
      end
      call sys_log.detail(to_object(@operation))
    end
  end
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

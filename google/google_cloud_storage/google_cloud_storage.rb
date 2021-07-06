name "Google Cloud Storage"
type "plugin"
rs_ca_ver 20161221
short_description "Google cloud storage bucket details"
long_description ""
package "plugins/google_cloud_storage"
info(
      provider: "Google",
      service: "Storage"
    )
    
parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

pagination "gce_pagination" do
  get_page_marker do
    body_path "nextPageToken"
  end
  set_page_marker do
    query "pageToken"
  end
end

plugin "google_cloud_storage" do

  short_description "GCE Cloud storage"
  long_description "Supports polling activity for google cloud storage bucket with support for pagination"
  version "v2.0.0"
  json_query_language 'jq'
  
  documentation_link "source" do
    label "Source"
    url "https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_storage/google_cloud_storage.rb"
  end

  documentation_link "readme" do
    label "ReadMe"
    url "https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_storage/README.md"
  end

  parameter "project_id" do
    type "string"
    label "Project Id"
    description "Project identifier for which storage bucket details are fetched"
  end

  endpoint do
    default_host "storage.googleapis.com"
    default_scheme "https"
    path "/"
  end

  type "storage_buckets" do
    href_templates "{{.items[].id}}"

    output_path ".items[]"
    output "id" do
      body_path ".id"
    end

    output "name" do
      body_path ".name"
    end

    output "region" do
      body_path ".location"
    end

    output "storage_class" do
      body_path ".storageClass"
    end

    output "labels" do
      body_path ".labels"
    end

    output "updated" do
      body_path ".updated"
    end

    action "list" do
      verb "GET"
      path "storage/v1/b"
      field "projectId" do
        type "string"
        location "query"
        alias_for "project"
      end
    end

    polling do
      field_values do
        projectId $project_id
      end
      period 60
      action "list"
    end

    link "bucket_permission" do
      path "/bucket/{{id}}"
      type "bucket_permission"
    end

    link "bucket_size" do
      path "/bucket/{{id}}"
      type "bucket_size"
    end
  end
  
  type "bucket_permission" do
    href_templates "{{.resourceId | .[19:]}}"

    output "public_access" do
      body_path '[.bindings[].members[] | select(. == "allUsers" or . =="allAuthenticatedUsers")] | length>0'
    end

    action "list" do
      verb "GET"
      path "storage/v1/b/$bucket_name/iam"
      field 'bucket_name' do
        type 'string'
        location 'path'
      end
    end

    polling do
      field_values do
        bucket_name parent_field("id")
      end
      parent "storage_buckets"
      period 60
      action "list"
    end
  end
  
  type "bucket_size" do
    href_templates '{{[.items[].bucket] | first}}'

    output "size" do
      body_path '[.items[].size | tonumber ] | add | tostring | .+ " bytes"'
    end

    action "list" do
      verb "GET"
      path "storage/v1/b/$bucket_name/o"
      field "bucket_name" do
        type "string"
        location "path"
      end
    end

    polling do
      field_values do
        bucket_name parent_field("id")
      end
      parent "storage_buckets"
      period 60
      action "list"
    end
  end

  type "objects" do
    href_templates '{{ . | select(.kind == "storage#object") | .selfLink }}', '{{select( .items != null ) | [.items[].selfLink] | first}}'

    action "get" do
      type "objects"
      path "$href"
    end

    action "show" do
      type "objects"
      verb "GET"
      path "storage/v1/b/$bucket_name/o/$object_name?alt=json"
      field "bucket_name" do
        type "string"
        location "path"
      end

      field "object_name" do
        type "string"
        location "path"
      end
    end

    action "content" do
      type "objects"
      verb "GET"
      path "$href?alt=media"
    end

    action "list" do
      type "objects"
      verb "GET"
      path "storage/v1/b/$bucket_name/o"
      field "bucket_name" do
        type "string"
        location "path"
      end
    end

    polling do
      field_values do
        bucket_name parent_field("id")
      end
      parent "storage_buckets"
      period 60
      action "list"
    end
  end
end

resource_pool "google_cloud_storage" do
  plugin $google_cloud_storage
  parameter_values do
    project_id $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_STORAGE_SERVICE_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/cloud-platform"
      } end
      signing_key cred("GOOGLE_STORAGE_SERVICE_ACCOUNT_KEY")
    end
  end
end

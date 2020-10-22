name 'rs_azure_blob_service'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Blob Services"

info(
      provider: "Azure",
      service: "Blob Container"
    )

pagination 'azure_pagination' do
  get_page_marker do
    body_path '/EnumerationResults/NextMarker'
  end
  set_page_marker do
    query 'marker'
  end
end

parameter "storage_account" do
  type  "string"
  label "Storage Account"
end

plugin "rs_azure_blob_service" do
  short_description 'Azure Blob Services'
  long_description 'Supports polling activity for Azure Storage account with support for pagination'
  version '1.0.0'
  
  documentation_link "source" do
    label "Source"
    url "https://github.com/flexera/flexera-plugins/blob/master/azure/rs_azure_blob_service/azure_blob_services.rb"
  end

  documentation_link "readme" do
    label "ReadMe"
    url "https://github.com/flexera/flexera-plugins/blob/master/azure/rs_azure_blob_service/README.md"
  end

  parameter "storage_account" do
    type  "string"
    label "Storage Account"
    description 'Storage Account for which Blob Services are retrieved'
  end

  endpoint do
    default_host '$storage_account.blob.core.windows.net'
    default_scheme 'https'
    path '/'
  end
  
  type 'blob_services' do
    href_templates '{{/EnumerationResults/Containers/Container/Name}}'

    output_path '/EnumerationResults/Containers/Container'

    output 'name' do
      body_path 'Name'
    end
	
    output 'id' do
      body_path 'Name'
    end

    output 'public_access' do
      body_path 'Properties/PublicAccess'
    end
	
    output 'last_modified' do
      body_path 'Properties/Last-Modified'
    end
	
    output 'tags' do
      body_path 'Properties/Etag'
    end
	
    action 'list' do
      verb 'GET'
      path '/'
	  field 'version' do
        type 'string'
        location 'header'
        alias_for 'x-ms-version'
      end
	  field 'comp' do
        type 'string'
        location 'query'
        alias_for 'comp'
      end
	  field 'page_size' do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $azure_pagination  
    end

    polling do
      field_values do
	    version '2018-11-09'
		comp 'list'
        page_size '100'
      end
      period 60
    end
  end

  type "container_size" do
    
	href_templates '{{/EnumerationResults/@ContainerName}}'

    output "size" do
      body_path 'sum(/EnumerationResults/Blobs/Blob/Properties/Content-Length)'
    end
		
	action 'list' do
      verb 'GET'
      path '/$container_name'
      field "container_name" do
        type "string"
        location "path"
      end
	  field 'version' do
        type 'string'
        location 'header'
        alias_for 'x-ms-version'
      end
	  field 'comp' do
        type 'string'
        location 'query'
        alias_for 'comp'
      end
	  field 'restype' do
        type 'string'
        location 'query'
        alias_for 'restype'
      end
	  field 'page_size' do
        type 'string'
        location 'query'
        alias_for 'MaxResults'
      end
      pagination $azure_pagination  
    end
  
    polling do
      field_values do
	    container_name parent_field("name")
	    version '2018-03-28'
		comp 'list'
		restype 'container'
        page_size '100'
      end
	  parent "blob_services"
      period 60
    end
  end
end

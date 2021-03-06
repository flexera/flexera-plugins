name 'Azure AKS Service - Kubernetes Test CAT'
rs_ca_ver 20161221
short_description "Azure AKS Service  - Kubernetes Test CAT"
import "sys_log"
import "plugins/rs_azure_aks"

parameter "subscription_id" do
  like $rs_azure_aks.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_resource_group", type: "rs_cm.resource_group" do
  cloud_href "/api/clouds/3526"
  name join(["aks-rg-", last(split(@@deployment.href, "/"))])
  description join(["container resource group for ", @@deployment.name])
end

 
resource "my_k8s", type: "rs_azure_aks.aks" do
  name join(["aks", last(split(@@deployment.href, "/"))])
  resource_group @my_resource_group.name
  location "Central US"
  properties do {
  "dnsPrefix" => join(["dnsprefix-", last(split(@@deployment.href, "/"))]),
   "orchestratorProfile" => {
      "orchestratorType" =>  "Kubernetes"
    },
    "servicePrincipalProfile" => {
      "clientId" => cred("AZURE_APPLICATION_ID"),
      "secret" => cred("AZURE_APPLICATION_KEY")
    },
 
    "agentPoolProfiles" =>  [
      {
        "name" =>  "agentpools",
        "count" =>  2,
        "vmSize" =>  "Standard_DS2",
        "dnsPrefix" => join(["dnsprefix-", last(split(@@deployment.href, "/"))]),
        "storageProfile" => 'ManagedDisks',
        "osType" => 'Linux'
      }
    ],
    "diagnosticsProfile" => {
      "vmDiagnostics" => {
          "enabled" =>  "false"
      }
    },
    "linuxProfile" => {
      "adminUsername" =>  "azureuser",
      "ssh" => {
        "publicKeys" =>  [
          {
            "keyData" =>  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1CfyxgqRTbPSXpLqEa9VbvtJxEcxI1JsB/9Dw0hha4PCIGw5pX7X/Dl8UbnkbvzUuzvDQ3Ap6jZpYB4sHRTN/8fv1F9HnQ5xkDRfyH2fnZmhrihlxzwy1AvufNhGqwPEZLl8znxRG94UR2oqa1KBtVX+zvjoAdrhAsuhNcix/3VpTkeoCyEjNknl3Jy8VYCX4CH0cQpyl/gjWGmXF4YxyyLeZ4LzRfUQl2lXH/eF4h0MwZsYSJChiR1UU6FSD4+NJbJa01gLCMJmox8DwKABK/iPnulR/gsTG/HLEXTtkqIrOaIuBnNsfnq2dkOcGgXDFbTi9X0irWZow/lQcJ0M5 container"
          }
        ]
      }
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@my_resource_group,@my_k8s) return @my_resource_group,@my_k8s do
  call start_debugging()
  provision(@my_resource_group)
  provision(@my_k8s)
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

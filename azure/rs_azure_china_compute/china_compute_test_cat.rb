name 'Azure Compute Test CAT'
rs_ca_ver 20161221
short_description "Azure Compute - Test CAT"
import "sys_log"
import "azure/cloud_parameters"
import "plugins/azure_china_compute", as: "azure_compute"
import "plugins/azure_china_networking", as: "rs_azure_networking"

parameter "tenant_id" do
  like $cloud_parameters.tenant_id
end

parameter "subscription_id" do
  like $cloud_parameters.subscription_id
end

parameter "param_resource_group" do
  label "Resource Group"
  type "string"
  default "FLEXERA-POC"
end

parameter "vmSize" do
  label "VirtualMachine Sizes"
  type "string"
  allowed_values "Standard_DS1_v2"
  default "Standard_DS1_v2"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

output "vm_ids" do
  label "VM ids"
end

output "vm_sizes" do
  label "Available VM Sizes"
end

resource "azure_nic", type: "rs_azure_networking.interface" do
  name join(['linux-', last(split(@@deployment.href,"/"))])
  location "China East"
  resource_group "FLEXERA-POC"
  properties do {
    "ipConfigurations": [{
      "name": "ipconfig1",
      "properties": {
        "privateIPAllocationMethod": "Dynamic",
        "privateIPAddressVersion": "IPv4",
        "primary": true,
        "subnet": {
          "id": join(["subscriptions/", $subscription_id, "/resourceGroups/FLEXERA-POC/providers/Microsoft.Network/virtualNetworks/AADS/subnets/default"])
        }
      }
    }]
  } end
end

resource "server1", type: "azure_compute.virtualmachine" do
  name join(['win-', last(split(@@deployment.href,"/"))])
  location "China East"
  resource_group "FLEXERA-POC"
  properties do {
    "hardwareProfile": {
      "vmSize": $vmSize
    },
    "osProfile": {
      "adminUsername": "rs-admin",
      "adminPassword": "Flexera1234!",
      "secrets": [],
      "computerName": "myVM",
      "linuxConfiguration": {
        "disablePasswordAuthentication": false
      }
    },
    "storageProfile": {
      "imageReference": {
        "sku": "16.04-LTS",
        "publisher": "Canonical",
        "version": "latest",
        "offer": "UbuntuServer"
      },
      "osDisk": {
        "caching": "ReadWrite",
        "managedDisk": {
          "storageAccountType": "Premium_LRS"
        },
        "name": join(["myVMosdisk", last(split(@@deployment.href,"/"))]),
        "createOption": "FromImage"
      }
    },
    "networkProfile": {
      "networkInterfaces": [{
        "id": @azure_nic.id
      }]
    }
  } end
end

resource "my_vm_extension", type: "azure_compute.extensions" do
  name join(["easy-", last(split(@@deployment.href, "/"))])
  resource_group "FLEXERA-POC"
  location "China East"
  virtualMachineName @server1.name
  properties do {
    "publisher" => "Microsoft.OSTCExtensions",
    "type" => "CustomScriptForLinux",
    "typeHandlerVersion" => "1.5",
    "autoUpgradeMinorVersion" => true,
    "settings" => {
       "fileUris" => [ "https://s3.amazonaws.com/rightscale-services/scripts/nginx.sh" ],
       "commandToExecute" => "sh nginx.sh"
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
    $vm_ids => $vms,
    $vm_sizes => $vmss
  } end
end

operation "change_size" do
  description "changes size"
  definition "supersize_me"
end

define launch_handler($tenant_id, $subscription_id, @azure_nic, @server1, @my_vm_extension) return @server1,@my_vm_extension,$vms,$vmss do
  call start_debugging()
  provision(@azure_nic)
  provision(@server1)
  provision(@my_vm_extension)
  call stop_debugging()
end

define getSizes() return $values do
  call start_debugging()
  sub on_error: stop_debugging() do
    @vm=rs_azure_compute.virtualmachine.show(resource_group: @@deployment.name, virtualMachineName: join(["server1-", last(split(@@deployment.href, "/"))]))
    $$vmss = @vm.vmSizes()
  end
  call stop_debugging()
  call sys_log.detail("sizes:" + to_s($$vmss))
  $values=[]
  $values << "Standard_F1"
  foreach $size in $$vmss[0]["value"] do
    $values << $size["name"]
  end
end

define supersize_me(@server1,$vmSize) return @server1 do
  @vm=rs_azure_compute.virtualmachine.show(resource_group: @@deployment.name, virtualMachineName: @server1.name)
  $vm_object=to_object(@vm)
  $vm_fields=$vm_object["details"][0]
  $vm_fields["properties"]["hardwareProfile"]={}
  $vm_fields["properties"]["hardwareProfile"]["vmSize"] = $vmSize
  @vm.update($vm_fields)
  sleep(60)
  sleep_until(@server1.state == 'operational')
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
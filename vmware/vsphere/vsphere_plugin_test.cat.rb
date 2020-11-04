name "VMWare VSphere Test Cat"
rs_ca_ver 20161221
short_description "VMWare VSphere Test Cat"
import "sys_log"
import "plugins/rs_vmware_vsphere"

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_tag_category", type: "rs_vmware_vsphere.cis_tagging_category" do
  name "rs_test_tag_category"
end

resource "my_tag", type: "rs_vmware_vsphere.cis_tagging_tag" do
  name "name:predicate=value"
end
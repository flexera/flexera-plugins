name 'GKE - Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - GKE - Test CAT"
import "plugins/gke"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $gke.google_project
end

##########################
##########################
#######  Outputs  ########
##########################
##########################


##########################
##########################
####### Resources ########
##########################
##########################

resource "my_cluster", type: "gke.clusters" do
  zone "us-central1-a"
  cluster do {
    "name" => join(["rs-cluster-", last(split(@@deployment.href, "/"))]),
    "initialNodeCount" => 3,
    "initialClusterVersion" => "1.7.11-gke.1"
  } end 
end 



##########################
##########################
###### Operations ########
##########################
##########################



##########################
##########################
###### Definitions #######
##########################
##########################
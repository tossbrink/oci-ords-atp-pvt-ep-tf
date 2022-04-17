/*
  @author: tossbrink
*/
######################## GOVERNANCE/IAM Parameters ########################
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "user_ocid" {}
variable "private_key_path" {}
######################## SEC Parameters ########################
variable "ssh_public_key" {}


######################## AD Parameters ########################
variable "availability_domain_name" { default = "" }
variable "availability_domain_number" { default = 0 }
 
######################## VCN Parameters ########################
variable "VCNname" { default = "TfVcn02" }
variable "VCN-CIDR" { default = "10.0.0.0/16" }
variable "PubSubnetName" { default = "TfWebSubnet" }
variable "Webserver_PublicSubnet-CIDR" { default = "10.0.1.0/24" }
variable "PrivSubnetName" { default = "TfAdbSubnet" }
variable "ATP_PrivateSubnet-CIDR" { default = "10.0.2.0/24" }

variable "use_existing_vcn" { default = false }
variable "use_existing_nsg" { default = false }
variable "vcn_id" { default = "" } 
variable "compute_subnet_id" { default = "" }
variable "compute_nsg_id" { default = "" }
variable "ATP_subnet_id" { default = "" }
variable "ATP_nsg_id" { default = "" }

variable "dhcp_options_dp_name" { default = "TfDHCPOptions1" }
variable "nat_gateway_dp_name" { default = "TfNATGateway" }
variable "internet_gateway_dp_name" { default = "TfInternetGateway" }
variable "rtigw_dp_name" { default = "TfRTViaIGW" }
variable "rtnatgw_dp_name" { default = "TfRTViaNAT" }

variable "websubnet_dns_lable" {default = "TffkN1"}
variable "atpsubnet_dns_lable" {default = "TffkN2"}
variable "rt_destination" {default = "0.0.0.0/0"}
variable "rt_destination_type" {default = "CIDR_BLOCK"}

variable "nsg_01" {default = "TfWebNSG"}
variable "nsg_02" {default = "TfSshNSG"}
variable "nsg_03" {default = "TfAtpNSG"}


######################## COMPUTE & SHAPE Parameters ########################
variable "Shape" { default = "VM.Standard3.Flex" }

variable "Shape_flex_ocpus" { default = 1 }
variable "Shape_flex_memory" { default = 10 }

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}
variable "computeName" { default = "TfOrdsJettySrv002" }
######################## OTHER Parameters ########################
variable "ATP_tde_wallet_zip_file" { default = "tde_wallet_TfAtpPriv01.zip" } #replace file name
variable "oracle_instant_client_version" { default = "19.9" }
variable "oracle_instant_client_version_short" { default = "19.9" }

variable "identity_tag" { default = "TfAOrdsAtpPrivEp" }

variable "release" {
  description = "Architecture-TossBrink-Release"
  default     = "Development"
}

######################## ADB Parameters ########################
variable "ATP_pubdb_name" { default = "TfAtpPriv01" }
variable "ATP_password" {}
variable "ATP_database_cpu_core_count" { default = 1 }
variable "ATP_database_data_storage_size_in_tbs" { default = 1 }
variable "ATP_adb_workload" {default = "OLTP"}

variable "ATP_database_freeform_tags" {
  default = {
    TfAtpPriv01 = {"Owner" = "TfAtpPriv01"}
    #TfAtpPub01  = {"Owner" = "TfAtpPub02"}
  }
}

variable "ATP_database_license_model" { default = "LICENSE_INCLUDED" }
#
variable "ATP_free_tier" { default = true }
variable "ATP_private_endpoint" { default = true }
variable "ATP_database_db_name" { default = "TfAtpPriv01" }
variable "ATP_database_db_version" { default = "19c" }
variable "ATP_database_defined_tags_value" { default = "" }
#variable "ATP_database_display_name" { default = "TfAtpPriv01" }
variable "ATP_private_endpoint_label" { default = "AtpPrivateEp1" }

######################## Local Parameters ########################
# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Optimized3.Flex",
    "VM.Standard.A1.Flex",
    "VM.Standard.E2.1.Micro",
    "VM.Standard3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape   = contains(local.compute_flexible_shapes, var.Shape)
  availability_domain_name = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number], "name") : var.availability_domain_name
  ATP_nsg_id               = !var.use_existing_nsg ? oci_core_network_security_group.ATPSecurityGroup[0].id : var.ATP_nsg_id
  ATP_subnet_id            = !var.use_existing_vcn ? oci_core_subnet.ATPEndpointSubnet[0].id : var.ATP_subnet_id
  vcn_id                   = !var.use_existing_vcn ? oci_core_virtual_network.VCN[0].id : var.vcn_id
}

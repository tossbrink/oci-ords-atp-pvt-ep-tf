/*
  @author: tossbrink
*/
resource "oci_core_virtual_network" "VCN" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.VCN-CIDR
  dns_label      = var.VCNname
  compartment_id = var.compartment_ocid
  display_name   = var.VCNname 
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_dhcp_options" "DhcpOptions1" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN[0].id
  display_name   = var.dhcp_options_dp_name

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["example.com"]
  }
}

resource "oci_core_nat_gateway" "NATGateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = var.nat_gateway_dp_name
  vcn_id         = oci_core_virtual_network.VCN[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "InternetGateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = var.internet_gateway_dp_name
  vcn_id         = oci_core_virtual_network.VCN[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "RouteTableViaIGW" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN[0].id
  display_name   = var.rtigw_dp_name
  route_rules {
    destination       = var.rt_destination
    destination_type  = var.rt_destination_type
    network_entity_id = oci_core_internet_gateway.InternetGateway[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "RouteTableViaNAT" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN[0].id
  display_name   = var.rtnatgw_dp_name
  route_rules {
    destination       = var.rt_destination
    destination_type  = var.rt_destination_type
    network_entity_id = oci_core_nat_gateway.NATGateway[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "WebSubnet" {
  count           = !var.use_existing_vcn ? 1 : 0
  cidr_block      = var.Webserver_PublicSubnet-CIDR
  display_name    = var.PubSubnetName
  dns_label       = var.websubnet_dns_lable
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.VCN[0].id
  route_table_id  = oci_core_route_table.RouteTableViaIGW[0].id
  dhcp_options_id = oci_core_dhcp_options.DhcpOptions1[0].id
  defined_tags    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "ATPEndpointSubnet" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.ATP_PrivateSubnet-CIDR
  display_name               = var.PrivSubnetName
  dns_label                  = var.atpsubnet_dns_lable 
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.VCN[0].id
  route_table_id             = oci_core_route_table.RouteTableViaNAT[0].id
  dhcp_options_id            = oci_core_dhcp_options.DhcpOptions1[0].id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
 
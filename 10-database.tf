/*
  @author: tossbrink
*/
#Private Database
resource "oci_database_autonomous_database" "create_adb" {
    #Required
    compartment_id = var.compartment_ocid
    db_name = var.ATP_database_db_name
    #Optional
    admin_password = var.ATP_password
    cpu_core_count = var.ATP_database_cpu_core_count
    data_storage_size_in_tbs = var.ATP_database_data_storage_size_in_tbs
    db_version = var.ATP_database_db_version
    db_workload = var.ATP_adb_workload
    display_name = var.ATP_database_db_name
    #
    freeform_tags = var.ATP_database_freeform_tags.TfAtpPriv01
    license_model = var.ATP_database_license_model
    nsg_ids = !var.use_existing_nsg ? [oci_core_network_security_group.ATPSecurityGroup[0].id, oci_core_network_security_group.SSHSecurityGroup[0].id] : [var.compute_nsg_id]
    private_endpoint_label = var.ATP_private_endpoint_label
    subnet_id = local.ATP_subnet_id
    defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


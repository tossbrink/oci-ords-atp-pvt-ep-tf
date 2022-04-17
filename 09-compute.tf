/*
  @author: tossbrink
*/
# compute.tf used for redner #Ref1.1
data "template_file" "key_script" {
  template = file("${path.module}/scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

# compute.tf used for redner user_data #Ref1.0
data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered #Ref1.1
  }
}

resource "oci_core_instance" "Webserver1" {
  
  availability_domain = local.availability_domain_name # Required
  compartment_id      = var.compartment_ocid # Required
  display_name        = var.computeName
  shape               = var.Shape # Required

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.Shape_flex_memory
      ocpus         = var.Shape_flex_ocpus
    }
  }

  source_details { # Required
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

 metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
    user_data           = data.template_cloudinit_config.cloud_init.rendered #Ref1.0
  }
  
  create_vnic_details {
    subnet_id = !var.use_existing_vcn ? oci_core_subnet.WebSubnet[0].id : var.compute_subnet_id
    nsg_ids   = !var.use_existing_nsg ? [oci_core_network_security_group.WebSecurityGroup[0].id, oci_core_network_security_group.SSHSecurityGroup[0].id] : [var.compute_nsg_id]
    assign_public_ip = true
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  preserve_boot_volume = false
}

data "oci_core_vnic_attachments" "Webserver1_VNIC1_attach" {
  availability_domain = var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.Webserver1.id
}

data "oci_core_vnic" "Webserver1_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.Webserver1_VNIC1_attach.vnic_attachments.0.vnic_id
}

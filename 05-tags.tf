/*
  @author: tossbrink
*/
resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_identity_tag_namespace" "ArchitectureCenterTagNamespace" {
  provider       = oci.homeregion
  compartment_id = var.compartment_ocid
  description    = "ArchitectureTossBrink"
  name           = "ArchitectureTossBrink\\OCI-Solution-${random_id.tag.hex}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "oci_identity_tag" "ArchitectureCenterTag" {
  provider         = oci.homeregion
  description      = var.identity_tag
  name             = var.identity_tag
  tag_namespace_id = oci_identity_tag_namespace.ArchitectureCenterTagNamespace.id

  validator {
    validator_type = "ENUM"
    values         = ["Prodduction", "Development", "Testing"]
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }

}

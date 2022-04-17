/*
  @author: tossbrink
*/
output "all-availability-domains-in-your-tenancy" {
  description = "The Availabiliyt domains in your teanancy."
  value = data.oci_identity_availability_domains.ADs.availability_domains
}

output "name-of-first-availability-domain" {
  description = "The First Availabiliyt domains in your teanancy."
  value = data.oci_identity_availability_domains.ADs.availability_domains[0].name
}

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

output "webserver1_public_ip" {
  value = [data.oci_core_vnic.Webserver1_VNIC1.public_ip_address]
}



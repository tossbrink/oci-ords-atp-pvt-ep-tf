/*
  @author: tossbrink
*/
data "template_file" "sqlnet_ora_template" { #ref1
  template = file("${path.module}/scripts/sqlnet.ora")
  vars = {
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

# bootstrap for ords
data "template_file" "ords_bootstrap_template"{
  template = file("${path.module}/scripts/ords_bootstrap.sh")
  vars = {
    ATP_tde_wallet_zip_file  = var.ATP_tde_wallet_zip_file
    ATP_password = var.ATP_password
    ATP_database_db_name = var.ATP_pubdb_name
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

# Wallet
resource "oci_database_autonomous_database_wallet" "xadb_wallet" { 
    #Required
    autonomous_database_id = oci_database_autonomous_database.create_adb.id
    password = var.ATP_password #random_string.autonomous_database_wallet_password.result

    #Optional
    base64_encode_content = "true"
}

resource "null_resource" "Webserver1_ConfigMgmt" {
    depends_on = [
      oci_core_instance.Webserver1, oci_database_autonomous_database.create_adb
    ]

  # invokes a local executable after a resource is created
   provisioner "local-exec" {
      command = "echo '${oci_database_autonomous_database_wallet.xadb_wallet.content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
   }

   provisioner "local-exec" {
    command = "base64 --decode ${var.ATP_tde_wallet_zip_file}_encoded > ${var.ATP_tde_wallet_zip_file}"
   }

   provisioner "local-exec" {
    command = "rm -rf ${var.ATP_tde_wallet_zip_file}_encoded"
   }

   provisioner "file" {
      connection {
        type        = "ssh"
        user        = "opc"
        host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
        private_key = tls_private_key.public_private_key_pair.private_key_pem
        script_path = "/home/opc/myssh.sh"
        agent       = false
        timeout     = "10m"
      }
      content     = data.template_file.sqlnet_ora_template.rendered #ref1
      destination = "/home/opc/sqlnet.ora"
  }

   provisioner "file" { 
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/home/opc/${var.ATP_tde_wallet_zip_file}"
  }
  
  provisioner "file" {
    connection {
       type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/ords/ords_conf.zip"
    destination = "/home/opc/ords_conf.zip"
  }

  # create ords user
  provisioner "file" {
    connection {
       type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/scripts/create_ord_user.sql"
    destination = "/home/opc/create_ord_user.sql"
  }

  provisioner "file" {
    connection {
       type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/scripts/create_data_for_rest.sql"
    destination = "/home/opc/create_data_for_rest.sql"
  }

  provisioner "file" {
    connection {
       type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/scripts/apex_pu.xml"
    destination = "/home/opc/apex_pu.xml"
  }
  
 
   provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.ords_bootstrap_template.rendered
    destination = "/home/opc/ords_bootstrap.sh"
  }

  #configuration management install tools, bootstrap into machin
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.Webserver1_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "chmod +x /home/opc/ords_bootstrap.sh",
      "sudo /home/opc/ords_bootstrap.sh"
    ]
  }
}


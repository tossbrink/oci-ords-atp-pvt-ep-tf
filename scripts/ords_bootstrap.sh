#!/bin/bash
#/*
#  @author: tossbrink
#*/
echo '== 1. Install ords'
sudo yum install -y ords
echo '== 2. Install sqlclient'
sudo yum install -y sqlcl
sudo yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-basic-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
sudo yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-sqlplus-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
echo '== 3. Open Firewall and starting HTTPD'
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --reload
echo '== 5. Move Wallet*.zip and sqlnet.ora to oracle client /network/admin directory'
sudo cp /home/opc/${ATP_tde_wallet_zip_file} /home/oracle/${ATP_tde_wallet_zip_file}
sudo chown oracle:oinstall /home/oracle/${ATP_tde_wallet_zip_file}
sudo unzip -o /home/opc/${ATP_tde_wallet_zip_file} -d /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/
sudo cp /home/opc/sqlnet.ora /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/
echo '== 6. Move ords_config.zip to oracle account, change ownership to oracle and unzip'
sudo mv /home/opc/ords_conf.zip /opt/oracle/ords/
sudo chown oracle:oinstall /opt/oracle/ords/ords_conf.zip
sudo su - oracle -c 'unzip -q /opt/oracle/ords/ords_conf.zip -d /opt/oracle/ords/'
echo '== 7. configdir for ords'
sudo su - oracle -c 'java -jar /opt/oracle/ords/ords.war configdir /opt/oracle/ords/conf'
echo '== 8. create ords/rest users'
sudo sed -i s/{password}/${ATP_password}/g /home/opc/create_ord_user.sql
sudo sqlplus admin/${ATP_password}@${ATP_database_db_name}_high @create_ord_user.sql
echo '== 9. create rest data by connecting TOSSBRINK'
sudo sqlplus tossbrink/${ATP_password}@${ATP_database_db_name}_high @create_data_for_rest.sql
echo '== 10. Start rest service'
sudo sed -i s/{password}/${ATP_password}/g /home/opc/apex_pu.xml
sudo sed -i s/{wallet_file}/${ATP_tde_wallet_zip_file}/g /home/opc/apex_pu.xml
sudo sed -i s/{db_name}/${ATP_database_db_name}/g /home/opc/apex_pu.xml
sudo mv /home/opc/apex_pu.xml /home/oracle/apex_pu.xml
sudo chown oracle:oinstall /home/oracle/apex_pu.xml
sudo su - oracle -c 'mv /home/oracle/apex_pu.xml /opt/oracle/ords/conf/ords/conf/apex_pu.xml'
sudo su - oracle -c 'java -jar -Duser.timezone=UTC /opt/oracle/ords/ords.war standalone &'
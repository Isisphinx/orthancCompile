#!/bin/bash
orthanc="Orthanc-1.9.7"
apt update
mkdir /home/orthanc
mkdir /home/orthanc/plugin
cd /home/orthanc
wget 

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

apt install -y postgresql
sudo -u postgres createdb orthanc
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'postgres';"

cat <<EOF > /home/orthanc/$orthanc/configuration.json
{
"HttpPort": 80
,"DicomPort" : 11112
,"RemoteAccessAllowed" : true
,"AuthenticationEnabled" : true
,"RegisteredUsers" : {
    "alice" : "alicePassword"
  }
,"StorageCompression" : true
,"PostgreSQL" : {
    "EnableIndex" : true
    ,"ConnectionUri" : "postgresql://postgres:postgres@localhost:5432/orthanc"
  }
  ,"Plugins" : [
    "/home/orthanc/plugin/PostgreSQLBuild/libOrthancPostgreSQLIndex.so"
    ,"/home/orthanc/plugin/libOrthancWebViewer.so"
    ,"/home/orthanc/plugin/libOrthancTransfers.so"
  ]
}
EOF

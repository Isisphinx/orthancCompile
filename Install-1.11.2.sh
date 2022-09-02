#!/bin/bash
orthancVersion="Orthanc-1.11.2"
postgreVersion="OrthancPostgreSQL-4.0"
transfersVersion="OrthancTransfers-1.2"

mkdir /opt/Orthanc
apt update

#Orthanc
orthancSource=$orthancVersion"Source"
apt install -y build-essential unzip cmake mercurial patch uuid-dev libcurl4-openssl-dev liblua5.3-dev libgtest-dev libpng-dev libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev locales

cd /opt/Orthanc/
wget -O $orthancVersion.tar.gz https://www.orthanc-server.com/downloads/get.php?path=/orthanc/$orthancVersion.tar.gz
tar zxvf $orthancVersion.tar.gz
rm $orthancVersion.tar.gz
mv $orthancVersion $orthancSource
mkdir $orthancVersion
cd $orthancVersion

cmake ../$orthancSource/OrthancServer/ -DALLOW_DOWNLOADS=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DDCMTK_LIBRARIES=dcmjpls -DCMAKE_BUILD_TYPE=Release
make
rm -rf $orthancSource

#Postgre
postgreSource=$postgreVersion"Source"

apt install -y libpq-dev postgresql-server-dev-all postgresql

cd /opt/Orthanc/
wget -O $postgreVersion.tar.gz https://www.orthanc-server.com/downloads/get.php?path=/plugin-postgresql/$postgreVersion.tar.gz
tar zxvf $postgreVersion.tar.gz
rm $postgreVersion.tar.gz
mv $postgreVersion $postgreSource
mkdir $postgreVersion
cd $postgreVersion

cmake ../$postgreSource/PostgreSQL -DCMAKE_BUILD_TYPE=Release -DALLOW_DOWNLOADS=ON -DUSE_SYSTEM_GOOGLE_TEST=OFF -DUSE_SYSTEM_ORTHANC_SDK=OFF
make
rm -rf $postgreSource

#Transfers
transfersSource=$transfersVersion"Source"

cd /opt/Orthanc/
wget -O $transfersVersion.tar.gz https://www.orthanc-server.com/downloads/get.php?path=/plugin-transfers/$transfersVersion.tar.gz
tar zxvf $transfersVersion.tar.gz
rm $transfersVersion.tar.gz
mv $transfersVersion $transfersSource
mkdir $transfersVersion
cd $transfersVersion

cmake ../$transfersSource -DSTATIC_BUILD=ON -DCMAKE_BUILD_TYPE=Release
make
rm -rf $transfersVersion

#Config
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
sudo -u postgres createdb orthanc
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'postgres';"

cat <<EOF > /opt/Orthanc/$orthancVersion/configuration.json
{
"HttpPort": 80
,"DicomPort" : 11112
,"RemoteAccessAllowed" : true
,"AuthenticationEnabled" : true
,"RegisteredUsers" : {
    "alice" : "alicePassword"
  }
,"StorageCompression" : false
,"PostgreSQL" : {
    "EnableIndex" : true
    ,"ConnectionUri" : "postgresql://postgres:postgres@localhost:5432/orthanc"
  }
  ,"Plugins" : [
    "/opt/Orthanc/OrthancPostgreSQL-4.0/libOrthancPostgreSQLIndex.so"
    ,"/opt/Orthanc/OrthancTransfers-1.2/libOrthancTransfers.so"
  ]
}
EOF

cat <<EOF > /etc/systemd/system/orthanc.service
[Unit]
Description=Orthanc DICOM server
Documentation=man:Orthanc(1) http://www.orthanc-server.com/
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/opt/Orthanc/$orthancVersion/Orthanc /opt/Orthanc/$orthancVersion/configuration.json
[Install]
WantedBy=multi-user.target
EOF

systemctl start orthanc.service
systemctl enable orthanc.service

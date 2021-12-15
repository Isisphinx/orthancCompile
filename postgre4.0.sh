#!/bin/bash
apt install -y libpq-dev postgresql-server-dev-all

Version=”OrthancPostgreSQL-4.0”
Source=$Version”Source”

wget -O $Version.tar.gz https://www.orthanc-server.com/downloads/get.php?path=/plugin-postgresql/$Version.tar.gz
tar zxvf $Version.tar.gz
rm $Version.tar.gz
mv $Version $Source
mkdir $Version
cd $Version

cmake ../$Source/PostgreSQL -DCMAKE_BUILD_TYPE=Release -DALLOW_DOWNLOADS=ON -DUSE_SYSTEM_GOOGLE_TEST=OFF -DUSE_SYSTEM_ORTHANC_SDK=OFF
make

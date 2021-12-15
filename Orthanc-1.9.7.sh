#!/bin/bash
apt install -y build-essential unzip cmake mercurial patch uuid-dev libcurl4-openssl-dev liblua5.3-dev libgtest-dev libpng-dev libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev locales

Version="Orthanc-1.9.7"
Source=$Version”Source”

wget -O $Version.tar.gz https://www.orthanc-server.com/downloads/get.php?path=/orthanc/$Orthanc.tar.gz
tar zxvf $Version.tar.gz
rm $Version.tar.gz
mv $Version $Source
mkdir $Version
cd $Version

cmake ../$Source/OrthancServer/ -DALLOW_DOWNLOADS=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DDCMTK_LIBRARIES=dcmjpls -DCMAKE_BUILD_TYPE=Release
make
rm -rf $Source

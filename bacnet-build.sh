#!/bin/bash

if ! grep -q "VERSION_CODENAME=bullseye" /etc/os-release; then
  echo "ERROR: This script requires Debian Bullseye."
  exit 1
fi


# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install IOTECH dependencies 
apt-get install lsb-release apt-transport-https curl gnupg git make cmake
curl -fsSL https://iotech.jfrog.io/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/iotech.gpg
echo "deb [signed-by=/usr/share/keyrings/iotech.gpg] https://iotech.jfrog.io/iotech/debian-release $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/iotech.list
apt-get update
apt-get install iotech-iot-1.5-dev


# Install required dependencies
sudo apt install -y gcc cmake make libcurl4-openssl-dev libmicrohttpd-dev libyaml-dev libcbor-dev libpaho-mqtt-dev uuid-dev libhiredis-dev iotech-c-utils-dev
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin
source ~/.bashrc


# Clone and build device-sdk-c
git clone -b v2.3.0 https://github.com/edgexfoundry/device-sdk-c.git
cd device-sdk-c/
make
export CSDK_DIR=$PWD/build/release/_CPack_Packages/Linux/TGZ/csdk-2.3.0
cd /root

# Install device-sdk-c
sudo dpkg -i device-sdk-c/build/release/_CPack_Packages/Linux/TGZ/csdk-2.3.0.deb

#update .bashrc
echo "
export CSDK_DIR=/root/device-sdk-c/build/release/_CPack_Packages/Linux/TGZ/csdk-2.3.0
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin
"  >>  .bashrc
source ~/.bashrc


# Clone and build device-bacnet-c
git clone -b v2.3.1 https://github.com/edgexfoundry/device-bacnet-c.git
cd device-bacnet-c/
echo v2.3.1 > VERSION
./scripts/build.sh
cd build/release/device-bacnet-mstp/

# Run the device-bacnet-c application
./device-bacnet-c


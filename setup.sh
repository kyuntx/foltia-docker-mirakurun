#!/bin/sh

# download original image, docker import
apt -y install libguestfs-tools
wget -O - https://download.foltia.com/evaluation/foltia_ANIME_LOCKER_6114.img.xz | xz -dfc > ./images/foltia_ANIME_LOCKER_6114.img
echo "Import original foltia image to docker, this may take some time."
virt-tar-out -a ./images/foltia_ANIME_LOCKER_6114.img / - | docker import - foltia:6.1.14
rm ./images/foltia_ANIME_LOCKER_6114.img

# download updater
wget -P ./updater/ https://aniloc.foltia.com/firmware/bin/foltia_ANIME_LOCKER_6115_updater.tar.gz
wget -P ./updater/ https://aniloc.foltia.com/firmware/bin/foltia_ANIME_LOCKER_6116_updater.tar.gz

# download neroAAcEnc
wget -P ./neroAacEnc/ https://aniloc.foltia.com/mirror/ftp6.nero.com/tools/NeroAACCodec-1.5.1.zip
unzip ./neroAacEnc/NeroAACCodec-1.5.1.zip -d ./neroAacEnc/
chmod 755 ./neroAacEnc/linux/neroAacEnc

# build docker image
docker-compose build


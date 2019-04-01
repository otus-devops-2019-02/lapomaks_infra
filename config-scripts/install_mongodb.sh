#!/bin/bash
echo 'Add MongoDb Repository'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

echo 'Install MongoDb'
sudo apt -y update
sudo apt -y upgrade
sudo apt install -y mongodb-org

echo 'Start MongoDb and add it to the autostart'
sudo systemctl start mongod
sudo systemctl enable mongod

echo 'MongoDb installation and launch complete'


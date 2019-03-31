#!/bin/bash
echo 'Update package index and install Ruby, Bundler, MongoDb'

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

sudo apt -y update
sudo apt -y upgrade

sudo apt install -y ruby-full ruby-bundler build-essential mongodb-org

echo 'Start MongoDb and add it to the autostart'
sudo systemctl start mongod
sudo systemctl enable mongod

echo 'Download app and run it'
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d


#!/bin/bash
echo 'Download testapp'
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
echo 'Launch testapp'
puma -d


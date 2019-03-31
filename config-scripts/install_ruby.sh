#!/bin/bash
echo 'Install Ruby and Bundler'
sudo apt -y update
sudo apt -y upgrade
sudo apt install -y ruby-full ruby-bundler build-essential
echo 'Ruby and Bundler install complete'


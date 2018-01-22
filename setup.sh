#!/bin/bash

# Use rvm to install ruby stable release
echo "We use rvm to install and configure ruby"

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable --ruby

echo "Sourcing the rvm scripts"
source /usr/local/rvm/scripts/rvm

echo "Adding the rvm scripts to bashrc, so to use rvm as default"
echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

echo "ruby and all other pre-requisite packages have been installed."
echo "Will install the required ruby gems now."
gem install rest-client
gem install json
gem install terminal-table
echo "The Setup is complete!"

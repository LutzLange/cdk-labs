#!/bin/bash
#
# test Lab Setup with ansible an Mac OS
#  Open ToDo Ansibleize
#

# kick off install of CMDLine dev tools
sudo xcode-select --install

# Accept License agreement for xcode
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# prefered way to install ansible on MacOS is pip
pip &>/dev/null || sudo easy_install pip

# install ansible
ansible --version &>/dev/null || sudo pip install ansible

# Clone the repo
test -d ~/git || mkdir ~/git
test -d ~/git/cdk-labs || { cd ~/git; git clone https://github.com/LutzLange/cdk-labs.git; }

# Create bin folder
test -d ~/bin || mkdir ~/bin

# extend PATH
echo ‘export PATH=$PATH:$HOME/bin’ >> ~/.bash_profile

# Get CDK (ToDo official CDK when released)
wget http://people.redhat.com/~llange/cdkmac -O ~/bin/cdk

# Install homebrew
brew --version || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install 
brew list docker-machine-driver-xhyve || brew install docker-machine-driver-xhyve



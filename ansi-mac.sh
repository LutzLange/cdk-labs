#!/bin/bash
#
# test Lab Setup with ansible an Mac OS
#  Open ToDo Ansibleize
#

# kick off install of CMDLine dev tools
echo "Installing XCode Developer Toolset"
sudo xcode-select --install

# Accept License agreement for xcode
echo "Accepting XCode License Agreement"
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# prefered way to install ansible on MacOS is pip
echo "Installing Pip for Ansible"
pip &>/dev/null || sudo easy_install pip

# install ansible
echo "Installing Ansible"
ansible --version &>/dev/null || sudo pip install ansible

# Clone the repo
echo "Clone Lab Repo"
test -d ~/git && echo "~/git is already therer" || mkdir ~/git
test -d ~/git/cdk-labs && echo "cdk-labs is already checked out"|| { cd ~/git; git clone https://github.com/LutzLange/cdk-labs.git; }

# Create bin folder
test -d ~/bin || mkdir ~/bin

# extend PATH
echo ‘export PATH=$PATH:$HOME/bin’ >> ~/.bash_profile

# Get CDK (ToDo official CDK when released)
echo "Getting latest CDK"
wget http://people.redhat.com/~llange/cdkmac -O ~/bin/cdk

# Install homebrew
echo "Checking / Installing homebrew"
brew --version &>/dev/null && echo "homebrew was installed" || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install 
echo "Installing docker-machine-driver-xhyve"
brew list docker-machine-driver-xhyve &>/dev/null && echo "xhyve was installed" || brew install docker-machine-driver-xhyve



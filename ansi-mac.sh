#!/bin/bash
#
# test Lab Setup with ansible an Mac OS
#

# kick off install of CMDLine dev tools
sudo xcode-select --install

# Accept License agreement for xcode
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# prefered way to install ansible on MacOS is pip
pip &>/dev/null || sudo easy_install pip

# install ansible
ansible --version &>/dev/null || sudo pip install ansible

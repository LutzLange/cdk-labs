#!/bin/bash
#
# test Lab Setup with ansible an Mac OS
#  Convert to Ansible?
#

cat <<ENDMESSAGE
You are running the OpenShift CDK Lab Installer for MacOS. The following actions will be taken :

1. Install XCode Developer Toolset for git usage
2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs
3. Create ~/bin and extend your PATH to include ~/bin
4. Get the latest CDK ( currently nightly buids for 3.1 ) and put it in ~/bin
5. Install Homebrew
6. Install docker-machine-driver-xhyve
7. Install olab command in ~/bin

You will need to enter your password for prviledge actions.

ENDMESSAGE

read -p "Do you want to proceed ? (Y/N)" ANSWER
test $ANSWER != Y && { echo "Found \"$ANSWER\" expecting \"Y\" installation averted"; exit 1 ; }

STEP=0

# kick off install of CMDLine dev tools
echo "1. Installing XCode Developer Toolset" 
sudo xcode-select --install

# Accept License agreement for xcode
echo "   Accepting XCode License Agreement"
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# prefered way to install ansible on MacOS is pip
#echo "Installing Pip for Ansible"
#pip &>/dev/null || sudo easy_install pip

# install ansible
#echo "Installing Ansible"
#ansible --version &>/dev/null || sudo pip install ansible

# Clone / update the repo
echo "2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs"
test -d ~/git && echo "~/git is already therer" || mkdir ~/git
if test -d ~/git/cdk-labs then
       echo "cdk-labs is already checked out, updating cdk-labs instead"
       cd ~/git; git pull
       cd
else
       cd ~/git; git clone https://github.com/LutzLange/cdk-labs.git
fi

# Create bin folder
echo "3. Create ~/bin and extend your PATH to include ~/bin"
test -d ~/bin && echo "~/bin was there already" || mkdir ~/bin

# extend PATH if required
{ echo $PATH | grep -q $HOME/bin; } || echo ‘export PATH=$PATH:$HOME/bin’ >> ~/.bash_profile

# Get CDK (ToDo official CDK when released) 
# get this every time
echo "4. Getting latest CDK - this can be a slow Download of ~400MB"
curl http://people.redhat.com/~llange/cdkmac -O ~/bin/cdk

# Install homebrew
echo "5. Checking / Installing homebrew"
brew --version &>/dev/null && echo "homebrew was installed" || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install docker-machine-driver-xhyve
echo "6. Installing docker-machine-driver-xhyve"
brew list docker-machine-driver-xhyve &>/dev/null && echo "xhyve was installed" || brew install docker-machine-driver-xhyve

# Install the olab Command in ~/bin
echo "7. Installing olab Script"
cp ~/git/cdk-labs/olab ~/bin

# You are ready to roll now
cat <<ENDMESSAGE

You are ready to check your environment and start the OpenShift environment.
You will have all the necessary tools installed now. 

Check your environment with : $ cdk version
Build or reset your lab environment with : $ olab

NOTE : you will need a fast internet connection to download docker images
NOTE2 : 16GB RAM are currently required 
ENDMESSAGE



#
# Enable add ons
# 
ADDONS="registry-console cfme"

cd ~/git/cdk-labs/

cdk config set memory 12288 
cdk config set disk-size 40g

for ADDON in $ADDONS
do
	cdk addons install $ADDON
	cdk addons enable $ADDON
done	


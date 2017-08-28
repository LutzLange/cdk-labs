# cdk-labs
OpenShift-Lab Setup

This will set up a CDK that is ready for the OpenShift-Labs.
This all in one OpenShift has the following additional features activated :

There are currently 3 Lab Profiles that can be selected with -l Option.

Lab 1 :

* CDK 
* Registry Console

Lab 2 : 

* CDK 
* Registry Console
* CloudForms
* Metric Stack

Lab 3 : 

* CDK 
* Registry-Console
* Service Catalog
* Ansible Service Broker

------------------------------------------------------------------

Run this on MacOS as regular user :

        $ bash <(curl -s https://raw.githubusercontent.com/LutzLange/cdk-labs/master/install-on-mac.sh)

Run this on Linux ( Fedora ) as regular User :

        $ bash <(curl -s https://raw.githubusercontent.com/LutzLange/cdk-labs/master/install-on-linux.sh)


You can setup each of the labs with :

				$ olab -l X

Please always use the *cdk* shorthand to get the right minishift :

				$ cdk console

# cdk-labs
OpenShift-Lab Setup

This will set up a CDK that is ready for the OpenShift-Labs.
This all in one OpenShift has the following additional features activated :

There are currently 3 Lab Profiles that can be selected with -l Option.

Lab 1 :

* CDK 3.1.0 Release Version
* Registry Console

Lab 2 : 

* CDK 3.1.0 Release Version
* Registry Console
* CloudForms
* Metric Stack

Lab 3 : ( only with $ olab -d -l3  )

* CDK 3.1+ Devel Build 
* Registry-Console
* Service Catalog

------------------------------------------------------------------

Run this on MacOS as regular user :

        $ bash <(curl -s https://raw.githubusercontent.com/LutzLange/cdk-labs/master/install-on-mac.sh)

Run this on Linux ( Fedora ) as regular User :

        $ bash <(curl -s https://raw.githubusercontent.com/LutzLange/cdk-labs/master/install-on-linux.sh)

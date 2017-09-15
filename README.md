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

Please always use the **cdk** shorthand to get the right minishift :

        $ cdk version
        minishift v1.4.1+e65bd06
        CDK v3.0.0-17082017-1

To open your default browser to the OpenShift WebUI call :

        $ cdk console

To update your local cdk to the latest available version do :

        $ cdk update

Starting and Stoping your current lab Setup is as easy as :

        $ cdk stop

        $ cdk start

You might want to start a new shell or source ~/.bashrc to get the alias to the "CDK" oc working.

        $ oc version
    
        $ source ~/.bashrc

        $ oc version
          oc v3.6.173.0.5
          kubernetes v1.6.1+5115d708d7
          ...


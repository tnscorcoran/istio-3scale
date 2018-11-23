# Red Hat 3scale and Istio demo

## Prerequisites
The steps below assume you have Openshift installed. If not, follow these instructions:
[Installing Openshift](https://docs.openshift.com/container-platform/3.11/install/running_install.html)



1 - Login to your RHEL box and execute initialisations
==================================================================================================

In this demo, we assume you are using RHPDS. Should you prefer to install the components yourself, follow the steps in ./step-1-setup-apps.sh

If following the RHPDS route, order the 3scale Istio demo on that system. You will be issued with a GUID identifying your cluster
SSH into the cluster box as follows 

	ssh -i ~/.ssh/your_private_key_name {$username}@bastion.{$GUID}.openshift.opentlc.com

	git clone https://github.com/tnscorcoran/istio-3scale.git

	cd istio-3scale

Change the permissions on the bash scripts that will be used to setup the demos.



***TODO ADD MORE*** 

	chmod +x step-1-setup-apps.sh
	chmod +x step-2-setup-vars.sh
	chmod +x step-3-output-urls-creds.sh
	
	
	chmod +x step-1-setup-apps.sh
	chmod +x step-1-setup-apps.sh
	chmod +x step-1-setup-apps.sh
	chmod +x step-1-setup-apps.sh
	chmod +x 2-setup-vars.sh


Setup your environment variables

	sh step-2-setup-vars.sh

Apply these changes to your current terminal 

	source ~/.bashrc
In a browser, login to Openshift and 3scale using the URLs and credentials output on executing this command. Also in a browser, test the naked catalog route.

	sh step-3-output-urls-creds.sh

Now you're ready to make some manual configurations on the 3scale web interface. Follow steps between *2.2.1. Define Catalog Service* and *2.2.3. Create Application* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html)












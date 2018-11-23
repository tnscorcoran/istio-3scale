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
	chmod +x step-2-setup-vars-routes.sh
	chmod +x step-3-output-urls-creds.sh
	chmod +x step-4-output-3scale-urls.sh
	chmod +x step-5-inject-istio-to-apicast.sh
	chmod +x step-6-configure-istio-ingress-gateway.sh
	










Setup your environment variables and apply these changes to your current terminal

	sh step-2-setup-vars-routes.sh
	source ~/.bashrc

In a browser, login to Openshift and 3scale using the URLs and credentials output on executing this command. Also in a browser, test the naked catalog route.

	sh step-3-output-urls-creds.sh


2 - Test out current Non-Istio API Gateway (Apicast
==================================================================================================


Now you're ready to make some manual configurations on the 3scale web interface. Follow steps between *2.2.1. Define Catalog Service* and *2.2.3. Create Application* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html). In those steps you
 - Create a 3scale Service
 - Create an Application Plan
 - Create an Application

Copy your new User Key, in my case 1d5587f40ab92dea4434083a676b02ab.

Add it as an environment variable, substituting your key for mine:

	echo "export CATALOG_USER_KEY=1d5587f40ab92dea4434083a676b02ab" >> ~/.bashrc
	source ~/.bashrc

Execute this script and note the 3 URLs it outputs 

	sh step-4-output-3scale-urls.sh

Follow the steps including inserting these 3 URLs in *2.2.4. Service Integration* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html)

Delete pods as using the next command. Wait for them to come back up. This will sync your Service Integration changes to the APICast gateway.
	
	for i in `oc get pod -n $GW_PROJECT | grep "apicast" | awk '{print $1}'`; do oc delete pod $i; done
	
Ensure your user key is till available and test out your managed API

	echo $CATALOG_USER_KEY
	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"` 


3 - Apply Istio to Apicast
==================================================================================================
Apply Istio to Apicast using this script
	
	sh step-5-inject-istio-to-apicast.sh

Wait until developer-prod-apicast-istio is ready with 2 containers running (2/2)
	oc get pods
	
Test out your Istio Enabled API Gateway. Run this curl a few times in quick succession

	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -n $GW_PROJECT -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"`

	 	
4 - Configure Istio Ingress Gateway
==================================================================================================

Apply the configuration and source it so variables are available in your current terminal

	sh step-6-configure-istio-ingress-gateway.sh
	source ~/.bashrc

Test it out
	curl -v \
       -HHost:$CATALOG_API_GW_HOST \
       http://$INGRESS_HOST:$INGRESS_PORT/products?user_key=$CATALOG_USER_KEY		





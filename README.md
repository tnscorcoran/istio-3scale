# Red Hat 3scale and Istio demo

## Prerequisites
The steps below assume you have Openshift installed. If not, follow these instructions:
[Installing Openshift](https://docs.openshift.com/container-platform/3.11/install/running_install.html)



## 1 - Login to your RHEL box and execute initialisations
==============================================================

This document describes a fast way to implement excellent the Istio 3scale tutorials available at [Opentlc](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/). We recommend you follow the entire labs - and just use this as a fast way to recreate the demos at a later stage.

For these demos, we assume you are using RHPDS. Should you prefer to install the components yourself, follow the steps in ./step-1-setup-apps.sh

If following the RHPDS route, order the 3scale Istio demo on that system. After several minutes, you'll get an email with a GUID identifying your cluster. 
SSH into the cluster box as follows, clone this repo and change into its directory:

	ssh -i ~/.ssh/your_private_key_name {$rhpds-username}@bastion.{$GUID}.openshift.opentlc.com
	git clone https://github.com/tnscorcoran/istio-3scale.git

	cd istio-3scale


Setup your environment variables and apply these changes to your current terminal

	sh step-02-setup-vars-routes.sh
	source ~/.bashrc

In a browser, login to Openshift and 3scale using the URLs and credentials output on executing this command. Also in a browser, test the naked catalog route it outputs:

	sh step-03-output-urls-creds.sh


## 2 - Test out current Non-Istio API Gateway (Apicast
==========================================================


Now you're ready to make some manual configurations on the 3scale web interface. Follow steps between *2.2.1. Define Catalog Service* and *2.2.3. Create Application* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html). In those steps you
 - Create a 3scale Service
 - Create an Application Plan
 - Create an Application

Copy your new User Key, in my case 9ae7ef94e736123543e74dd53ee67cd0.

Add it as an environment variable, substituting your key for mine:

	echo "export CATALOG_USER_KEY=c8f13334f9c9b1c3f58153e69a69c62a" >> ~/.bashrc
	source ~/.bashrc

Execute this script and note the 3 URLs it outputs 

	sh step-04-output-3scale-urls.sh

Follow the steps including inserting these 3 URLs in *2.2.4. Service Integration* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html)

Delete pods as using the next command. This will sync your Service Integration changes to the APICast gateway. 
Wait for them to come back up. You'll know they're up when both *stage-apicast-xxxx* and *prod-apicast-xxxx* both show 1/1 containers running.

	
	oc project $GW_PROJECT 
	for i in `oc get pod -n $GW_PROJECT | grep "apicast" | awk '{print $1}'`; do oc delete pod $i; done
	oc get pods -w
	
Cancel from watching your pods, ensure your user key is still available and test out your managed API

	CTRL+C
	echo $CATALOG_USER_KEY
	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"` 

Now you have 3scale fully functioning in its conventional manner - without Istio. On your 3scale web interface, navigate to Analytics -> catalog_service.
Every call you make to the API via the curl is reported and shows up on this Analytics screen.
Now it's time to start applying Istio configuration.


## 3 - Apply Istio to Apicast
================================
Apply Istio to Apicast using this script
	
	sh step-05-inject-istio-to-apicast.sh

Wait until *developer-prod-apicast-istio-xxxxx* is ready with 2 containers running (2/2)

	oc get pods -w
	
Cancel from watching your pods, test out your Istio Enabled API Gateway. Run this curl a few times in quick succession

	CTRL+C
	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -n $GW_PROJECT -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"`


Delete Apicast project - to preserve resources

	oc delete project $GW_PROJECT --as=system:admin  


	 	
## 4 - 3scale Mixer Adapter
=============================

####  4.1 Istio Ingress Gateway without 3scale
By delegating access policies to the 3scale API Manager, it enables rate limits and acccess policies to be configured in a non-yaml based way as Istio currently requires.

By using the 3scale Mixer Adapter, we have been able to decommission our APIcast gateway and use Istio Ingress gateway to make the authorise and report calls to the 3scale API Manager. 

We will first hook our Istio Ingress Gateway to our Catalog Service without 3scale in the picture.

Apply the configuration

	sh step-09-configure-ingress-no-3scale.sh
	
Wait until Istio Policy, which was purged, is back

	oc get pods -n istio-system | grep istio-policy -w

Wait till all Istio pods are available then test out the API with a POST

	CTRL+C
	curl -v -X POST -H "Content-Type: application/json" `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})""`/product/ -d '{
	  "itemId" : "822222",
	  "name" : "Oculus Rift 2",
	  "desc" : "Oculus Rift 2",
	  "price" : 102.0
	}'
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/product/822222"`
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products"`

####  4.2 Applying 3scale Mixer to Istio Ingress Gateway 

Now we insert the 3scale Istio Mixer. Run this script

	sh step-10-add-3scale-mixer-to-ingress-1.sh

Wait till this completes before proceeding -  i.e. has 2/2 containers
	
	oc get pods -n istio-system | grep 3scale-istio-adapter


On your 3scale Web interface, Go to choose the APIs menu. Make a note of your catalog_service API's ID, likely 4 which we'll refer to as *<your catalog service Id>*.

Execute the following:

	export CATALOG_SERVICE_ID=<your catalog service Id>

Inject 3scale handler into Istio Mixer Adapter:
	
	sh step-11-add-3scale-mixer-to-ingress-2.sh
	
Verify your handler exists
	
	oc get handler -n istio-system --as=system:admin -o yaml


Verify your handler is behaving properly and authenticating. This first call should fail and the second, with a user key should pass.
	

	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products"`
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"`


Besides the 3scale Traffic Analytics shown above, Istio gives you extra visualisation tools - we're going to look at 2 - Jaeger and Grafana.

	sh step-x-output-visualisation-tool-urls.sh

Visit Jaeger - ingress gateway. See the spans


Congratulations, you've successfully integrated 3scale API Management into your Istio Service Mesh and used Istio's superb visualization tools!





	

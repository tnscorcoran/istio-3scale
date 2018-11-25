# Red Hat 3scale and Istio demo

## Prerequisites
The steps below assume you have Openshift installed. If not, follow these instructions:
[Installing Openshift](https://docs.openshift.com/container-platform/3.11/install/running_install.html)



1 - Login to your RHEL box and execute initialisations
==================================================================================================

This document describes a fast way to implement excellent the Istio 3scale tutorials avai;able at [Opentlc](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/). We recommend you follow the entire labs - and just use this as a fast way to recreate the demos at a later stage.

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
	chmod +x step-7-tracing-on-gateway.sh
	chmod +x step-8-tracing-on-api-backend.sh
	chmod +x step-9-configure-ingress-no-3scale.sh
	chmod +x step-10-add-3scale-mixer-to-ingress-1.sh
	chmod +x step-11-add-3scale-mixer-to-ingress-2.sh







Setup your environment variables and apply these changes to your current terminal

	sh step-02-setup-vars-routes.sh
	source ~/.bashrc

In a browser, login to Openshift and 3scale using the URLs and credentials output on executing this command. Also in a browser, test the naked catalog route.

	sh step-03-output-urls-creds.sh


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

	sh step-04-output-3scale-urls.sh

Follow the steps including inserting these 3 URLs in *2.2.4. Service Integration* on the [longer instructions](http://www.opentlc.com/rhte/rhte_lab_04_api_mgmt_and_service_mesh/LabInstructionsFiles/01_2_api_mgmt_service_mesh_Lab.html)

Delete pods as using the next command. Wait for them to come back up. This will sync your Service Integration changes to the APICast gateway.
	
	for i in `oc get pod -n $GW_PROJECT | grep "apicast" | awk '{print $1}'`; do oc delete pod $i; done
	
Ensure your user key is till available and test out your managed API

	echo $CATALOG_USER_KEY
	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"` 


3 - Apply Istio to Apicast
==================================================================================================
Apply Istio to Apicast using this script
	
	sh step-05-inject-istio-to-apicast.sh

Wait until developer-prod-apicast-istio is ready with 2 containers running (2/2)
	oc get pods
	
Test out your Istio Enabled API Gateway. Run this curl a few times in quick succession

	curl -v -k `echo "https://"$(oc get route/catalog-prod-apicast-$OCP_USERNAME -n $GW_PROJECT -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"`

	 	
4 - Configure Istio Ingress Gateway
==================================================================================================

Apply the configuration and source it so variables are available in your current terminal

	sh step-06-configure-istio-ingress-gateway.sh
	source ~/.bashrc

Test it out
	
	curl -v -HHost:$CATALOG_API_GW_HOST http://$INGRESS_HOST:$INGRESS_PORT/products?user_key=$CATALOG_USER_KEY		

	 	
5 - Apicast Gateway - Istio enabled
==================================================================================================

Apply the configuration and source it so variables are available in your current terminal

	sh step-07-tracing-on-gateway.sh

Wait for *developer-prod-apicast-istio* to start and finish re-deploying - either by watching it on screen or *oc get pods -w*
When that's done, verify the existence of the libraries *ngx_http_opentracing_module.so* and *libjaegertracing.so* on executing these commands

	oc rsh `oc get pod | grep "apicast-istio" | awk '{print $1}'` ls -l /usr/local/openresty/nginx/modules/ngx_http_opentracing_module.so 
	oc rsh `oc get pod | grep "apicast-istio" | awk '{print $1}'` ls -l /opt/app-root/lib/libjaegertracing.so.0

	 
	 	
6 - Jaeger UI
==================================================================================================


Generate some traffic - calling this a number of times
	
	curl -v -HHost:$CATALOG_API_GW_HOST http://$INGRESS_HOST:$INGRESS_PORT/products?user_key=$CATALOG_USER_KEY

Identify the URL for your Jaeger Distributed Tracing 
	
	echo -en "\n\nhttp://"$(oc get route/tracing -o template --template {{.spec.host}} -n istio-system)"\n\n"
	
Navigate to the above URL, choose developer-prod-apicast, drill in, choose a span and click on it. You can see the constituent parts making up the entire latency of the request.

	 	
7 - Catalog Service - Istio enabled
==================================================================================================

We need to add tracing capabilities to our API backend in order to gain full visibility into the latencies in any given request.	
Apply the configuration:

	sh step-08-tracing-on-api-backend.sh

Ensure these ENV vars are set on your system:

	echo $CATALOG_USER_KEY
	echo $CATALOG_API_GW_HOST	

Generate some load by running this several times

	curl -v -HHost:$CATALOG_API_GW_HOST http://$INGRESS_HOST:$INGRESS_PORT/products?user_key=$CATALOG_USER_KEY		


	 	
7 - 3scale Mixer Adapter
==================================================================================================

####  7.1 Istio Ingress Gateway without 3scale
By delegating access policies to the 3scale API Manager, it enables rate limits and acccess policies to be configured in a non-yaml based way as Istio currently requires.

By using the 3scale Mixer Adapter, we can decommission our APIcast gateway and use Istio Ingress gateway to make the authorise and report calls to the 3scale API Manager. 

We will first hook our Istio Ingress Gateway to our Catalog Service without 3scale in the picture.

Apply the configuration

	sh step-09-configure-ingress-no-3scale.sh
	
Wait until Istio Pilot, which was purged, is back

	oc get pods -n istio-system | grep istio-adapter

Wait till all Istio pods are available then test out the API with a POST



	curl -v -X POST -H "Content-Type: application/json" `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})""`/product/ -d '{
	  "itemId" : "822222",
	  "name" : "Oculus Rift 2",
	  "desc" : "Oculus Rift 2",
	  "price" : 102.0
	}'
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/product/822222"`
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products"`

####  7.2 Applying 3scale Mixer to Istio Ingress Gateway 

Now we insert the 3scale Istio Mixer. Run this script

	sh step-10-add-3scale-mixer-to-ingress.sh

Wait till this completes before proceeding -  i.e. has 2/2 containers
	
	oc get pods -n istio-system | grep 3scale-istio-adapter


On your 3scale Web interface, Go to choose the APIs menu. Make a note of your catalog_service API's ID, likely 4 wiich we'll refer to as *<your catalog service Id>*.

Execute the following:

	export CATALOG_SERVICE_ID=<your catalog service Id>

Inject 3scale handler into Istio Mixer Adapter:
	
	step-11-add-3scale-mixer-to-ingress-2.sh
	
Verify your handler exists
	
	oc get handler -n istio-system --as=system:admin -o yaml


Verify your handler is behaving properly and authenticating. This first call should fail and the second, with a user key should pass.
	

	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products"`
	curl -v `echo "http://"$(oc get route istio-ingressgateway -n istio-system -o template --template {{.spec.host}})"/products?user_key=$CATALOG_USER_KEY"`


Congratulations, you've successfully integrated 3scale API Management into your Istio Service Mesh!





	

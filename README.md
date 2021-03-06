# 3scale Istio Mixer Adapter
The overlap between classic API Management and Service Mesh is an interesting one. On the face of it, they provide competing capabilities - i.e. control and visibility into API traffic. Some even go so far as to say Service Mesh will be the death of API Management. We take a different stance on this, i.e. they offer complementary capabilities. Broadly speaking API Management adds business value to API traffic flowing into the mesh - so called _north-south_ traffic. Service Mesh is great for network level control especially for service to service communication, so called _east-west_ communication. What we offer and demo here is a bridge - between API Management and Service - allowing simultaneous usilisation of both in a seamless manner on the same OpenShift infrastructure.


## In this demo we 
- setup 3scale on OpenShift
- setup 3scale enabled Red Hat Service Mesh on OpenShift
- setup a simple application using several Microservices, the [Bookinfo example] (https://istio.io/latest/docs/examples/bookinfo/) taken from the upstream Istio site.
- apply service mesh control to Bookinfo
- apply 3scale API Management to Bookinfo through the [3scale Istio Adapter](https://docs.openshift.com/container-platform/4.4/service_mesh/threescale_adapter/threescale-adapter.html)

Let's get started.

----------------------------------------------------------------------------------------------------

## Setup 3scale on OpenShift

First let's install 3scale 2.9 on OpenShift. There are various options around 
- operator or template
- storage

For simplicity, I'll be using the 3scale operator and S3 for storage. I will provide requisite instructions to do this on this README, but for more details see [deploying-threescale-using-the-operator](https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.9/html/installing_3scale/install-threescale-on-openshift-guide#deploying-threescale-using-the-operator) 
### Pre-requisites
- in my case, an S3 implemenation. I'll use Amazon S3.
- in my case, I'll use the Red Hat productised 3scale, for which you'll need an account at [https://access.redhat.com](https://access.redhat.com/) to pull the supported, productised images. You can alternatively use the Community operator for which no Red Hat credentials are required.
- an OpenShift 4 cluster - in my case 4.4 with Administrative access.
- the _oc_ client installed locally (e.g. on your laptop) logged in as an Administrator to OpenShift.
- this repo cloned - and _cd_ into it.

Setup this environment variable to be the home of this repo on your laptop.
```
export REPO_HOME=`pwd`
```

### 3scale setup instructions
Execute the following
```
oc new-project 3scale
```
Modify $REPO_HOME/3scale-setup/secret-s3.yaml with your actuals under _stringData_ and execute:
```
oc apply -f $REPO_HOME/3scale-setup/secret-s3.yaml
```
For more on S3 for 3scale storage see [S3 3scale storage](https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.9/html/installing_3scale/install-threescale-on-openshift-guide#amazon_simple_storage_service_3scale_emphasis_filestorage_emphasis_installation)


Create a secret using your [https://access.redhat.com](https://access.redhat.com/) credentials
```
oc create secret docker-registry threescale-registry-auth \
--docker-server=registry.redhat.io \
--docker-username="yourusername" \
--docker-password="yourpassword"
```

On the OpenShift web console, select the 3scale project. Navigate to _Operators->Operator Hub_. Search for _3scale_ and select the _Red Hat Integration - 3scale_ operator

![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/2-3scale-operator.png)

Install this operator, going with the defaults on the next screen.
![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/3-install-3scale-operator.png)

Your display will change to _Installed Operators_. A couple of minutes later the staus should be _Succeeded_.

Select the _Red Hat Integration - 3scale_ operator.
![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/4-installed-3scale-operator.png)

Click _Create Instance_ on the _API Manager_ box. You need to overwrite the yaml that's on the screen. Overwrite with your modified __REPO_HOME/3scale-setup/threescale.yaml__ . You'll just need to modify what's highlighted - which you can get in the address on your brower tab that's logged into OpenShift:
![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/5-threescale.yaml.png)

Copy it in, overwriting what's there and Click _Create_. Then navigate to _Workloads->Pods_. A few minutes later all pods should be Running and 1/1 or 3/3 under Ready.

Now you need to retrieve your credentials for 3scale. Go to _Workloads->Secrets_. Open the _system-seed_ secret, click _Reveal Values_ on the right and see your ADMIN_PASSWORD. Your ADMIN_USER will also be needed but it will be _admin_. Keep note of both.
![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/6-reveal-system-seed-secret.png)

Now time to open the 3scale Admin console. Go to _Networking->Routes_ and open the _zync-3scale-provider-xxxxxxx_ Route. 
![](https://github.com/tnscorcoran/3scale-soap-2-rest/blob/master/_images/7-3scale-admin-route.png)

Use your ADMIN_USER and ADMIN_PASSWORD credentials from the previous step and log in.

----------------------------------------------------------------------------------------------------

## Setup [Bookinfo sample application](https://istio.io/latest/docs/examples/bookinfo/) on OpenShift

First we setup the OpenShift Service Mesh through the Service Mesh Operator.

Log into your OpenShift cluster as administrator - both on the terminal using *oc* and web interfaces.
We use Kubernetes operators to install the service mesh. Provisioning of Operators requires admin access.
Consumption of operators - typically by developers does not. But for speed we'll use 
the same admin user for both provisioning and use.

We need to install 4 Operators - from the OpenShift Operator Hub. Navigate to the OpenShift Operator Hub:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/1-open-shift-operatorhub.png)

We'll install 4 operators. The first 3 support the main one, the *Red Hat OpenShift Service Mesh Operator* 
- Elasticsearch
- Jaeger - for distributed tracing
- Kiali - for Service Mesh topology visualisation
- Red Hat OpenShift Service Mesh Operator

Find each one in the Operator Hub. Click into each and select Install. Choose Cluster scope and Automatic approval for each of the 4 operators - as shown here for Elasticsearch:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/1-operator-subscription.png)

After a few minutes the operators will be installed. They'll appear as follows:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/2-installed-operators.png)

Next you create a Service Mesh from the Service Mesh operator. Create a project (namespace) called *istio-system*
to hold the Service Mesh application. With *istio-system* selected, click into the Red Hat OpenSHift Service Mesh Operator. Then create a new *Istio Service Mesh Control Plane* in my namespace *istio-system* as shown:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/3-install-control-plane.png)

There are various tunables here on screen - regarding the various components of Service Mesh. Stick with the defaults apart from the following 
- make this entry to enable the 3scale adapter: 
```
  threeScale:
    enabled: true
```
Note the level of indentation - _threescale_ is a sibling of _istio_ as shown:
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/1-smControlPlane-yaml.png)

More [optional values for this yaml here](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_install/customizing-installation-ossm.html#ossm-cr-threescale_customizing-installation-ossm)

Click _Create_

A short time later, the Service Mesh application and its components are installed. You can verify it on screen 
or in the command line as shown:
```
oc project istio-system
oc get pods -w
```
Note 3scale-istio-adapter-xxxxxxx is one of the pods. As soon as all are ready and running, you can continue. 

One things you'll need to do for 3scale integration is to _enable policy checks_, which are disabled by default. 3scale is a policy delegated out to from the Istio Mixer. Run
```
oc get cm -n istio-system istio -o jsonpath='{.data.mesh}' | grep disablePolicyChecks
```
If _disablePolicyChecks_ is _true_, you need to set it to _false_. Run the following, search for _disablePolicyChecks_ (about 10 lines down) and change it to _false_
```
oc edit cm -n istio-system istio
```
For more see [Updating Mixer policy enforcement](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_day_two/prepare-to-deploy-applications-ossm.html#ossm-mixer-policy_deploying-applications-ossm)


Now we're ready to apply Service Mesh control to a microservices Application. We'll use the [Bookinfo example] (https://istio.io/latest/docs/examples/bookinfo/) taken from the upstream Istio site.

Here's a diagram of the application:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/4-istio-book-info-architecture.png)

It's a very basic application - a webpage called productpage. 
On the left hand side of the screen will be displayed the result of the details page.
Of most interest to us are the 3 reviews microservices - the results of which will appear on the right hand side of the webpage.
- when v1 of reviews is called - ratings is not called and NO stars are shown
- when v2 of reviews is called - ratings are called and BLACK stars are shown
- when v3 of reviews is called - ratings are called and RED stars are shown

At this point, we need to do 3 things:

1. The first step is to create namespace for the bookinfo application - call it *bookinfo*. I can do this either on the GUI or the command line - let's do it on the command line:
```
oc new-project bookinfo
```

2. The next step is to create a *Service Mesh Member Roll* on the same screen you created a new *Istio Service Mesh Control Plane* about - this essentially dictates which namespaces we'll apply Service Mesh control to. Just enter *bookinfo*.

3. Finally I install my bookinfo microservices application - which my Service Mesh Member Roll
is looking out to apply control to. I'll do that by applying some yaml that installs the Bookinfo Microservices application. As soon as this is created, the Service Mesh Member Roll will apply Service Mesh control to it. Execute the following:
```
oc project bookinfo
oc apply -f https://raw.githubusercontent.com/istio/istio/release-1.3/samples/bookinfo/platform/kube/bookinfo.yaml
```

Wait till it completes.

A couple of minutes later, our Bookinfo Microservices application is installed with Service Mesh control
as we can see:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/4-istio-book-info-pods.png)

Next we need to setup some Service Mesh constructs, inherited from Upstream Istio, for Service Mesh control. First the Envoy based side car proxies and the microservices to apply them to:
```
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/bookinfo/maistra-1.0/bookinfo.yaml
```

Next an Istio gateway - representing the port and protocol at the ingress point to the mesh(in our case HTTP and port 80):
```
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/bookinfo/maistra-1.0/bookinfo-gateway.yaml
```

Next the Istio Destination rules, that is addressible services and their versions:
```
oc apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.1/samples/bookinfo/networking/destination-rule-all.yaml
```

Now, output the Gateway URL: 
```
export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
echo $GATEWAY_URL
```
Append the path */productpage* to this gateway URL to view our Product Page under Service Mesh control. We'll refer to this below as *Product-Page-URL* below. Hit it in a browser:
![](https://raw.githubusercontent.com/tnscorcoran/OpenShift-servicemesh/master/images/4-product-page.png)


For more on applying Red Hat Service Mesh based control and visibility, see my repo on [Openshift Servicemesh](https://github.com/tnscorcoran/openshift-servicemesh)

## Apply 3scale API Management to Bookinfo

### Configure 3scale

Login to 3scale and retrieve your application credentials. In my case I'm using the application that's created in the default product called _API_. If you're not using the default product, you'll need to create an Application Plan then an Application. For more on that, see [Creating Application Plans](https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.8/html-single/getting_started/index#creating-application-plans) and then the following section on creating Applications.

But in my case, using the default Product called _API_, I go to: 
```
Product: API -> Applications -> Listing ->  drill into Developer's App_
```
and copy your API credential ( _User Key_ ) also known as _API-Key_ and refered to that below. 

![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/2-get-api-key.png)


Now we change our API product deployment type to _Istio_. Go to 
```
Product: API -> Integration -> Settings ->  change Deployment to Istio -> click Update Product at the bottom of page
```
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/3-settings-istio.png)
Now we effectively _commit_ our changes by _promoting_ them on the Configuration screen:
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/4-promote.png)


Later on, we'll need the _service id_ of this Istio configured API Product. Copy it from the address bar - in my case 2. Below we'll use it in the variable SERVICE_ID. 
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/4-service-id.png)

The final thing we need to do is create an access token with which the service mesh communicates back to the 3scale manager. Go to:
```
Settings (gear icon to the top right) -> Personal -> Tokens ->  Add Access Token
```
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/5-add-access-token.png)

Consult the documentation for the exact requirements, but I created a universal access token with full access (not recommended for production, but fine for a demo):
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/6-add-access-token.png)

Copy the token - as once you move away from this screen it will no longer be accessible. We'll use this below in the variable API_ADMIN_ACCESS_TOKEN:
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/7-token-copied.png)

### Configure OpenShift Custom Resources
Next we need to configure our Istio control plane and our product-page microservice (the entry point to our bookinfo app) to delegate API Management responsibilities to 3scale. To do that we use a tool _3scale-config-gen_ that's inside the 3scale-istio-adapter-xxxxxxx pod. It generates some custom resources we need to apply at the Istio control plane level as well at the API exposing microservice level. Substitute your values in and execute the following:

```
export API_ADMIN_ACCESS_TOKEN=[yours copied above]
export SM_CP_NS=istio-system
export SYSTEM_PROVIDER_URL=[your 3scale Admin URL]
export HANDLER_NAME=threescale
oc exec -n ${SM_CP_NS} $(oc get po -n ${SM_CP_NS} -o jsonpath='{.items[?(@.metadata.labels.app=="3scale-istio-adapter")].metadata.name}') -it -- ./3scale-config-gen --url ${SYSTEM_PROVIDER_URL} --name ${HANDLER_NAME} --token ${API_ADMIN_ACCESS_TOKEN} -n ${SM_CP_NS} > threescale-adapter-config.yaml
```
Now apply the 3 custom resources (rule, handler, instance) created and populated into the file _threescale-adapter-config.yaml_.
```
oc apply -f ./threescale-adapter-config.yaml -n istio-system
```

Next we need to patch the productpage deployment to get to delegate API authorisation and traffic reporting to 3scale. Execute the following:
```
oc project bookinfo
export HANDLER_NAME="threescale"
export SERVICE_ID="[yours copied above]"
export DEPLOYMENT="productpage-v1"
patch="$(oc get deployment "${DEPLOYMENT}" --template='{"spec":{"template":{"metadata":{"labels":{ {{ range $k,$v := .spec.template.metadata.labels }}"{{ $k }}":"{{ $v }}",{{ end }}"service-mesh.3scale.net/service-id":"'"${SERVICE_ID}"'","service-mesh.3scale.net/credentials":"'"${HANDLER_NAME}"'"}}}}}' )"
oc patch deployment "${DEPLOYMENT}" --patch ''"${patch}"''
```

Now curl or use Postman to hit the Product Page - the value _Product-Page-URL_ saved above
![](https://github.com/tnscorcoran/istio-3scale/blob/master/images/8-postman.png)

You'll get an access Denied message. Now append the 3scale credential in the format 
```
?user_key=[API-Key saved above]
```
If we go back to 3scale and visit the Analtyics screen by navigating to the area below and hit our API a few times, we can see the hit count incrementing:
```
API -> Analytics -> Usage
```

Congratulations you've applied API Mangement to our HTTP URL through the 3scale Istio Adapter.


## Conclusion
In this demo we 
- setup 3scale on OpenShift
- setup a simple application using several Microservices, the [Bookinfo example] (https://istio.io/latest/docs/examples/bookinfo/) taken from the upstream Istio site.
- apply service mesh control to Bookinfo
- apply 3scale API Management to Bookinfo through the [3scale Istio Adapter](https://docs.openshift.com/container-platform/4.4/service_mesh/threescale_adapter/threescale-adapter.html)
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
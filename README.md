# 3scale Istio Mixer Adapter

## In this demo we 
- setup 3scale on OpenShift
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
- an OpenShift 4 cluster - in my case 4.5 with Administrative access.
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





## Conclusion
In this demo we 
- setup 3scale on OpenShift
- setup a simple application using several Microservices, the [Bookinfo example] (https://istio.io/latest/docs/examples/bookinfo/) taken from the upstream Istio site.
- apply service mesh control to Bookinfo
- apply 3scale API Management to Bookinfo through the [3scale Istio Adapter](https://docs.openshift.com/container-platform/4.4/service_mesh/threescale_adapter/threescale-adapter.html)
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
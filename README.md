# Red Hat 3scale and Istio demo

## Prerequisites
TODO

1 - Login and execute initialisations
==================================================================================================

In this demo, we assume you are using RHPDS
Order the 3scale Istio demo on that system. You will be issued with a GUID identifying your cluster
SSH into the cluster box as follows 

ssh -i ~/.ssh/your_private_key_name {$username}@bastion.{$GUID}.openshift.opentlc.com



git clone https://github.com/tnscorcoran/istio-3scale.git

mkdir lab

cd istio-3scale


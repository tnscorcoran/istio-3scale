# Modify this to be your usename
echo "export API_USERNAME=user1" >> ~/.bashrc

echo "export API_REGION=`echo $HOSTNAME | cut -d'.' -f2`" >> ~/.bashrc
echo "export API_DOMAIN=clientvm.\$API_REGION.openshift.opentlc.com" >> ~/.bashrc
echo "export API_TENANT_SUFFIX=3scale-mt-api0" >> ~/.bashrc
echo "export GW_PROJECT=\$API_USERNAME-gw" >> $HOME/.bashrc
source ~/.bashrc

echo "export API_ADMIN_ACCESS_TOKEN=`sudo more /root/provisioning_output/clientvm.$API_REGION.openshift.opentlc.com/3scale_tenants_api0/api0_tenant_info_file_1_1.txt | sed '3q;d' | cut -f7 -d$'\t'`" >> ~/.bashrc
echo 'export API_PASSWD=r3dh4t1!' >> ~/.bashrc
echo 'export OCP_PASSWD=r3dh4t1!' >> ~/.bashrc
echo "export OCP_USERNAME=developer" >> ~/.bashrc
echo "export LAB_CODE=a1001" >> ~/.bashrc
echo "export OCP_REGION=`echo $HOSTNAME | cut -d'.' -f2`" >> ~/.bashrc
echo "export OCP_DOMAIN=clientvm.\$OCP_REGION.openshift.opentlc.com" >> ~/.bashrc
echo "export OCP_WILDCARD_DOMAIN=apps.\$OCP_DOMAIN" >> ~/.bashrc
echo "export MSA_PROJECT=rhte-mw-api-mesh-\$LAB_CODE" >> ~/.bashrc
echo "export API_WILDCARD_DOMAIN=apps.\$API_DOMAIN" >> ~/.bashrc
echo "export TENANT_NAME=\$API_USERNAME-\$API_TENANT_SUFFIX" >> ~/.bashrc
echo "export THREESCALE_PORTAL_ENDPOINT=https://\${API_ADMIN_ACCESS_TOKEN}@\$TENANT_NAME-admin.\$API_WILDCARD_DOMAIN" >> ~/.bashrc
echo "export BACKEND_ENDPOINT_OVERRIDE=https://backend-\$API_TENANT_SUFFIX.\$API_WILDCARD_DOMAIN" >> ~/.bashrc
source ~/.bashrc

oc login https://$HOSTNAME:8443 -u $OCP_USERNAME -p $OCP_PASSWD
oc project $MSA_PROJECT
echo "export NAKED_CATALOG_ROUTE=$(oc get route catalog-unsecured -o template --template='{{.spec.host}}' -n $MSA_PROJECT)" >> ~/.bashrc
source ~/.bashrc

oc create route edge catalog-stage-apicast-$OCP_USERNAME --service=stage-apicast  -n $GW_PROJECT
oc create route edge catalog-prod-apicast-$OCP_USERNAME --service=prod-apicast  -n $GW_PROJECT

curl -X GET "http://$NAKED_CATALOG_ROUTE/products"

echo -en "Openshift URL, ID and Password:"
echo -en "\n\nhttps://$OCP_DOMAIN:8443\n\n"
echo $OCP_USERNAME
echo $OCP_PASSWD
echo -en "3scale Admin URL:"
echo -en "\n\nhttps://$TENANT_NAME-admin.$API_WILDCARD_DOMAIN\n\n"   
echo "http://$NAKED_CATALOG_ROUTE"

   
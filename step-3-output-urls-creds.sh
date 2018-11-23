#!/usr/bin/env bash


echo "Openshift URL, ID and Password:"
echo "https://$OCP_DOMAIN:8443"
echo $OCP_USERNAME
echo -en $OCP_PASSWD

echo "3scale Admin URL:"
echo -en "\n\nhttps://$TENANT_NAME-admin.$API_WILDCARD_DOMAIN\n\n"   

echo "3scale Admin URL:"
echo "http://$NAKED_CATALOG_ROUTE"

   
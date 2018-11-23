#!/usr/bin/env bash


echo "Openshift URL, ID and Password:\n"
echo "https://$OCP_DOMAIN:8443"
echo $OCP_USERNAME
echo $OCP_PASSWD

echo "\n3scale Admin URL:\n"
echo "https://$TENANT_NAME-admin.$API_WILDCARD_DOMAIN\n"   

echo "3scale Admin URL:\n"
echo "http://$NAKED_CATALOG_ROUTE"

   
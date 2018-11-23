#!/usr/bin/env bash


echo -en "Openshift URL, ID and Password:"
echo -en "\n\nhttps://$OCP_DOMAIN:8443\n\n"
echo $OCP_USERNAME
echo $OCP_PASSWD
echo -en "3scale Admin URL:"
echo -en "\n\nhttps://$TENANT_NAME-admin.$API_WILDCARD_DOMAIN\n\n"   
echo "http://$NAKED_CATALOG_ROUTE"

   
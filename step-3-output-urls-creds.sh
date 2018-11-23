#!/usr/bin/env bash

echo "Openshift URL, ID and Password:"
echo "     https://$OCP_DOMAIN:8443"
echo "     $OCP_USERNAME"
echo "     $OCP_PASSWD"
echo
echo "3scale Admin URL, ID and Password:"
echo "     https://$TENANT_NAME-admin.$API_WILDCARD_DOMAIN"   
echo "     $API_USERNAME"   
echo "     $API_PASSWD"   
echo
echo "NAKED CATALOG ROUTE:"
echo "     http://$NAKED_CATALOG_ROUTE"
echo

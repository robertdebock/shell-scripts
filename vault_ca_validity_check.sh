#!/bin/bash -x


if [ -z "${VAULT_ADDR}" -o -z "${VAULT_TOKEN}" ] ; then
  echo "Please make sure you set VAULT_ADDR and VAULT_TOKEN."
  exit 1
fi

check_status() {
  vault status > /dev/null 2>&1
}

list_namespaces() {
  vault namespace list 2> /dev/null
}


check_status || (echo "Can't get the status of Vault." ; exit 1)
list_namespaces || (echo "No namespaces found." ; exit 2)

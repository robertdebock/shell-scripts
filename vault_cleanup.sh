#!/bin/bash

# Stolen from https://github.com/hashicorp/vault/issues/1815#issuecomment-300861855

if ! which jq > /dev/null 2>&1 ; then
  echo "Please install jq."
  exit 1
fi

if [ -r ~/.vault-token ]; then
  token=$(cat ~/.vault-token)
fi

export VAULT_ADDR=${VAULT_ADDR:-"http://localhost:8200"}
export VAULT_TOKEN=${VAULT_TOKEN:-"$token"}

dump() {
  curl -k  -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/auth/token/accessors?list=true"  | jq -r '.data.keys[]
' > accessors.list
}

revoke_app() {
  local accessor="$1"
  local revoke_app="$2"
  local appid=$(vault token lookup -format=json -accessor "$accessor" | jq -r '.data.meta."app-id"')
  if [ "$appid" = "$revoke_app" ]; then
    echo "Revoke: $accessor"
    vault token-revoke -accessor "$accessor" > /dev/null
  fi
}

revoke_apps() {
  if ! [ -r accessors.list ]; then
    echo "Cannot find accessors.list; run dump first"
    exit 1
  fi
  while read -r ACCESSOR; do
    revoke_app "$ACCESSOR" "$1"
  done < accessors.list
}


info() {
  if ! [ -r accessors.list ]; then
    echo "Cannot find accessors.list; run dump first"
    exit 1
  fi
  while read -r ACCESSOR; do
    vault token-lookup -format=json -accessor "$ACCESSOR"
  done < accessors.list
}

case ${1:-"help"} in
  dump)
    echo "Dumping accessors.list"
    dump
  ;;
  info)
    echo "Dumping token information"
    info
  ;;
  revoke-app-id)
    if [ -z "$2" ]; then
      echo "Must provide an app ID hash as argugment 2"
      echo "Example: sha1:43a9e4dcda072319e26d79fda59bae2bf17af288"
      echo "Can get this from the 'info' command"
      exit 1
    fi
    revoke_apps "$2"
  ;;
  *|help)
    cat <<EOF
Usage:

  $0 dump                   # Dump accessors.list
  $0 info                   # Get token information on each accessor
  $0 revoke-app-id APP_HASH # Revoke AppID tokens matching the APP_HASH
  $0 help                   # Print this help
EOF
  ;;
esac

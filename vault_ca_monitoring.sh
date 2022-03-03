#!/bin/sh

# INPUT: URL (https://vault.example.com/namespace/path/pki)

# OUTPUT: integer representing the number of days left before expiry/

usage() {
  echo "Please specify a URL to connect to."
  echo "For example: $0 http://127.0.0.1:8200/v1/pki/ca/pem"
  echo
  exit 1
}

test_connection() {
  # Try the connection.
  if ! curl "${1}" > /dev/null 2>&1 ; then
    echo "Can't connect."
    exit 2
  fi
}

call_api() {
  certificate=$(curl "${1}" 2> /dev/null)
}

report() {
  end_date=$(echo "${certificate}" | \
    sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |
    openssl x509 -text 2> /dev/null |
    sed -n 's/ *Not After : *//p')
 
  if [ -n "${end_date}" ] ; then
    end_date_seconds=$(date -d "${end_date}" +%s)
    now_seconds=$(date '+%s')
    echo $(((end_date_seconds-now_seconds)/24/3600))
  else
    echo "An error occurred."
    exit 1
  fi
}

if [ -z "$1" ] ; then
  usage
fi

test_connection "$@"
call_api "$@"
report

#! /bin/sh -x

servername=$1
port=${2:-443}
hostname=${3:-$servername}

if [ -z "${1}" ] ; then
  echo "Please specify a hostname to check. For example:"
  echo
  echo "$0 google.com"
  echo
  echo "Optionally add a protocol and/or hostname:"
  echo
  echo "$0 google.com 8443 my_hostname"
  exit 1
fi

case "${OSTYPE}" in
  "linux-gnu")
    date_command="date -d"
  ;;
  "darwin21")
    date_command="date -j -f \"%b %d %T %Y %Z\""
  ;;
  *)
    echo "The OS ${OSTYPE} is not supported."
    exit 1
  ;;
esac

end_date=$(echo | openssl s_client -servername "${servername}" -host "${hostname}" -port "${port}" -showcerts -prexit 2> /dev/null |
  sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |
  openssl x509 -text 2>/dev/null |
  sed -n 's/ *Not After : *//p')

if [ -n "${end_date}" ] ; then
  end_date_seconds=$(${date_command} "${end_date}" "+%s")
  now_seconds=$(date '+%s')
  echo "($end_date_seconds-$now_seconds)/24/3600" | bc
else
  echo "An error occurred."
  exit 1
fi

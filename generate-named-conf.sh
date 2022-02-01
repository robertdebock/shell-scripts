#!/bin/sh

# A script to generate named.conf. Quite specific.

# Input: a file called `forwarders.txt`, with on each line:
# - The zone.
# - The nameserver(s) to forward to.
#
# For example:
# example.com 1.2.3.4
# 1.in-addr.arpa.net 2.3.4.5 3.4.5.6

cat << EOF
acl goodclients {
  192.0.2.0/24;
  localhost;
  localnets;
};

options {
  directory "/var/cache/bind";

  recursion yes;
  allow-query { goodclients; };
  allow-query-cache { goodclients; };

  forward only;
  forwarders {
    168.63.129.16;
  };

  dnssec-enable yes;
  dnssec-validation yes;

  auth-nxdomain no;    # conform to RFC1035
  listen-on-v6 { any; };
};

EOF

# if [ -f forwarders.txt ] ; then
#   grep -v '^#' forwarders.txt | while read -r zone dnses ; do
#     echo "zone \"${zone}\" {"
#     echo "  type forward;"
#     echo "  forward only;"
#     printf "  forwarders { "
#     for dns in ${dnses} ; do
#       printf "%s; " "${dns}"
#     done
#     echo "};"
#     echo "};"
#     echo ""
#   done
# fi

if [ -f forwarders.txt ] ; then
  grep -v '^#' forwarders.txt | while read -r zone dnses ; do
    printf "Add-DnsServerConditionalForwarderZone -Name %s -MasterServers " "${zone}"
    printf "%s" "${dnses}" | sed 's/ /,/g'
    echo ""
  done
fi

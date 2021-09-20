#!/bin/bash

# A script to return a random number, based on a least and most value.

default_least="10"
default_most="30"

while getopts :l:m: flag
do
  case "${flag}" in
    l)
      least="${OPTARG}"
    ;;
    m)
      most="${OPTARG}"
    ;;
    \?)
      echo "The option ${OPTARG} is invalid."
      exit 1
    ;;
    :)
     echo "The argument ${OPTARG} is unknown."
     exit 1
    ;;
  esac
done

if [ -z "${least}" ] ; then
  least="${default_least}"
fi

if [ -z "${most}" ] ; then
  most="${default_most}"
fi

if [ "${least}" -ge "${most}" ] ; then
  echo "Least value (${least}) is higher or equal to the most value (${most})."
  exit 1
fi

delta=$((most - least + 1))

echo $((least + RANDOM % delta))

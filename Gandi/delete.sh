#!/bin/bash

usage() {

cat <<EOF
$(basename $0) : delete a DNS value on Gandi

SYNOPSIS

  $(basename $0) -f fqdn

    -f fqdn : fqdn of the record to delete

    -h : displays this help

EOF
}

while getopts "f:h" opt
do
  case $opt in
    f)
      fqdn=$OPTARG
    ;;
    h)
      usage
      exit 0
    ;;
    *)
      echo "Unknown option"
      usage
      exit 3
  esac
done

if [ "x$fqdn" == "x" ]
then
  echo "Options -f is mandatory. Exiting..."
  usage
  exit 1
fi

name=$(echo $fqdn | cut -d '.' -f1)
domain=$(echo $fqdn | cut -d '.' -f2-)

dnsline=$(gandi record list -f text $domain | grep $name)

if [ "x$dnsline" == "x" ]
then
  # DNS name doesn't exist
  echo "$fqdn doesn't exist"
  exit 2
fi

dnstype=$(echo $dnsline | awk '{print $4}')
dnsvalue=$(echo $dnsline | awk '{print $5}')

gandi record delete --name $name --type $dnstype --value $dnsvalue $domain

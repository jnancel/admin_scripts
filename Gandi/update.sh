#!/bin/bash

usage() {

cat <<EOF
$(basename $0) : update a DNS value on Gandi

SYNOPSIS

  $(basename $0) -f fqdn -o oldIP -n newIP

    -f fqdn : fqdn of the record to update

    -i IP : IP to associate to the fqdn

    -h : displays this help

EOF
}

while getopts "f:i:h" opt
do
  case $opt in
    f)
      fqdn=$OPTARG
    ;;
    i)
      ip=$OPTARG
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

if ([ "x$fqdn" == "x" ] || [ "x$ip" == "x" ])
then
  echo "Options -f and -i are mandatory. Exiting..."
  usage
  exit 1
fi

domain=$(echo $fqdn | awk -F'.' '{print $(NF-1)"."$NF}')
subdomain=$(echo $fqdn | awk -F'.' '{$NF=""; $(NF-1)=""; print $0}' | sed -e 's/\ //g')

record=$(mktemp)
gandi record list $domain -f text | grep ^"$subdomain " > $record

if [ $? -ne 0 ]
then 
  echo "Cannot find $fqdn in domain $domain. Exiting..."
  exit 2
fi

if [ $(wc -l $record | awk '{print $1}') -gt 1 ]
then
  echo "Found more than one record for $fqdn. Exiting..."
  exit 4
fi

ttl=$(awk '{print $2}' $record)
old_ip=$(awk '{print $5}' $record)
gandi record update -r "$subdomain $ttl A $old_ip" --new-record "$subdomain $ttl A $ip" $domain

rm $record

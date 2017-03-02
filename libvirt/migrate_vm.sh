#!/bin/bash

usage() {

cat <<EOF
$(basename $0) : migrate a VM

SYNOPSIS

  $(basename $0) -n vmname -s sourcehypv -d desthypv

    -n vmname : VM name as seen in virsh

    -s sourcehypv : source hypervisor

    -d desthypv : destination hypervisor

EOF
}

while getopts "n:s:d:h" opt
do
  case $opt in
    n)
      vmname=$OPTARG
    ;;
    s)
      srchypv=$OPTARG
    ;;
    d)
      dsthypv=$OPTARG
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

if ([ "x$vmname" == "x" ] || [ "x$srchypv" == "x" ] || [ "x$dsthypv" == "x" ])
then
  echo "Options -n, -s and -d are mandatory. Exiting..."
  usage
  exit 1
fi

vmstate=$(virsh -c qemu+ssh://$srchypv/system list --all | grep " $vmname " | awk '{print $3, $4}')

if [ "$vmstate" == "running " ]
then
  read -p "VM $vmname needs to be shutdown. Do you agree (y/n) "
  answer=$REPLY
  if [ $answer == "n" ]
  then
    echo "Exiting program"
    exit
  elif [ $answer != "y" ]
  then
    echo "Unknown answer. Exiting..."
    exit 4
  fi
  virsh -c qemu+ssh://$srchypv/system shutdown $vmname
  while true
  do
    sleep 2
    vmstate=$(virsh -c qemu+ssh://$srchypv/system list --all | grep " $vmname " | awk '{print $3, $4}')
    [ "$vmstate" == "shut off" ] && break
  done
elif [ "$vmstate" != "shut off" ]
then
  echo "Unknown VM state $vmstate. Exiting..."
  exit 2
fi

xmldump=$(mktemp)
virsh -c qemu+ssh://$srchypv/system dumpxml $vmname > $xmldump
qcowfile=$(grep '<source file' $xmldump | cut -d "'" -f2)
scp $srchypv:$qcowfile $dsthypv:$qcowfile
ssh $dsthypv "chown qemu. $qcowfile"

sed -i /uuid/d $xmldump
sed -i '/mac address/d' $xmldump

virsh -c qemu+ssh://$dsthypv/system define $xmldump

read -p "What do you want to do with VM $vmname on $srchypv (remove,restart,keep) "
answer=$REPLY
case $answer in
  'remove')
    virsh -c qemu+ssh://$srchypv/system undefine $vmname
    ssh $srchypv "rm -rf $qcowfile"
  ;;
  'restart')
    virsh -c qemu+ssh://$srchypv/system start $vmname
  ;;
  'keep')
    echo "$vmname kept shutdown"
  ;;
  *)
    echo "Unknown answer. Nothing done"
esac

read -p "Do you want to start VM $vmname on $dsthypv (y,n) "
answer=$REPLY
if [ $answer == "y" ]
then
  virsh -c qemu+ssh://$dsthypv/system start $vmname
elif [ $answer != "n" ]
then
  echo "Unknown response. Nothing done"
fi
  
 

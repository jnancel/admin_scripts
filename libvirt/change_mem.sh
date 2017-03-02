#!/bin/bash

usage() {

cat <<EOF
$(basename $0) : change the amount of memory for a libvirt VM

SYNOPSIS

  $(basename $0) -n vmname -m memory

    -n vmname : name of the VM

    -m memory : amount of desired memory on the VM in MB

    -c cpu : number of vcpus desired on the VM

EOF
}

while getopts "n:m:c:h" opt
do
  case $opt in
    n)
      vmname=$OPTARG
    ;;
    m)
      mem=$(($OPTARG*1024))
    ;;
    c)
      cpus=$OPTARG
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

if [ "x$vmname" == "x" ]
then
  echo "Please provide a VM name"
  usage
  exit 1
fi

if ([ "x$mem" == "x" ] && [ "x$cpus" == "x" ])
then
  echo "Please provide a desired memory or cpu amount"
  usage
  exit 2
fi

temp=$(mktemp)

clush -w @hypvlibv "virsh list --all" | grep " $vmname " | cut -d ':' -f1 > $temp

if [ $(cat $temp | wc -l | awk '{print $1}') -ne 1 ]
then
  echo "Impossible to determine which VM to modify. Exiting..."
  exit 3
fi 

dedi=$(cat $temp)
needtoreboot=false

if [ "x$mem" != "x" ]
then
  virsh -c qemu+ssh://$dedi/system setmem $vmname $mem --config --live 2> /dev/null
  if [ $? -ne 0 ]
  then
  # Probably we also need to raise the max memory parameter
  # and consequently to stop the VM
    needtoreboot=true
  fi
fi

if [ "x$cpus" != "x" ]
then
  vmstate=$(virsh -c qemu+ssh://$dedi/system list --all | grep $vmname | awk '{print $3}')
  if [ $vmstate != "shut off" ]
  then
    needtoreboot=true
  fi
fi

count=0
timeout=60

if ( $needtoreboot )
then
  # Asking for user confirmation to shutdown VM    
  read -p "$vmname needs to be stopped to increase memory. Do you agree? (y/n) "
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
  virsh -c qemu+ssh://$dedi/system shutdown $vmname
  while true
  do
    count=$(($count+1))
    if [ $count -gt $timeout ]
    then
      echo "Timeout reached while waiting for $vmname to shutdown."
      read -p "Do you want to forcefully shut it? (y/n) "
      answer=$REPLY
      if [ $answer == "y" ]
      then
        virsh -c qemu+ssh://$dedi/system destroy $vmname
      else 
        echo "Exiting..."
        exit 5
      fi
    fi
 
    sleep 2
    vmstate=$(virsh -c qemu+ssh://$dedi/system list --all | grep ' $vmname ' | awk '{print $3, $4}')
    if [ "$vmstate" == "shut off" ]
    then
      if [ "x$mem" != "x" ]
      then
        virsh -c qemu+ssh://$dedi/system setmaxmem $vmname $mem --config
        virsh -c qemu+ssh://$dedi/system setmem $vmname $mem --config
      fi
      if [ "x$cpus" != "x" ]
      then
        virsh -c qemu+ssh://$dedi/system setvcpus $vmname $cpus --config --maximum
        virsh -c qemu+ssh://$dedi/system setvcpus $vmname $cpus --config
      fi
      break
    fi
  done
fi

# Restarting the VM
echo "Restarting $vmname"
virsh -c qemu+ssh://$dedi/system start $vmname

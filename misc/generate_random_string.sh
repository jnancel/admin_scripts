#!/bin/bash

if [ "x$1" == "x" ]
then
  echo "Please specify a password length"
  exit 1
fi

length=$1

dd bs=$length count=1 if=/dev/urandom 2> /dev/null | base64 | tr -cd '[:alnum:]' | cut -b -$length

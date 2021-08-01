#!/bin/bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


cd "$SCRIPT_DIR"

# Some additional checks

uname > uname.txt
dmesg > dmesg.txt


if grep -s 'amzn2' uname.txt && \
   grep -s 'Hypervisor detected: KVM' dmesg.txt ; then
 echo "Additional checks passed."
else
  echo "Not OK."
  exit 3
fi



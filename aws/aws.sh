#!/bin/bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


cd "$SCRIPT_DIR"

# Some additional checks

uname -a > uname.txt
dmesg > dmesg.txt


if grep -s 'amzn2' uname.txt && \
   grep -s 'Hypervisor detected: KVM' dmesg.txt ; then
 echo "Additional checks passed."
else
  echo "Not OK."
  exit 3
fi

SSH_KEY_FINGERPRINT=$(ssh-keygen -l -f ~/.ssh/id_rsa.pub | cut -f2 -d' ')

if [ "$SSH_KEY_FINGERPRINT" != "SHA256:0CVGJt5T68lV+tJVlI04H5A/bARnK+Gu1CpqjFjB3RY" ]; then
  echo "Unexpected or absent ssh key"
  exit 4
fi


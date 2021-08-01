#!/bin/bash

# in AWS CloudShell metadata Chttp://169.254.169.254/latest/meta-data/) isn't available
# try to guess where we are by UID/name of the user

if id | grep --silent cloudshell-user ; then
  echo "We are in AWS CloudShell."
else
  echo "Not supported CloudShell provider."
  exit 1
fi

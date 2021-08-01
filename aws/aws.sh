#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Stop in case of error.
set -e

cd "$SCRIPT_DIR"

# Some additional checks

uname -a > uname.txt
dmesg > dmesg.txt

# jq must be present
jq --version > jq-version.txt

if grep --silent 'amzn2' uname.txt && \
   grep --silent 'Hypervisor detected: KVM' dmesg.txt ; then
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

echo "SSH key check passed"

# print some aws-cloudshell-specific env variables
echo "AWS_EXECUTION_ENV=$AWS_EXECUTION_ENV"
echo "AWS_REGION=$AWS_REGION"
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
echo "---------------------"

echo "Setup .aws/config"

mkdir -p ~/.aws
cp files/aws_config ~/.aws/config

if tail -n 3 ~/.bashrc | grep --silent 'bashrc99' ; then
  echo "Custom bashrc already installed"
else
  echo ". ~/.bashrc99" >> ~/.bashrc
fi

cp files/bashrc99 ~/.bashrc99
echo "You may need to execute source ~/.bashrc99 in the current shell"

cp files/ssh_config ~/.ssh/config
chmod 0600 ~/.ssh/config

DEPL_KEY=k8s-sandbox
if [ ! -e  ~/.ssh/${DEPL_KEY}_deploy_key ] ; then
  echo "Installing deploy key ${DEPL_KEY}."
  aws ssm get-parameter --name "/github/deploykeys/${DEPL_KEY}"  --with-decryption | jq '.Parameter.Value' --raw-output \
    | tr '\\' '\n' > ~/.ssh/${DEPL_KEY}_deploy_key
  chmod 0600 ~/.ssh/${DEPL_KEY}_deploy_key
fi

# copy .git config
cp files/.gitconfig ~/

# set-up projects
mkdir -p ~/projects

REPO_NAME=k8s-sandbox
if [ ! -d ~/projects/$REPO_NAME ] ; then
  echo "Setting up project $REPO_NAME ..."
  cd ~/projects
  git clone git@${REPO_NAME}.github.com:gdm/${REPO_NAME}.git
fi



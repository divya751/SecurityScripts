#!/bin/bash

# exit when the command fails
set -o errexit;

# exit when try to use undeclared var
set -o nounset;

accessKeyToSearch=${1?"Usage: bash $0 AccessKeyId"}
echo $accessKeyToSearch
for username in $(aws iam list-users --query 'Users[*].UserName' --output text); do
    for accessKeyId in $(aws iam list-access-keys --user-name $username --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
        if [ "$accessKeyToSearch" = "$accessKeyId" ]; then
            echo $username;
            break;
        fi;
    done;
done;

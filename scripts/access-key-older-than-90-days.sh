#!/bin/bash
# Script displays users Active access keys with created date and the age of the keys.\n Only the keys that are 90 days olders

Today=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

printf "The list of all the users Active access keys with created date and the age of the keys.\n Only the keys that are used in last 30 days.\n"
printf "ACCESS KEY USED DAY AGO = 0 means its used Today \n"
printf "\nUSER \t \t LAST ACTIVITY DAYS  CREATED ON \t \t"
for user in $(aws iam list-users --query 'Users[].UserName' --output text); do
  CREATED_ON=$(aws iam list-access-keys --user-name "$user"   --output json |jq '.AccessKeyMetadata[] | select(.Status == "Active")| .CreateDate' | tr -d '"')
  for key in $(aws iam list-access-keys --user-name $user --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    LAST_ACCESS_KEY=$(aws iam get-access-key-last-used --access-key-id $key --query '[AccessKeyLastUsed.LastUsedDate]' --output text)
  #  aws iam get-access-key-last-used --access-key-id $key --query '[UserName,AccessKeyLastUsed.LastUsedDate]' --output text
    for dates in $LAST_ACCESS_KEY;
      do
        d1=$(date -jf %Y-%m-%d "$Today" +%s 2> /dev/null)
        d2=$(date -jf %Y-%m-%d "$dates" +%s 2> /dev/null)
        keyageinsec=`expr $d1 - $d2`
    #    printf "D1 : $d1 \t D2: $d2 \t Key age in second :$keyageinsec FOR $LAST_ACCESS_KEY \n "
        age=`expr $keyageinsec / 86400`

      #return $age
     done
  done
  if [[ -n "$key" && $age -le 30 && -n $age ]]; then
       printf "\n $user \t $age \t \t \t \t $CREATED_ON"
       #printf "Keys: $key \t Created on: $CREATED_ON\n"
  fi
done

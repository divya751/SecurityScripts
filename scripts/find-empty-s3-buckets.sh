#!/bin/bash
profile="default"
olddate="2021-01-01"
smallbucketsize=10

emptybucketlist=()
oldbucketlist=()
smallbucketlist=()

#for bucketlist in  $(aws s3api list-buckets  | jq --raw-output '.Buckets[6,7,8,9].Name'); # test this script on just a few buckets
for bucketlist in  $(aws s3api list-buckets  | jq --raw-output '.Buckets[].Name');
do
#  echo "* $bucketlist"
  if [[ ! "$bucketlist" == *"shmr-logs" ]]; then
    listobjects=$(\
      aws s3api list-objects --bucket $bucketlist \
      --query 'Contents[*].Key' \
      )
#echo "==$listobjects=="
    if [[ "$listobjects" == "null" ]]; then
          echo "$bucketlist is empty"
          emptybucketlist+=("$bucketlist")

    fi
  fi
done


#echo "consider deleting these empty buckets"
#for emptybuckets in "${emptybucketlist[@]}";
#do
#  echo "aws s3api delete-bucket  --bucket $emptybuckets"
#done

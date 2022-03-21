#!/usr/bin/env bash

  echo "Looking for open S3 Buckets (ACLs and Policies) in all regions...  "
  #
  # Otherwise start to iterate bucket
  #
  ALL_BUCKETS_LIST=$(aws s3api list-buckets --query 'Buckets[*].{Name:Name}' --output text 2>&1)
  if [[ $(echo "$ALL_BUCKETS_LIST" | grep AccessDenied) ]]; then
    echo "Access Denied Trying to List Buckets"
    return
  fi
  if [[ "$ALL_BUCKETS_LIST" == "" ]]; then
    echo "No buckets found"
    return
  fi

  for bucket in $ALL_BUCKETS_LIST; do

    #
    # LOCATION - requests referencing buckets created after March 20, 2019
    # must be made to S3 endpoints in the same region as the bucket was
    # created.
    #
    BUCKET_LOCATION=$(aws s3api get-bucket-location --bucket $bucket --output text 2>&1)
    if [[ $(echo "$BUCKET_LOCATION" | grep AccessDenied) ]]; then
      echo "Access Denied Trying to Get Bucket Location for $bucket"
      continue
    fi
    if [[ "None" == $BUCKET_LOCATION ]]; then
      BUCKET_LOCATION="us-east-1"
    fi
    if [[ "EU" == $BUCKET_LOCATION ]]; then
      BUCKET_LOCATION="eu-west-1"
    fi

    #
    # Check for public ACL grants
    #
    BUCKET_ACL=$(aws s3api get-bucket-acl --region $BUCKET_LOCATION --bucket $bucket --output json 2>&1)
    if [[ $(echo "$BUCKET_ACL" | grep AccessDenied) ]]; then
      echo "Access Denied Trying to Get Bucket Acl for $bucket"
      continue
    fi

    ALLUSERS_ACL=$(echo "$BUCKET_ACL" | jq '.Grants[]|select(.Grantee.URI != null)|select(.Grantee.URI | endswith("/AllUsers"))')
    if [[ $ALLUSERS_ACL != "" ]]; then
      echo "$BUCKET_LOCATION: $bucket bucket is Public!" "$BUCKET_LOCATION"
      continue
    fi

    AUTHENTICATEDUSERS_ACL=$(echo "$BUCKET_ACL" | jq '.Grants[]|select(.Grantee.URI != null)|select(.Grantee.URI | endswith("/AuthenticatedUsers"))')
    if [[ $AUTHENTICATEDUSERS_ACL != "" ]]; then
      echo "$BUCKET_LOCATION: $bucket bucket is Public!" "$BUCKET_LOCATION"
      continue
    fi

  done

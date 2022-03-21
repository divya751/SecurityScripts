#!/usr/bin/env bash

##Find secrets in EC2 User Data (Not Scored) (Not part of CIS benchmark)"



  SECRETS_TEMP_FOLDER="/tmp/secrets-dummy"
  if [[ ! -d $SECRETS_TEMP_FOLDER ]]; then
    # this folder is deleted once this check is finished
    mkdir $SECRETS_TEMP_FOLDER
  fi

  echo "Looking for secrets in EC2 User Data in instances across all regions... (max 100 instances per region use -m to increase it)  "

    LIST_OF_EC2_INSTANCES=$(aws ec2 describe-instances $PROFILE_OPT  --query Reservations[*].Instances[*].InstanceId --output text --max-items $MAXITEMS | grep -v None)
    if [[ $LIST_OF_EC2_INSTANCES ]];then
      for instance in $LIST_OF_EC2_INSTANCES; do
        EC2_USERDATA_FILE="$SECRETS_TEMP_FOLDER/extra741-$instance-userData.decoded"
        EC2_USERDATA=$(aws ec2 describe-instance-attribute --attribute userData $PROFILE_OPT  --instance-id $instance --query UserData.Value --output text| grep -v ^None | decode_report > $EC2_USERDATA_FILE)
        if [ -s "$EC2_USERDATA_FILE" ];then
          # This finds ftp or http URLs with credentials and common keywords
          # FINDINGS=$(egrep -i '[[:alpha:]]*://[[:alnum:]]*:[[:alnum:]]*@.*/|key|secret|token|pass' $EC2_USERDATA_FILE |wc -l|tr -d '\ ')
          # New implementation using https://github.com/Yelp/detect-secrets
          # Test if user data is a valid GZIP file, if so gunzip first
          if gunzip -t "$EC2_USERDATA_FILE" > /dev/null 2>&1; then
            mv "$EC2_USERDATA_FILE" "$EC2_USERDATA_FILE.gz" ; gunzip "$EC2_USERDATA_FILE.gz"
          fi
          FINDINGS=$(secretsDetector file "$EC2_USERDATA_FILE")
          if [[ $FINDINGS -eq 0 ]]; then
            echo "No secrets found in $instance User Data"
            # delete file if nothing interesting is there
            #rm -f "$EC2_USERDATA_FILE"
          else
            textFail "Potential secret found in $instance User Data"
            # delete file to not leave trace, user must look at the instance User Data
            #rm -f "$EC2_USERDATA_FILE"
          fi
        else
          echo "No secrets found in $instance User Data or it is empty"
        fi
      done
    else
      echo "No EC2 instances found"
    fi

#  rm -rf $SECRETS_TEMP_FOLDER

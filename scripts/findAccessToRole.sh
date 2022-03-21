#! /bin/bash
#check eks- roles
ROLES=$(aws iam list-roles | jq -r .Roles[].Arn | grep "role/eks-" | grep "rbac")
echo "Roles                  Namespace          AccessedBy                  AccessDate"
for ROLE in $ROLES
do
  #  echo "ROLE : $ROLE "
    JOBID=$(aws iam generate-service-last-accessed-details --arn $ROLE | jq -r .JobId)
    #echo "JOBID: $JOBID "
    NAMESPACES=$(aws iam get-service-last-accessed-details --job-id $JOBID | jq -r .ServicesLastAccessed[].ServiceNamespace)
    for NAMESPACE in $NAMESPACES
    do
    #    echo "NS: $NAMESPACE"
        #aws iam get-service-last-accessed-details-with-entities --job-id $JOBID --service-namespace $NAMESPACE | jq '.JobCompletionDate,.EntityDetailsList[].EntityInfo.Name,.EntityDetailsList[].EntityInfo.Id' --output table
        #DateRoleAccessed:.JobCompletionDate,Name:.EntityDetailsList[].EntityInfo.Name
        ACCESSDATE=$(aws iam get-service-last-accessed-details-with-entities --job-id $JOBID --service-namespace $NAMESPACE --query 'JobCompletionDate' --output text )
        #| jq '.JobCompletionDate,.EntityDetailsList[].EntityInfo.Name,.EntityDetailsList[].EntityInfo.Id' ;
        Nameofrole=$(echo $ROLE| cut -d'/' -f 2)
        echo "$Nameofrole"         " $NAMESPACES"        "$JOBID"        " $ACCESSDATE "
    done
done

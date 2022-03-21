#!/bin/bash
#USAGE: sh backup_ami.sh cloudformation@husdyrfag-sandbox
#the AWS account i want to use.
#AWSPROFILE=“cloudformation@husdyrfag-sandbox”
#AWSPROFILE=“$1"
### END OPTIONS ###
# Create a list of Load Balancers.
aws elbv2 describe-load-balancers --query 'LoadBalancers[?(Type == `application`)].LoadBalancerArn | []' --output text > /tmp/aws.load.balancers

# Cycle through the list and start the iamgeing process.
DATE=`date +%Y-%m-%d`
for INSTANCE in cat /tmp/aws.load.balancers
do
        #####echo “Starting to create the image for instance ${INSTANCE} without reboot”
        aws ec2 create-image --region eu-west-1 --instance-id ${INSTANCE} --name “Backup of ${INSTANCE} on ${DATE}” --no-reboot
        aws elbv2 describe-listeners --query 'Listeners[*].Port' --load-balancer-arn ${INSTANCE} --output text
      #  aws ec2 create-image --instance-id ${INSTANCE} --name “Backup of ${INSTANCE} on ${DATE}” --no-reboot --profile $profile
done
echo “The process will continue for some time...”

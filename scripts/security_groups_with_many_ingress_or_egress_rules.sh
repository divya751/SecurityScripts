#!/usr/bin/env bash

# Prowler - the handy cloud security tool (copyright 2020) by Toni de la Fuente
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

# Current VPC Limit is 120 rules (60 inbound and 60 outbound)
# Reference: https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html


#CHECK_TITLE_extra777="[extra777] Find VPC security groups with many ingress or egress rules (Not Scored) (Not part of CIS benchmark)"

    THRESHOLD=50
    echo "Looking for VPC security groups with more than ${THRESHOLD} rules across all regions...  "


        SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text | xargs)

        for SECURITY_GROUP in ${SECURITY_GROUP_IDS}; do

            INGRESS_TOTAL=$(aws ec2 describe-security-groups --filter "Name=group-id,Values=${SECURITY_GROUP}" --query "SecurityGroups[*].IpPermissions[*].IpRanges" --output text | wc -l | xargs)

            EGRESS_TOTAL=$(aws ec2 describe-security-groups --filter "Name=group-id,Values=${SECURITY_GROUP}" --query "SecurityGroups[*].IpPermissionsEgress[*].IpRanges" --output text | wc -l | xargs)

            if [[ (${INGRESS_TOTAL} -ge ${THRESHOLD}) || (${EGRESS_TOTAL} -ge ${THRESHOLD}) ]]; then
                echo ${SECURITY_GROUP} has ${INGRESS_TOTAL} inbound rules and ${EGRESS_TOTAL} outbound rules
            fi
        done

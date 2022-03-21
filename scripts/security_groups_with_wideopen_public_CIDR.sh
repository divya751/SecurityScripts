#!/usr/bin/env bash

# Find VPC security groups with wide-open public IPv4 CIDR ranges

    CIDR_THRESHOLD=24
    REGEX="(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)"
    echo "List of VPC Security Groups with wide-open (</${CIDR_THRESHOLD}) IPv4 address ranges...  "

    check_cidr() {
        local SECURITY_GROUP=$1
        local DIRECTION=$2
        local DIRECTION_FILTER=""
        #local REGION=$3

        case ${DIRECTION} in
            "inbound")
                DIRECTION_FILTER="IpPermissions"
                ;;
            "outbound")
                DIRECTION_FILTER="IpPermissionsEgress"
                ;;
        esac

        CIDR_IP_LIST=$(aws ec2 describe-security-groups \
                        --filter "Name=group-id,Values=${SECURITY_GROUP}" \
                        --query "SecurityGroups[*].${DIRECTION_FILTER}[*].IpRanges[*].CidrIp" \
                        --output text | xargs
                        )

        for CIDR_IP in ${CIDR_IP_LIST}; do
          ###echo ${CIDR_IP}
            if [[ ! ${CIDR_IP} =~ ${REGEX} ]]; then
                CIDR=$(echo ${CIDR_IP} | cut -d"/" -f2 | xargs)
            ###    echo "${SECURITY_GROUP} CIDR: ${CIDR}"
                # Edge case "0.0.0.0/0" for RDP and SSH are checked already by check41 and check42
                if [[ ${CIDR} < ${CIDR_THRESHOLD} && 0 < ${CIDR} ]]; then
                    echo "${SECURITY_GROUP} is wide-open address ${CIDR_IP} in ${DIRECTION} rule"
                fi
            fi
        done
    }


        SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups \
                              --query 'SecurityGroups[*].GroupId' \
                              --output text | xargs
                              )
        for SECURITY_GROUP in ${SECURITY_GROUP_IDS}; do
            check_cidr "${SECURITY_GROUP}" "inbound"
          #  check_cidr "${SECURITY_GROUP}" "outbound"
        done

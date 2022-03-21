#!/bin/bash

RED='\e[1;31m';
GRE='\e[1;32m';
NC='\e[0m'; # No Color

function print_msg () {
        echo -e "${GRE}$1${NC}\n";
        return 0;
}

function print_error () {
        echo -e "${RED}$1${NC}\n";
        return 0;
}

function usage () {
    print_msg "Usage: `basename $0` -i IP_BLACKLIST -r AWS_REGION";
    print_msg "-i: Insert the ip in the AWS NACL.";
    print_msg "-r: Insert AWS region.";
    print_msg "example: `basename $0` -i 1.2.3.4 -r eu-west-1";
    exit 0;
}

function exit_check () {
    if [ $1 -ne 0 ]; then
            print_error "Found problem in: $2";
            print_error "Exit!";
            exit 125;
    fi
}

function check_executable_file() {
    FILE_SEARCH=$(which $1);
    exit_check $? $LINENO;

    if [ -z $FILE_SEARCH ]; then
      print_error "$1: executable does not exist, you need to install it. Exit";
      exit 124;
    fi
}

if [ $# -ne 4 ]; then
    usage;
fi

while getopts "i:r:" opt; do
  case $opt in
    i)
      IP_BLACKLIST="${OPTARG}";
      ;;
    r)
      REGION="${OPTARG}";
      ;;
    h | *)
      usage;
      ;;
  esac
done

check_executable_file "geoiplookup";
check_executable_file "aws";
check_executable_file "whois";

print_msg "Do you want to filter the following ip $IP_BLACKLIST? [y/n]";
read yn
case $yn in
      [Yy]* ) ;;
      [Nn]* ) exit;;
      * ) print_msg "Please answer y or n." &amp;&amp; exit;;
esac

if [[ $IP_BLACKLIST =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  IP_FILTER=$IP_BLACKLIST;
else
  print_error "Invalid ip address. Exit";
  exit 126;
fi

print_msg "IP coming from:";
geoiplookup $IP_FILTER;
exit_check $? $LINENO;

NET_FILTER=$(whois $IP_FILTER|grep route:|uniq|awk '{print $2}');
exit_check $? $LINENO;

if [ "$NET_FILTER" != "" ]; then
  print_msg "Do you want to filter the subnet $NET_FILTER or single IP $IP_FILTER? [ip|net]";
  read ip_net
  case $ip_net in
    ip)
    CIDR_FILTER="$IP_FILTER/32";
    ;;
    net)
    CIDR_FILTER="$NET_FILTER";
    ;;
    * ) print_msg "Is it ip or net." &amp;&amp; exit;;
  esac
else
  CIDR_FILTER="$IP_FILTER/32";
fi

NACL=$(aws ec2 describe-network-acls --output text --query 'NetworkAcls[*].NetworkAclId' --region $REGION);
exit_check $? $LINENO;

for id_acl in $NACL; do
  NUM_EGRESS=$(aws ec2 describe-network-acls \
      --output text \
      --network-acl-ids $id_acl \
      --query 'NetworkAcls[*].Entries[?(RuleAction==`deny` &amp;&amp; Egress==`true`)].{RN:RuleNumber}' \
      --region $REGION |grep -v "32767"|sort -n|tail -1| tr -d '\n');
  exit_check $? $LINENO;

  NUM_INGRESS=$(aws ec2 describe-network-acls \
      --output text \
      --network-acl-ids $id_acl \
      --query 'NetworkAcls[*].Entries[?(RuleAction==`deny` &amp;&amp; Egress==`false`)].{RN:RuleNumber}' \
      --region $REGION |grep -v "32767" |sort -n|tail -1|tr -d '\n');
  exit_check $? $LINENO;

  if [ "$NUM_EGRESS" != "$NUM_INGRESS" ]; then
    print_error "There is an error in the IN / OUT ACL index... Exit.";
    exit 127;
  else
    if [ -n "$CIDR_FILTER" ] &amp;&amp; [[ $CIDR_FILTER =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
      if [ -z "$NUM_INGRESS" ]; then
        NUM_INGRESS=0;
      fi

      IDX=$((NUM_INGRESS+1));

      if [ "$IDX" -eq 100 ]; then
        print_error "$LINENO You have to fix the number of roles, ALL TRAFFIC must be the last one... Exit";
        exit 128;
      fi

      aws ec2 create-network-acl-entry --network-acl-id $id_acl --ingress --rule-number $IDX --protocol all \
      --port-range From=1,To=65535 --cidr-block $CIDR_FILTER --rule-action deny --region $REGION;
      if [ "$?" -eq 0 ]; then
        print_msg "OK  $CIDR_FILTER ingress filtered on $id_acl";
      fi

      aws ec2 create-network-acl-entry --network-acl-id $id_acl --egress --rule-number $IDX --protocol all \
      --port-range From=1,To=65535 --cidr-block $CIDR_FILTER --rule-action deny --region $REGION;
      if [ "$?" -eq 0 ]; then
        print_msg "OK  $CIDR_FILTER egress filtered on $id_acl";
      fi

    else
      print_error "$LINENO The net $CIDR_FILTER does not appear syntactically correct.... Exit";
      exit 129;
    fi
  fi
done

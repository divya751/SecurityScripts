#!/usr/bin/env bash
# Ensure there are no Security Groups not being used.

comm -23  <(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId'  --output text | tr '\t' '\n'| sort) <(aws ec2 describe-instances --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text | tr '\t' '\n' | sort | uniq)
sg-002e7c9e47d68b90b
sg-09b57a5f243713fae
sg-28c6075e
sg-5ce8d225
sg-71a59315
sg-cfdba1b4

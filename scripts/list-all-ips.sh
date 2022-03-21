#aws ec2 describe-network-interfaces --query 'NetworkInterfaces[*].[Association.PublicIp,Attachment.Status,Attachment[*].InstanceId]'
aws ec2 describe-network-interfaces --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId, PublicIP:Association.PublicIp, PrivateIP:PrivateIpAddress, Status:Status, attachedTo:Attachment.InstanceId}' --output table > network_analysis_report.lst
####With filters
aws ec2 describe-network-interfaces  --filters Name=status,Values=available --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId, PubIP:Association.PublicIp, PrivateIP:PrivateIpAddress, Status:Attachment.Status, attachedTo:Attachment.InstanceId}' --output table

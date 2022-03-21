#!/usr/bin/env bash

dry_run=1
echo_progress=1

d=$(date +'%Y-%m-%d' -d '2 year ago')

snapshots_to_delete=$(aws ec2 describe-snapshots --query 'Snapshots[?StartTime<'$d'].SnapshotId' --output text)
echo "List of snapshots to delete: $snapshots_to_delete"

# actual deletion
for snap in $snapshots_to_delete; do
  echo "aws ec2 delete-snapshot --snapshot-id $snap"
done

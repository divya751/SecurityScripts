aws ecr describe-repositories --output text | awk '{print $5}' | cut -d "/" -f 2-5 | while read line; do  echo $line; aws ecr list-images --repository-name $line --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output text | while read imageId; do echo $imageId; done; done
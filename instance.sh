#!/bin/bash

SG_ID=""
AMI_ID=""

for instance in $@
do

INSTANCE_ID=$( 
	aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
	--query 'Instances[0].InstanceId' \
    --output text )
    
    if [ $instance == 'frontend' ]; then
        ip=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text 
        )
    else
        ip=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text 
        )
    fi
done

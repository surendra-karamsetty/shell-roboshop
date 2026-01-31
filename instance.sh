#!/bin/bash

SG_ID="sg-0b9f1fbcf18f4096e"
AMI_ID="ami-0220d79f3f480ecf5"
HOSTED_ZONE_ID="Z01190221Q8O9S5K8BHJE"
DOMINE_NAME="venkata.online"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
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
        RECORD_NAME="$DOMINE_NAME" #venkata.online
    else
        ip=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text 
        )
        RECORD_NAME="$instance.$DOMINE_NAME" #mongodb.venkata.online
    fi
    echo "Ip address $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch '
{
    "Comment": "Update a record set",
    "Changes": [
        {
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "'$RECORD_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [
            { "Value": "'$IP'" }
            ]
        }
        }
    ]
    }
'
    echo "Record updated for $instance"


done

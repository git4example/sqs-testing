#!/bin/bash

echo "Start Putting Metrics.." 
while true; do 
    myvalue=$(aws sqs get-queue-attributes --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages --query 'Attributes.ApproximateNumberOfMessages' --output text)
    echo "Put Metrics" $myvalue
    aws cloudwatch put-metric-data --metric-name MySQSBacklogPerTask --namespace MySQSNamespace --unit Percent --value $myvalue
    echo "Wait 60 sec"
    sleep 60
done
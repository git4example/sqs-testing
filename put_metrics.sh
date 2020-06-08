#!/bin/bash

echo "Put Metrics" 
while [1]; do                                                                                                                                       ✔  7s   
value=$(aws sqs get-queue-attributes --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages --query 'Attributes.ApproximateNumberOfMessages' --output text)
echo "Put Metrics" $value
aws cloudwatch put-metric-data --metric-name MySQSBacklogPerTask --namespace MySQSNamespace --unit Count --value $value
sleep 60
done
#!/bin/bash

echo "Processing for" $1 "message(s)"
export AWS_DEFAULT_REGION=ap-southeast-2

for ((i=1;i<=$1;i++));
do

message=$(aws sqs receive-message --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS)
#echo $message


if [ ! -n "$message" ]
then
  echo "No messages found, do nothing"
else
  echo "Process message " $i "& wait 30 sec to delete message"
  Body=$(echo $message | jq -r '.Messages[0].Body')
  Handle=$(echo $message | jq -r '.Messages[0].ReceiptHandle')

  echo "Body:" $Body
  echo "ReceiptHandle:" $Handle
  echo "sleeping 30"
  sleep 30

  success=$(aws sqs delete-message --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --receipt-handle $Handle)

  echo "Sucessfully deleted : " $Body
fi

done

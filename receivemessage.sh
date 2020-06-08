#!/bin/bash

echo "Processing for" $1 "message(s)"
export AWS_DEFAULT_REGION=ap-southeast-2

if [ ! -n "$NO_MESSAGES_TO_PROCESS" ]
then
  echo "No of messages to process set to default 1"
  export NO_MESSAGES_TO_PROCESS=1
else 
  echo "No of messages to process set to " $NO_MESSAGES_TO_PROCESS
fi

if [ ! -n "$WAIT_TIME_TO_PROCESS_MESSAGE" ]
then
  echo "Wait time to process message set to default 30"
  export WAIT_TIME_TO_PROCESS_MESSAGE=30
else
  echo "Wait time to process message set to " $WAIT_TIME_TO_PROCESS_MESSAGE
else 

fi

if [ ! -n "$WAIT_BEFORE_NEXT_MESSAGE" ]
then
  echo "Wait time to process next message set to default 30"
  export WAIT_BEFORE_NEXT_MESSAGE=30
else
  echo "Wait time to process next message set to " $WAIT_BEFORE_NEXT_MESSAGE
fi


for ((i=1;i<=$NO_MESSAGES_TO_PROCESS;i++));
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
  echo "sleeping for " $WAIT_TIME_TO_PROCESS_MESSAGE
  sleep $WAIT_TIME_TO_PROCESS_MESSAGE

  success=$(aws sqs delete-message --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --receipt-handle $Handle)

  echo "Sucessfully deleted : " $Body
  sleep $WAIT_BEFORE_NEXT_MESSAGE
fi

done

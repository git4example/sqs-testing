#!/bin/bash
export AWS_DEFAULT_REGION=ap-southeast-2
echo $1

if [ ! -n "$NO_MESSAGES_TO_SEND" ]
then
  echo "No of messages to send set to default 1"
  export NO_MESSAGES_TO_SEND=1
else 
  echo "No of messages to send set to " $NO_MESSAGES_TO_SEND
fi

for ((i=1;i<=$NO_MESSAGES_TO_SEND;i++));
do

message=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10 | xargs)
echo "Sending message number " $i " to the queue :" $message
aws sqs send-message --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --message-body $message

done

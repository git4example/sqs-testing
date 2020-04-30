#!/bin/bash

echo $1

for ((i=0;i<$1;i++));
do

message=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10 | xargs)
echo "Sending message number " $i " to the queue :" $message
aws sqs send-message --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --message-body $message

done

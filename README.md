# sqs-testing

How to run : 
```
run ./receivemessage.sh <number of message>

run ./sendmessage.sh <number of message>
```
Build docker :
```
git clone https://github.com/hello2parikshit/sqs-testing.git

cd sqs-testing

docker build -t hello2parikshit/sqs-testing .      

docker push hello2parikshit/sqs-testing 
```

By default try to receive 1 message and 30 sec process time and 30 sec wait before next: 
```
docker run -it -e NO_MESSAGES_TO_PROCESS=10 -e WAIT_TIME_TO_PROCESS_MESSAGE=30 -e WAIT_BEFORE_NEXT_MESSAGE=60 hello2parikshit/sqs-testing 
```
Else use to send messages to the sqs, default 1 message : 
```
docker run -it -e NO_MESSAGES_TO_SEND=10 --entrypoint ./sendmessage.sh hello2parikshit/sqs-testing 
```

# How to create Target tracking ECS service autoscaling based on custom metrics, SQS Message queue length.


### Get SQS message queue ApproximateNumberOfMessages attribute 
```bash
aws sqs get-queue-attributes --queue-url 	https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages
```

```json
{
    "Attributes": {
        "ApproximateNumberOfMessages": "10"
    }
}
```

###  Describe ECS service
```bash
aws ecs describe-services --cluster CapacityProviderCluster  --service receive
```

### Create application auto-scaling target tracking policy based on custom metrics for ECS service
```bash
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/CapacityProviderCluster/receive \
    --policy-name sqs-target-tracking-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration file://config.json
```

### config.json
```json
{
    "TargetValue":1.0,
    "CustomizedMetricSpecification":{
        "MetricName":"MySQSBacklogPerTask",
        "Namespace":"MySQSNamespace",
        "Statistic":"Average",
        "Unit":"Count"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 60
}
```

### Delete default target tracking policy for ECS Service 
```bash
aws application-autoscaling delete-scaling-policy --policy-name cpu_target --scalable-dimension ecs:service:DesiredCount --resource-id service/CapacityProviderCluster/receive --service-namespace ecs
```

# Create custom metric and set ECS Target tracking based on SQS messages queue length : 

### Now Put custom metric every 1 min : 
```bash
while sleep 60; do 
value=$(aws sqs get-queue-attributes --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages --query 'Attributes.ApproximateNumberOfMessages' --output text)
echo "Put Metrics" $value
aws cloudwatch put-metric-data --metric-name MySQSBacklogPerTask --namespace MySQSNamespace --unit Count --value $value;
done
```

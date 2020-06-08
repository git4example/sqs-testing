# Create custom metric and set ECS Target tracking based on SQS messages queue length : 

### Get SQS message queue ApproximateNumberOfMessages attribute 
```bash
aws sqs get-queue-attributes --queue-url 	https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages
```

```json
{
    "Attributes": {
        "ApproximateNumberOfMessages": "879"
    }
}
```

###  Describe ECS service
```bash
aws ecs describe-services --cluster CapacityProviderCluster  --service receive
```

### Create application auto0-scaling policy to the ECS service 
```bash
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/CapacityProviderCluster/receive \
    --policy-name sqs-target-tracking-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration file://config.json
```

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

# Now Put custom metric every 1 min : 
```bash
while sleep 60; do 

aws cloudwatch put-metric-data --metric-name MySQSBacklogPerTask --namespace MySQSNamespace --unit None --value $(aws sqs get-queue-attributes --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages --query 'Attributes.ApproximateNumberOfMessages' --output text);

done
```

# sqs-testing

### How to run : 
```
run ./receivemessage.sh <number of message>

run ./sendmessage.sh <number of message>
```

### Build docker :
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

ECS Target tracking based on SQS messages queue length

### Get SQS message queue ApproximateNumberOfMessages attribute 
```bash
aws sqs get-queue-attributes --queue-url https://sqs.ap-southeast-2.amazonaws.com/064250592128/SQS4ECS --attribute-names ApproximateNumberOfMessages
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

```json
{
    "services": [
        {
            "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/CapacityProviderCluster/receive",
            "serviceName": "receive",
            "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/CapacityProviderCluster",
            "loadBalancers": [],
            "serviceRegistries": [],
            "status": "ACTIVE",
            "desiredCount": 0,
            "runningCount": 0,
            "pendingCount": 0,
            "capacityProviderStrategy": [
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2c",
                    "weight": 1,
                    "base": 0
                },
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2b",
                    "weight": 1,
                    "base": 0
                },
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2a",
                    "weight": 1,
                    "base": 0
                }
            ],
            "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/sqs-receivemessage:5",
            "deploymentConfiguration": {
                "maximumPercent": 200,
                "minimumHealthyPercent": 100
            },
            "deployments": [
                {
                    "id": "ecs-svc/8948913316662804029",
                    "status": "PRIMARY",
                    "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/sqs-receivemessage:5",
                    "desiredCount": 0,
                    "pendingCount": 0,
                    "runningCount": 0,
                    "createdAt": "2020-06-08T17:51:37.826000+10:00",
                    "updatedAt": "2020-06-08T17:51:41.556000+10:00",
                    "capacityProviderStrategy": [
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2c",
                            "weight": 1,
                            "base": 0
                        },
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2b",
                            "weight": 1,
                            "base": 0
                        },
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2a",
                            "weight": 1,
                            "base": 0
                        }
                    ]
                }
            ],
            "events": [
                {
                    "id": "41f9008a-42e1-4398-8818-1f982fce79b3",
                    "createdAt": "2020-06-08T17:51:41.563000+10:00",
                    "message": "(service receive) has reached a steady state."
                }
            ],
            "createdAt": "2020-06-08T17:51:37.826000+10:00",
            "placementConstraints": [],
            "placementStrategy": [
                {
                    "type": "spread",
                    "field": "attribute:ecs.availability-zone"
                },
                {
                    "type": "spread",
                    "field": "instanceId"
                }
            ],
            "schedulingStrategy": "REPLICA",
            "enableECSManagedTags": true,
            "propagateTags": "NONE"
        }
    ],
    "failures": []
}
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
    "TargetValue":100,
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

###  Describe ECS service
```bash
aws ecs describe-services --cluster CapacityProviderCluster  --service receive
```

```json
{
    "services": [
        {
            "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/CapacityProviderCluster/receive",
            "serviceName": "receive",
            "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/CapacityProviderCluster",
            "loadBalancers": [],
            "serviceRegistries": [],
            "status": "ACTIVE",
            "desiredCount": 0,
            "runningCount": 0,
            "pendingCount": 0,
            "capacityProviderStrategy": [
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2c",
                    "weight": 1,
                    "base": 0
                },
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2b",
                    "weight": 1,
                    "base": 0
                },
                {
                    "capacityProvider": "CapacityProvider-pvt-ap-southeast-2a",
                    "weight": 1,
                    "base": 0
                }
            ],
            "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/sqs-receivemessage:5",
            "deploymentConfiguration": {
                "maximumPercent": 200,
                "minimumHealthyPercent": 100
            },
            "deployments": [
                {
                    "id": "ecs-svc/8948913316662804029",
                    "status": "PRIMARY",
                    "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/sqs-receivemessage:5",
                    "desiredCount": 0,
                    "pendingCount": 0,
                    "runningCount": 0,
                    "createdAt": "2020-06-08T17:51:37.826000+10:00",
                    "updatedAt": "2020-06-08T17:51:41.556000+10:00",
                    "capacityProviderStrategy": [
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2c",
                            "weight": 1,
                            "base": 0
                        },
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2b",
                            "weight": 1,
                            "base": 0
                        },
                        {
                            "capacityProvider": "CapacityProvider-pvt-ap-southeast-2a",
                            "weight": 1,
                            "base": 0
                        }
                    ]
                }
            ],
            "events": [
                {
                    "id": "41f9008a-42e1-4398-8818-1f982fce79b3",
                    "createdAt": "2020-06-08T17:51:41.563000+10:00",
                    "message": "(service receive) has reached a steady state."
                }
            ],
            "createdAt": "2020-06-08T17:51:37.826000+10:00",
            "placementConstraints": [],
            "placementStrategy": [
                {
                    "type": "spread",
                    "field": "attribute:ecs.availability-zone"
                },
                {
                    "type": "spread",
                    "field": "instanceId"
                }
            ],
            "schedulingStrategy": "REPLICA",
            "enableECSManagedTags": true,
            "propagateTags": "NONE"
        }
    ],
    "failures": []
}
```

# Put custom metric : 

### Now Put custom metric every 1 min : 

Use put_metrics.sh script to post metrics every 60 sec.



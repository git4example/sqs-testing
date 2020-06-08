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

# sqs-testing

How to run : 
run ./receivemessage.sh <number of message>
run ./sendmessage.sh <number of message>

Build docker :
git clone https://github.com/hello2parikshit/sqs-testing.git

cd sqs-testing
docker build -t hello2parikshit/sqs-testing .      
docker push hello2parikshit/sqs-testing 

By default try to receive 1 message and process it : 
docker run -it hello2parikshit/sqs-testing 

Else use to send messages to the sqs : 
docker run -it --entrypoint ./sendmessage.sh hello2parikshit/sqs-testing  <number of message>

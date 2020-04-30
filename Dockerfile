FROM hello2parikshit/amazonlinux
WORKDIR /
COPY ./receivemessage.sh .
COPY ./sendmessage.sh .

CMD ["./receivemessage.sh","1"]

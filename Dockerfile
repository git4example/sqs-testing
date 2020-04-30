FROM amazonlinux

RUN yum -y update

RUN yum -y install iputils bind-tools curl nmap-ncat wget vim nano coreutils util-linux iproute2 iptables apache2-utils jq tcpdump unzip

#awscli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

CMD ["/bin/bash"]
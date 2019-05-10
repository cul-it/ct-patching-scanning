FROM python:3.6

# run some updates and set the timezone to eastern
# also install jq json viewer (https://stedolan.github.io/jq/)
# example jq usage: aws ec2 describe-instances | jq
RUN apt-get clean && apt-get update && apt-get -qy upgrade \
    && apt-get -qy install locales tzdata apt-utils software-properties-common build-essential python3 nano graphviz \
    && locale-gen en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get -qy install jq

RUN pip3 install --upgrade pip \
    && pip3 install boto3 awscli awscli-login

# clean up after ourselves, keep image as lean as possible
RUN apt-get remove -qy --purge software-properties-common \
    && apt-get autoclean -qy \
    && apt-get autoremove -qy --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/bin/bash" ]

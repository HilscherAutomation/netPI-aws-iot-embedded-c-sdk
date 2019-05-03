#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:stretch

#dynamic build arguments coming from the /hooks/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/HilscherAutomation/netPI-aws-iot-embedded-c-sdk" \
      org.label-schema.vcs-ref=$VCS_REF

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

#version
ENV HILSCHERNETPI_AW_IOT_EMBEDDED_C_SDK 1.0.2


#labeling
LABEL maintainer="netpi@hilscher.com" \
      version=$HILSCHERNETPI_AW_IOT_EMBEDDED_C_SDK \
      description="Amazon AWS IoT Embedded C SDK"

#copy files
COPY "./init.d/*" /etc/init.d/

RUN apt-get update \
    && apt-get install -y openssh-server \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd \
    && apt-get install -y --no-install-recommends \
                nano \
                build-essential \
                git \
                cmake \
                autoconf \
                automake \
                libtool \
                unzip

#get C SDK sources
RUN git clone https://github.com/aws/aws-iot-device-sdk-embedded-C.git -b release

WORKDIR aws-iot-device-sdk-embedded-C

#compile CppUTest and make available to SDK
RUN cd external_libs/ \
    && rm -r CppUTest \
    && git clone git://github.com/cpputest/cpputest.git --branch v3.8 CppUTest \
    && cd CppUTest/cpputest_build \
    && autoreconf .. -i \
    && ../configure \
    && make \
    && cp -r /lib/* ../src/CppUTest/

#make TLS source code available to SDK 
RUN cd external_libs/ \
    && rm -r mbedTLS \
    && git clone https://github.com/ARMmbed/mbedtls mbedTLS

#compile IotSDKC
RUN make -f Makefile

#setup thing "MyRaspberryPi" and precompile sample application
RUN apt-get install python \
    && cd samples/linux/subscribe_publish_sample \
    && sed -i 's@443@8883@g' -i aws_iot_config.h \
    && sed -i 's@"c-sdk-client-id"@"MyRaspberryPi"@g' -i aws_iot_config.h \
    && sed -i 's@"AWS-IoT-C-SDK"@"MyRaspberryPi"@g' -i aws_iot_config.h \
    && sed -i 's@"cert.pem"@"MyRaspberryPi.cert.pem"@g' -i aws_iot_config.h \
    && sed -i 's@"privkey.pem"@"MyRaspberryPi.private.key"@g' -i aws_iot_config.h \
    && make -f Makefile

#remove package lists
RUN rm -rf /var/lib/apt/lists/*

# change default shell folder
RUN echo "cd /aws-iot-device-sdk-embedded-C" >> /root/.bashrc

# get root CA certificate
RUN curl https://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem -o /aws-iot-device-sdk-embedded-C/certs/rootCA.crt

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#SSH port
EXPOSE 22

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]

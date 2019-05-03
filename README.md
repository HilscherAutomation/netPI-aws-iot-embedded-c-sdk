## Amazon AWS IoT Embedded C SDK 

[![](https://images.microbadger.com/badges/image/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk.svg)](https://microbadger.com/images/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk "Amazon AWS IoT Embedded C SDK")
[![](https://images.microbadger.com/badges/commit/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk.svg)](https://microbadger.com/images/hilschernetpi//netpi-amazon-aws-iot-embedded-c-sdk "Amazon AWS IoT Embedded C SDK")
[![Docker Registry](https://img.shields.io/docker/pulls/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk.svg)](https://registry.hub.docker.com/u/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk/)&nbsp;
[![Image last updated](https://img.shields.io/badge/dynamic/json.svg?url=https://api.microbadger.com/v1/images/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk&label=Image%20last%20updated&query=$.LastUpdated&colorB=007ec6)](http://microbadger.com/images/hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk "Image last updated")&nbsp;

Made for [netPI](https://www.netiot.com/netpi/), the Raspberry Pi 3B Architecture based industrial suited Open Edge Connectivity Ecosystem

### Debian with AWS IoT Embedded C SDK, sample app, SSH server and user root

The image provided hereunder deploys a container with installed AWS IoT Embedded C SDK and a ready-to-compile sample application connecting to your personal AWS IoT after a short setup of some credentials.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), created user 'root' and precompiled SDK as described in [Amazon's Using the AWS IoT Embedded C SDK Tuturial](https://docs.aws.amazon.com/iot/latest/developerguide/sdk-tutorials.html). The SDK's source code the image pulls the files from is located here: https://github.com/aws/aws-iot-device-sdk-embedded-C. There are also other SDKs available to write applications for node.js, java or python, but those come not preinstalled in the image.

First you have to sign up with Amazon Web Services and create an account (free) before the sample can be used. At the time of image preparation Amazon offered a 12 month free trial period which makes trying out this image much easier. This may change in future.

After signing up read this [Developer Guide](https://docs.aws.amazon.com/iot/latest/developerguide/) carefully to get knowledge about AWS IoT and its possibilites. This README just describes roughly what to do below stepwise.

#### Container prerequisites

##### Port mapping

For remote login to the container across SSH the container's SSH port `22` needs to be mapped to any free netPI host port.

#### Getting started

STEP 1. Open netPI's website in your browser (https).

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under *Containers > + Add Container*

Parameter | Value | Remark
:---------|:------ |:------
*Image* | **hilschernetpi/netpi-amazon-aws-iot-embedded-c-sdk**
*Port mapping* | *host* **22** -> *container* **22** | *host*=any unused
*Restart policy* | **always**

STEP 4. Press the button *Actions > Start/Deploy container*

Pulling the image may take a while (5-10mins). Sometimes it may take too long and a time out is indicated. In this case repeat STEP 4.

#### Accessing

The container starts the SSH server automatically when started. Open a terminal connection to it with an SSH client such as [putty](http://www.putty.org/) using netPI's IP address at your mapped port.

Use the credentials `root` as user and `root` as password when asked and you are logged in as root user `root` to the SDK's folder `/aws-iot-device-sdk-embedded-C`. From there you can begin your work.

Before compiling and using the sample follow the [Creating an IoT Thing on Raspberry Pi Tutorial](https://docs.aws.amazon.com/iot/latest/developerguide/sdk-tutorials.html#iot-sdk-create-thing) first followed by a [Common Raspberry Pi Tutorial](https://docs.aws.amazon.com/iot/latest/developerguide/iot-embedded-c-sdk.html).

Find below a short list of to do's. For details read the tutorials mentioned before.

##### AWS IoT Web Management Console to do's

STEP 1: In the AWS IoT Core console navigate to `Onboard/Configuring a device` and click `Get Started`.

STEP 2: Click `Get started` and choose as platform `Linux/OSX`.

STEP 3: Click `Node.js` as AWS IoT Device SDK (even if this image is using the C SDK).

STEP 4: Before clicking `Next` recognize the public internet port -port 8883(MQTT)- the connection will go across in the last line of the page.

STEP 5: Now name your IoT device (object) during registration. Use the value "MyRaspberryPi" here as it is the preconfigured value in the SDK. Of course you can name it as you want, but this needs adaptions in the SDK's header file `aws_iot_config.h` later.

STEP 6: Download the offered connection kit `connect_device_package.zip` as zip file containing all the certificates. Remember the certificate and key name to configured the SDK later correctly before compilation.

STEP 7: The next explained steps (chmod, ./start.sh) when you clicked `Next` can be ignored since they are only relevant for the `Node.js` SDK that we are not using here. Click `finish` and you have successfully downloaded your personal SDK connection package.

AWS IoT Core web services are provided by socalled Endpoints around the whole world. Location in the US, Europe and Asian region are available. For best performances between your IoT device and the web services it is recommended to use an Endpoint close to your location. 

To get your personal API Endpoint reference click `Settings` in your AWS IoT Core console. Depending on which location you have selected (drop down box in the window's top bar) the page provides you an ASCII string e.g. "a3sk6gw01vwcn8.iot.us-west-2.amazonaws.com" of your personal Rest API Endpoint. Remember the value since it is needed later for the SDK to set up a reference to let your IoT device communicate to your personal AWS.

##### netPI SDK to do's

STEP 1: Copy the connection kit zip file `connect_device_package.zip` to the container using an sftp program like Filezilla or WinSCP.

STEP 2: Extract the connection kit to the SDK's folder `/certs` using the command `unzip connect_device_package.zip`.

STEP 3: In the container navigate to SDK's folder `/samples/linux/subscribe_publish_sample/`.

STEP 4: Enter your previously received Rest API Endpoint value in the header file `aws_iot_config.h` in line `#define AWS_IOT_MQTT_HOST` as it is empty `""` by default.

STEP 5: In the same header file modify the values `#define AWS_IOT_CERTIFICATE_FILENAME "..."` and `#define AWS_IOT_PRIVATE_KEY_FILENAME "..."` (default myraspberrypi.cert.pem, myraspberry.private.key) to the given certificate names named in accordance to your IoT device defined before.

STEP 6: Compile the sample with `make -f Makefile` in the folder `/samples/linux/subscribe_publish_sample/` and then call `./subscribe_publish_sample` when finished to call the compiled executeable.

STEP 7: Watch the sample connecting to your AWS IoT and publishing an incrementing counter to the MQTT topic `sdkTest/sub` periodically.

STEP 8: In the AWS console use the embedded MQTT Client to subscribe to the topic `sdkTest/sub` and watch the values published.

#### Automated build

The project complies with the scripting based [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build the image output file. Using this method is a precondition for an [automated](https://docs.docker.com/docker-hub/builds/) web based build process on DockerHub platform.

DockerHub web platform is x86 CPU based, but an ARM CPU coded output file is needed for Raspberry systems. This is why the Dockerfile includes the [balena.io](https://balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/) steps.

#### License

View the license information for the software in the project. As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com

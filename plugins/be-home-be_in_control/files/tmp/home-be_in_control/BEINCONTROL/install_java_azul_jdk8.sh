#!/bin/bash

# Adapted from:
# https://github.com/openhab/openhab-docker/blob/master/2.3.0/armhf/debian/Dockerfile

JAVA_URL="https://www.azul.com/downloads/zulu/zdk-8-ga-linux_aarch32hf.tar.gz"
JAVA_HOME='/usr/lib/java-8'

sudo apt-get install ca-certificates

wget -O /tmp/java.tar.gz "${JAVA_URL}" && \
    sudo mkdir "${JAVA_HOME}" && \
    sudo tar --exclude='demo' --exclude='sample' --exclude='src.zip' -xvf /tmp/java.tar.gz --strip-components=1 -C "${JAVA_HOME}" && \
    rm /tmp/java.tar.gz && \
    sudo update-alternatives --install /usr/bin/java java   "${JAVA_HOME}/bin/java"  50 && \
    sudo update-alternatives --install /usr/bin/javac javac "${JAVA_HOME}/bin/javac" 50

#!/bin/bash

IP_MANAGER=$1
AGENT_TYPE=$2
HOST_INTERFACE=$3

echo $IP_MANAGER" confirmed. Continue.";
echo $AGENT_TYPE" confirmed. Continue.";
echo $HOST_INTERFACE" confirmed. Continue.";

echo -e "Applying configurations and starting the build process. 
It should take 5-7 mins to build depending on your internet speed and hardware."

sleep 1
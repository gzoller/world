#!/bin/bash

extra=""
if [ ! -z "$1" ]; then
  extra="-v $1:/extra"
fi

HOST_IP=`ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}'`

# TODO: If HOST_IP not passed in, assume AWS and hit AWS's host-getter URL
#
docker run -it -P -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=$HOST_IP $extra gzoller/world

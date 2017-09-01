#!/bin/bash

extra=""
if [ ! -z "$1" ]; then
  extra="-v $1:/extra"
fi

# This works on a Mac.  Mileage may vary on other *nix systems
HOST_IP=`ifconfig en0 | awk '$1 == "inet" {print $2}'`

# TODO: If HOST_IP not passed in, assume AWS and hit AWS's host-getter URL
#
docker run -it -P -v /var/run/docker.sock:/var/run/docker.sock -v ~/.docker/machine/certs:/mnt/certs -e "DOCKER_TLS_VERIFY=true" -e HOST_IP=$HOST_IP $extra gzoller/world

#!/bin/bash

extra=""
if [ -d $1 ]; then
  extra="-v $1:/extra"
fi

docker run -d -p 80:80 -p 5672:5672 -p 15672:15672 -p 27017:27017 -p 28017:28017 -p 11211:11211 -e HOST_IP=`docker-machine ip default` $extra gzoller/world

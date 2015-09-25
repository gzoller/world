#!/bin/bash

dbpath=""
extra=""
while getopts "e:i:" flag; do
  case $flag in
    i)
      dbpath="-v $OPTARG:/import";
      ;;
    e)
      extra="-v $OPTARG:/extra";
      ;;
  esac
done

docker run -d -p 80:80 -p 5672:5672 -p 15672:15672 -p 27017:27017 -p 28017:28017 -p 11211:11211 -e HOST_IP=`docker-machine ip default` $dbpath $extra gzoller/world

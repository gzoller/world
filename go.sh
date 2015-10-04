#!/bin/bash

extra=""
if [ ! -z "$1" ]; then
  extra="-v $1:/extra"
fi

CID="$(docker run -d -P -e HOST_IP=`docker-machine ip default` $extra gzoller/world)"

# 1. Get docker-machine name
DMNAME="$(echo `docker info`| sed 's/.*Name\: \([a-zA-Z0-9_]*\).*/\1/')"

# 2. Get IP for this docker-machine
DMIP="$(docker-machine ip $DMNAME)"

# 3. Figure out port mappings, esp. the HTTP port
HttpPort="$(echo `docker port $CID 80` | sed 's/.*\:\([0-9]*\)/\1/')"
MongoPort="$(echo `docker port $CID 27017` | sed 's/.*\:\([0-9]*\)/\1/')"
RabbitPort="$(echo `docker port $CID 5672` | sed 's/.*\:\([0-9]*\)/\1/')"
MemcachePort="$(echo `docker port $CID 11211` | sed 's/.*\:\([0-9]*\)/\1/')"

# Wait for nginx to come up
curl http://$DMIP:$HttpPort > /dev/null 2>&1
while [ $? -ne 0 ]; do !!; done

# 4. Push port mappings back to World so it can update harness.json
curl --data "http=$HttpPort&mongo=$MongoPort&rabbit=$RabbitPort&memcached=$MemcachePort" http://$DMIP:$HttpPort/portmap.pl> /dev/null 2>&1

echo $CID

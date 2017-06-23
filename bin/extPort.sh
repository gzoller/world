#!/bin/bash

# Get port mappings and parse output into inside outside ports
IID=`hostname`
EXTERNALPORT=`docker port $IID | sed 's/\([0-9]*\).*:\([0-9]*\)/\1 \2/' | grep $1 | sed 's/^[0-9]* \([0-9]*\)/\1/'`
echo $EXTERNALPORT
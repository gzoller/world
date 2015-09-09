#!/bin/bash
docker run -d -p 5672:5672 -p 15672:15672 -p 27017:27017 -p 28017:28017 co/world

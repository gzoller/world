docker run -d -p 80:80 -p 5672:5672 -p 15672:15672 -p 27017:27017 -p 28017:28017 -p 11211:11211 -v /Users/wmy965/git/world/db:/var/lib/mongodb -e HOST_IP=`docker-machine ip default` gzoller/world

# world
A "world server" for server-side development including MongoDB, RabbitMQ, and more.  The beauty of something like this is that you don't need to install all these infrastructure things on your machine so clean-up is instantaneous when you stop the container.

Note: In this stock version data volumes are not saved!  When you stop the container all data stored in MongoDB and other stores will be lost!  This can be a handy thing for QA where you want to forklift in data packs for testing, but may not be what you wish for other kinds of work.  In this case you can mount a persistent volume from your host machine with Docker's -v argument.

## Use
```
git clone https://github.com/gzoller/world
cd world
docker build -t gzoller/world .
```

Now you should have gzoller/world in your docker images.  Use the go.sh script provided to run.  The go.sh script presumes you are using docker-machine.

**Note:**  Mac users will need to open the following ports in VirtualBox in order to use the facilities in the world:

| port  | purpose |
| :------------ |:---------- |
| 80      | www (nginx)
| 5672 | RabbitMQ (AMQP)
| 15672 | RabbitMQ (web admin)
| 27017 | MongoDB
| 28017 | MongoDB (web status)
| 11211 | memcached

To connect to these facilities you'll need to know the IP address for Docker as exposed by your VM.  For docker-machine you can find this by:

```
$ docker-machine ip default
```

On my machine this resolves to 192.168.99.100, so to connect to RabbitMQ's web UI I would point my browser to http://192.168.99.100:15672, and I'd connect to mongodb with 192.168.99.10:27017, and so forth.

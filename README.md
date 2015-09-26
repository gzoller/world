# world
A "world server" for server-side development including MongoDB, RabbitMQ, and more.  The beauty of something like this is that you don't need to install all these infrastructure things on your machine so clean-up is instantaneous when you stop the container.

**Note: In this stock version data volumes are not saved!**  When you stop the container all data stored in MongoDB and other stores will be lost.  This can be a handy thing for QA where you want to forklift in data packs for testing, but may not be what you wish for other kinds of work.  

MongoDB requires disk access that VirtualBox doesn't provide, so using Docker's -v host volume mounting won't work--sadly.  For now your best bet if you want to save data is to commit changes to another image:

```docker commit 3e9ff88a my/imagename```

Hopefully a better fix will be available at some point. 

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

###Augmenting the World
The World server has the ability to pre-load information on startup.  You do this by supplying an optional argument to the go.sh script when you run it.  This argument is a path to a directory formatted as shown below:

    /extra
    	/config
    		app.config
    	/http
    	/mongo
    		dbname1
    			coll1.js
    			coll2.js
    		dbname2
    			coll3.js
    			coll4.js

/extra is the top-level directory you supply (the full path) to the argument:  `go.sh /my/path/extra` 

The config directory contains the app.config file.  This is a comma-separated set of JSON objects which comprise any application-specific configuration you want, in any structure you need.  This information will be inserted into the applications:[ ] array in harness.json, read by your applications on start-up.

The http directory's contents will be dumped into nginx's docroot directory.

The contents of the mongo directory will be pre-loaded into mongo.  The subdirs (dbname1, dbname2) will be the names of the databases used, and coll1.js, coll2.js, etc., will be the collection names.  The contents of the .js files should be compatible with mongoimport (i.e. one JSON object per line)

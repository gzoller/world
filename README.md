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

###Automatic Data Loading
The World server has the ability to auto-detect and auto-load JSON data into MongoDB.  Create a directory, say /home/mydata, which contains subdirectories named after databases you want in MongoDB.  In each subdirectory put a file named after a desired collection with a '.js' suffix.  The format of the data file is the same as acceptable for mongoimport.

For example this structure:

    /home/mydata
    	/users
    		oldUsers.js
    		newUsers.js
    	/customers
    		good.js
    		bad.js

When mounted properly (see below) this will create 2 databases in MongoDB: users and customers.  The users database will then load 2 collections, oldUsers and newUsers, while the customers database will load collections good and bad.

Run go.sh script, passing '-i /home/mydata' (your host's data directory) as a parameter to the script and when the World comes up (and assuming you don't have errors in your structure or JSON) you'll have data loaded automatically!

###Augmenting Application Config
One of the features of the World server is a self-referencing wiring harness available at `http://your_ip/harness.json`.  In this JSON there's an 'applications' section, which is a list of, well, anything you need.

To add content to that section simply create JSON objects in a file called "app.config" and put it in a directory.  Then pass this directory to the -e parameter of go.sh:

    ./go.sh -e /users/me/my/stuff



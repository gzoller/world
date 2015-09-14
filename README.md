# world
A "world server" for server-side development including MongoDB, RabbitMQ, and more.

## Use
git clone https://github.com/gzoller/world
cd world
docker build -t gzoller/world .

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

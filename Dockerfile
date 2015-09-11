# Pull base image.
#FROM dockerfile/rabbitmq
FROM rabbitmq

# Add files.
ADD bin/start /usr/local/bin/
ADD bin/harness.json /usr/share/nginx/www/

# Install RabbitMQ.
#  rabbitmq-plugins enable rabbitmq_management && 
RUN \
  apt-get update && \
  apt-get -y install mongodb && \
  apt-get -y install memcached && \
  apt-get -y install nginx && \
  sed 's/^bind_ip/#bind_ip/' -i /etc/mongodb.conf && \
  sed 's/HOSTIP/$HOST_IP/g' -i /usr/share/nginx/www/harness.json && \
  chmod +x /usr/local/bin/start

# WWW DocRoot
# /usr/share/nginx/www

# Define default command.
CMD ["start"]

# Expose ports.
# - RabbitMQ
EXPOSE 5672
EXPOSE 15672
# - Docker
EXPOSE 28018
EXPOSE 27017
# - memcached
EXPOSE 11211
# - nginx
EXPOSE 80

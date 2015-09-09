#
# CapitalOne Development "World" Dockerfile
# 

# Pull base image.
FROM rabbitmq

# Add files.
ADD bin/start /usr/local/bin/

# Install RabbitMQ.
RUN \
  rabbitmq-plugins enable rabbitmq_management && \
  apt-get update && \
  apt-get -y install mongodb && \
  sed 's/^bind_ip/#bind_ip/' -i /etc/mongodb.conf && \
  chmod +x /usr/local/bin/start

# Define environment variables.
#ENV RABBITMQ_LOG_BASE /data/log
#ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Define mount points.
#VOLUME ["/data/log", "/data/mnesia"]

# Define working directory.
#WORKDIR /data

# Define default command.
CMD ["start"]

# Expose ports.
# - RabbitMQ
EXPOSE 5672
EXPOSE 15672
# - Docker
EXPOSE 28018
EXPOSE 27017
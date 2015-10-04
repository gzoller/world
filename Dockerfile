# Pull base image.
FROM rabbitmq

# Add files.
ADD bin/start /usr/local/bin/
ADD bin/harness.json /var/www/html/
ADD bin/rabbitmq.config /etc/rabbitmq/rabbitmq.config
ADD bin/world_fcgi /etc/nginx/
ADD bin/portmap.pl /var/www/cgi-bin/

# FastCGI setup info from here:
# https://www.linode.com/docs/websites/nginx/nginx-and-perlfastcgi-on-ubuntu-12-04-lts-precise-pangolin

RUN \
  mkdir /tmp/nginx && \
  chmod a+wrx /tmp/nginx && \
  chmod a+wr /var/www/html/harness.json && \
  echo "deb http://ftp.us.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y install jq && \
  apt-get -y install mongodb && \
  apt-get -y install memcached && \
  apt-get -y install nginx spawn-fcgi fcgiwrap && \
  rabbitmq-plugins enable rabbitmq_management && \
  sed 's/^bind_ip/#bind_ip/' -i /etc/mongodb.conf && \
  sed 's/DAEMON_OPTS:-\"--unixSocketPrefix/DAEMON_OPTS:-\"--rest --unixSocketPrefix/' -i /etc/init.d/mongodb && \
  sed 's/^-l 127\.0\.0\.1/#-l 127\.0\.0\.1/' -i /etc/memcached.conf && \
  sed 's/# pass the PHP/include world_fcgi;\n\n\t# pass the PHP/' -i /etc/nginx/sites-available/default && \
  chmod +x /var/www/cgi-bin/portmap.pl && \
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

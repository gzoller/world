FROM ubuntu:16.04
#FROM aibano/ubuntu-java-8

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

# Add files.
ADD bin/start /usr/local/bin/
ADD bin/start-kafka.sh /usr/bin/
ADD bin/start-postgres.sh /usr/bin/
ADD bin/check.sh /usr/local/bin/
ADD bin/harness.json /var/www/html/
ADD bin/extPort.sh /usr/bin/

#--------------------------- Prologue

RUN apt-get update && apt-get install -y --no-install-recommends docker.io ca-certificates wget numactl \
  libc6-i386 gcc gcc-multilib libc6-dev-i386 make \
  jq nginx zookeeper supervisor dnsutils ruby s3cmd \
  && rm -rf /var/lib/apt/lists/*

#---------------------------
# EventStore

ENV ES_VERSION=4.0.1

RUN apt-get update \
    && apt-get install tzdata \
    && apt-get install curl -y \
    && curl -s https://packagecloud.io/install/repositories/EventStore/EventStore-OSS/script.deb.sh | bash \
    && apt-get install eventstore-oss=$ES_VERSION -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /var/lib/eventstore

COPY bin/eventstore.conf /etc/eventstore/


#---------------------------
# Kafka and Zookeeper

ENV DEBIAN_FRONTEND noninteractive
ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.10.2.1
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"
ADD bin/kafka.conf bin/zookeeper.conf /etc/supervisor/conf.d/

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true 

#---------------------------
# Redis

ENV REDIS_VERSION 3.0.7
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.7.tar.gz
ENV REDIS_DOWNLOAD_SHA1 e56b4b7e033ae8dbf311f9191cf6fdf3ae974d1c

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN set -x \
  && gem install fakes3 \
  && mkdir /tmp/nginx \
  && chmod a+wrx /tmp/nginx \
  && chmod a+wr /var/www/html/harness.json \
  && sed 's/root .*\;/root \/var\/www\/html\;/' -i /etc/nginx/sites-available/default \
  && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
  && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
  && mkdir -p /usr/src/redis \
  && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
  && rm redis.tar.gz \
  && make -C /usr/src/redis 32bit \
  && make -C /usr/src/redis install \
  && rm -r /usr/src/redis \
  && wget -q http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz \
  && tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt \
  && echo "auto.create.topics.enable=true" >> /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"/config/server.properties \
  && rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz

#RUN mkdir /data && chown redis:redis /data
VOLUME /data
RUN chown redis:redis /data
WORKDIR /data

#---------------------------
# Postgres

# explicitly set user/group IDs
RUN groupadd -r postgres && useradd -r -g postgres postgres
#RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true 
#  && apt-get purge -y --auto-remove ca-certificates

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

ENV PG_MAJOR 9.6
ENV PG_VERSION 9.6.3-1.pgdg80+1

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
  && apt-get install -y postgresql-common \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get install -y \
    postgresql-$PG_MAJOR=$PG_VERSION \
    postgresql-contrib-$PG_MAJOR=$PG_VERSION \
  && rm -rf /var/lib/apt/lists/*

# make the sample config easier to munge (and "correct by default")
RUN mv -v /usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample /usr/share/postgresql/ \
  && ln -sv ../postgresql.conf.sample /usr/share/postgresql/$PG_MAJOR/ \
  && sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

#ENTRYPOINT ["/docker-entrypoint.sh"]

#---------------------------
# Exports

ENTRYPOINT ["start"]

# Expose ports.
# - nginx
EXPOSE 80
# - redis
EXPOSE 6379
# - kafka (2181 is zookeeper, 9092 is kafka)
EXPOSE 2181 9092
# - fakeS3
EXPOSE 10001
# - Postgres
EXPOSE 5432
# - EventStore
EXPOSE 1113
EXPOSE 2113 

# WWW DocRoot
# /usr/share/nginx/www

FROM aibano/ubuntu-java-8

RUN apt-get update && apt-get install -y --no-install-recommends docker.io vim \
  && rm -rf /var/lib/apt/lists/*

COPY extPort.sh /usr/bin
COPY start /usr/bin
ADD harness.json /var/www/html/

# Expose ports.
EXPOSE 80
EXPOSE 6379
EXPOSE 9092
EXPOSE 2181
EXPOSE 10001
EXPOSE 5432

CMD ["/bin/bash"]

#ENTRYPOINT ["start"]
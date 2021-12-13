#FROM confluentinc/cp-enterprise-replicator:latest
FROM openjdk:11.0.9.1-jre

ARG KAFKA_VERSION=3.0.0
ARG SCALA_VERSION=2.13
ENV username="replicator"
ENV TZ=UTC
ENV PATH=${PATH}:/app/${username}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/bin

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y telnet netcat git jq nano

RUN mkdir -p /app/${username}

RUN groupadd -r ${username} --gid 1000
RUN useradd -ms /bin/bash -r -g ${username} ${username} --uid 1000
RUN usermod -d /app/${username} ${username}

RUN wget https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -P /tmp 
RUN tar -xzvf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /app/${username} 
RUN rm /tmp/* -r
RUN chown ${username}:${username} /app/${username} -R

COPY /config/connect-log4j.properties /app/${username}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config/

RUN chown ${username}:${username} /app/${username}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config/connect-log4j.properties

USER ${username}

# EXPOSE 80
# EXPOSE 443
# EXPOSE 8083
# EXPOSE 9093

# Configurar ambiente
RUN echo "connect-mirror-maker.sh ./config/mm2-config.properties"  >> /app/${username}/.bashrc 

WORKDIR /app/${username}
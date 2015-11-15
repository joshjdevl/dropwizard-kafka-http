FROM ubuntu:trusty
MAINTAINER josh <joshjdevl [at] gmail {dot} com>

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository -y ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast -y install git

RUN add-apt-repository ppa:webupd8team/java
RUN apt-fast update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \
    /usr/bin/debconf-set-selections
RUN apt-fast install -y oracle-java8-installer
RUN apt-fast install -y oracle-java8-set-default


ENV MAVEN_VERSION 3.2.2
ADD https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz
RUN tar xfz /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt

ENV PATH /opt/apache-maven-$MAVEN_VERSION/bin:$PATH

ADD src /tmp/dropwizard-kafka/src
ADD pom.xml /tmp/dropwizard-kafka/pom.xml
RUN cd /tmp/dropwizard-kafka && mvn clean install && mvn package -PalternateBuildDir

ADD kafka-http.yml /etc/dropwizard-kafka/kafka-http.yml

ENV KAFKA_VERSION 0.8.2.2
ENV SCALA_VERSION 2.11
ADD http://apache.mirrors.hoobly.com/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz /tmp/kafka/kafka.tgz
RUN tar xfz /tmp/kafka/kafka.tgz -C /opt

RUN apt-fast -y install supervisor

ADD kafkadropwizard-supervisor.conf /etc/supervisor/conf.d/kafkadropwizard.conf
ADD zookeeper-supervisor.conf /etc/supervisor/conf.d/zookeeper.conf
ADD kafka-supervisor.conf /etc/supervisor/conf.d/kafka.conf

CMD /usr/bin/supervisord && tail -f /dev/null

RUN ln -s /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION /opt/kafka

RUN apt-fast -y install curl

EXPOSE 8080 8081

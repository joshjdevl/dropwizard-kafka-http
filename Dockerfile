FROM ubuntu:trusty
MAINTAINER josh <joshjdevl [at] gmail {dot} com>

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast -y install git

RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \
    /usr/bin/debconf-set-selections
RUN apt-fast install -y oracle-java8-installer
RUN apt-fast install -y oracle-java8-set-default


ENV MAVEN_VERSION 3.2.2
ADD https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz
RUN tar xfz /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt

ENV PATH /opt/apache-maven-$MAVEN_VERSION/bin:$PATH

RUN cd /tmp && git clone https://github.com/joshjdevl/dropwizard-kafka-http
RUN cd /tmp/dropwizard-kafka-http && mvn clean install && mvn package

#CMD cd /tmp/dropwizard-kafka-http && java -jar target/dropwizard-kafka-http-0.0.1-SNAPSHOT.jar server kafka-http.yml

ADD kafka-http.yml /tmp/dropwizard-kafka-http/kafka-http.yml

ADD http://apache.mirrors.hoobly.com/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz /tmp/kafka
RUN tar -xvf /tmp/kafka

RUN apt-get -y install supervisor

ADD kafkarest.conf /etc/supervisor/conf.d/kafkarest.conf
ADD zookeeper.conf /etc/supervisor/conf.d/zookeeper.conf
ADD kafka.conf /etc/supervisor/conf.d/kafka.conf

CMD /usr/bin/supervisord && tail -f /dev/null

EXPOSE 8080 8081

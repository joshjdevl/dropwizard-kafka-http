#!/bin/bash

vagrant ssh brokerOne -c "nohup sh -c '/opt/apache/kafka/bin/kafka-server-start.sh /opt/server.properties &> /tmp/broker.log &'"
sleep 10
vagrant ssh brokerOne -c "nohup sh -c 'cd /vagrant; mkdir -p log; java -jar /vagrant/target/dropwizard-kafka-http-0.0.1-SNAPSHOT.jar server kafka-http.yml &> /vagrant/log/stealthly.log &'"

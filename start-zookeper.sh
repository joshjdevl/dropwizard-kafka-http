#!/bin/bash

vagrant ssh zookeeper -c "nohup sh -c '/opt/apache/kafka/bin/zookeeper-server-start.sh /opt/apache/kafka/config/zookeeper.properties &> /tmp/zk.log'"

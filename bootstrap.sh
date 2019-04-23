#!/bin/bash

# : ${HADOOP_PREFIX:=/usr/local/hadoop}

echo ' # >>> bootstrap.sh : $HADOOP_PREFIX ' $HADOOP_PREFIX

rm /tmp/*.pid

# Arrancamos el ssh
echo ' # >>> bootstrap.sh : Arrancamos el ssh '
/etc/init.d/ssh start

# Arrancamos los servicios de hadoop
echo ' # >>> bootstrap.sh : Arrancamos los servicios de hadoop '
su --command "$HADOOP_PREFIX/sbin/start-all.sh"  --shell /bin/bash hadoop

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
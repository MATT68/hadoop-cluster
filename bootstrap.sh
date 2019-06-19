#!/bin/bash

# : ${HADOOP_PREFIX:=/usr/local/hadoop}

echo ' # >>> bootstrap.sh : $HADOOP_PREFIX ' $HADOOP_PREFIX

# Arrancamos el ssh
echo ' # >>> bootstrap.sh : Arrancamos el ssh '
/etc/init.d/ssh start

# Los siguientes comandos se deben lanzar como usuario hadoop
#
echo ' ###>>> Si arranca el master, formatea el cluster y arranca servicios ###  '
echo ' ### $HOSTNAME >> ' $HOSTNAME
if [ "$HOSTNAME" = 'hadoop-master' ]; then
	# Formateamos el cluster
	echo ' ## Formateamos el cluster: hdfs namenode -format ##  '
	sudo -u hadoop $HADOOP_HOME/bin/hdfs namenode -format 
	# Arrancamos todos los demonios
	echo ' ## Arrancamos todos los demonios: start-all.sh ##  '
	sudo -u hadoop $HADOOP_HOME/sbin/start-all.sh
	# Antes de poder usar por primera vez hdfs
	# Inicializamos hdfs creando el directorio /user/hadoop
	echo ' ## Inicializamos hdfs creando el directorio /user/hadoop '
	sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user
	sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hadoop
	#
	# Como parte de la configuracion del cluster
	# copiamos los ficheros de configuarion en el sistema distribuido
	echo ' ## Copiamos los ficheros de configuarion en el sistema distribuido ##  '
	sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -mkdir input
	sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/*.xml input
fi
echo ' >>>>>> Debug >>>>>> : Parametro $1 : ' $1
if [[ $1 == "-d" ]]; then
   while true; do sleep 1000; done
fi
echo ' >>>>>> Debug >>>>>> : Parametro $1 : ' $1
if [[ $1 == "top" ]]; then
   top 
fi
echo ' >>>>>> Debug >>>>>> : Si el parámetro $1 no es "-d" entonmces es : ' $1
if [[ $1 == "-bash" ]]; then
  /bin/bash 
fi

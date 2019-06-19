#!/usr/bin/env /bin/bash
# Levantamos el ssh y rsyslogd
# ( si el ssh no funciona podremos mirar en /var/log/auth.log )
echo ' ###>>> Inicio TareasInicio.sh ###  '
echo ' ## Levantamos el ssh . . . . .  '
/etc/init.d/ssh start
echo ' ## . . . . . . .  y rsyslogd '
# kill -9 $(cat /var/run/rsyslogd.pid)
rsyslogd
# Creamos difectorios para el hdfs-site.xml
echo ' ## Creamos difectorios para el hdfs-site.xml ##  '
echo ' ## /home/hadoop/workspace/dfs/name           ##  '
echo ' ## /home/hadoop/workspace/dfs/data           ##  '
mkdir /home/hadoop/workspace
mkdir /home/hadoop/workspace/dfs
mkdir /home/hadoop/workspace/dfs/name
mkdir /home/hadoop/workspace/dfs/data
chown -R hadoop:hadoop /home/hadoop/workspace

echo ' ###>>>> Fin TareasInicio.sh ###  '
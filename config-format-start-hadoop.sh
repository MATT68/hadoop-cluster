# Los siguientes comandos se deben lanzar como usuario hadoop
#
echo ' ###>>> Inicio config-format-start-hadoop.sh ###  '
# Creamos difectorios para el hdfs-site.xml
echo ' ## Creamos difectorios para el hdfs-site.xml ##  '
echo ' ## /home/hadoop/workspace/dfs/name           ##  '
echo ' ## /home/hadoop/workspace/dfs/data           ##  '
mkdir /home/hadoop/workspace
mkdir /home/hadoop/workspace/dfs
mkdir /home/hadoop/workspace/dfs/name
mkdir /home/hadoop/workspace/dfs/data
# Formateamos el cluster
echo ' ## Formateamos el cluster: hdfs namenode -format ##  '
$HADOOP_HOME/bin/hdfs namenode -format 
# Arrancamos todos los demonios
echo ' ## Arrancamos todos los demonios: start-all.sh ##  '
$HADOOP_HOME/sbin/start-all.sh
# Antes de poder usar por primera vez hdfs
# Inicializamos hdfs creando el directorio /user/hadoop
echo ' ## Inicializamos hdfs creando el directorio /user/hadoop '
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hadoop
#
# Como parte de la configuracion del cluster
# copiamos los ficheros de configuarion en el sistema distribuido
echo ' ## Copiamos los ficheros de configuarion en el sistema distribuido ##  '
$HADOOP_HOME/bin/hdfs dfs -mkdir input
$HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/*.xml input
echo ' ###>>> Fin config-format-start-hadoop.sh ###  '
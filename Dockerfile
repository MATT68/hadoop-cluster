#
#  Author: Matias Andres Perez
#  Date: 2019-04-01
#
#  Desc: Creacion de un pseudo cluster de hadoop. 
#        Partiendo de la imagen base de hadoop (matt68/hadoop-base) hacemos la configuracion y arranque del cluster.
#
#        matt68/hadoop-node:3.2
#
FROM matt68/hadoop-base
LABEL MAINTAINER="Matias Andres (https://www.linkedin.com/in/matias-andres-formador-db2-jcl-datastage-52a46b31/)"

ARG HADOOP_VERSION=3.2.0

USER root
###############################################################################
# INICIO Lineas que deben aparecer en la imagen base : 
# Por un error en la imagen base volvemos a definir el siguiente link simbolico
# RUN rm -f /usr/local/hadoop
# RUN cd /usr/local && ln -s ./hadoop-$HADOOP_VERSION hadoop
# RUN apt-get update && apt-get install -y netbase          
# FIN   Lineas que deben aparecer en la imagen base : 
###############################################################################

# Hacemos sobre la imagen base  
# el resto de configuraciones para iniciar un pseudo cluster hadoop.

# Definimos variables de entorno a usar durante la creacion de la imagen
ENV  JAVA_HOME          /usr/lib/jvm/java-1.8.0-openjdk-amd64 
ENV  PATH               $PATH:$JAVA_HOME/bin    
ENV  HADOOP_HOME        /usr/local/hadoop             
ENV  HADOOP_PREFIX      $HADOOP_HOME                  
ENV  HADOOP_COMMON_HOME $HADOOP_HOME             
ENV  HADOOP_HDFS_HOME   $HADOOP_HOME               
ENV  HADOOP_MAPRED_HOME $HADOOP_HOME             
ENV  HADOOP_YARN_HOME   $HADOOP_HOME               
ENV  HADOOP_CONF_DIR    ${HADOOP_HOME}/etc/hadoop   
ENV  YARN_CONF_DIR      ${HADOOP_PREFIX}/etc/hadoop

# Creamos usuario hadoop y grupo hadoop	
# Y agregamos el user hadoop a los sudoers
RUN groupadd hadoop                        && \
    useradd  hadoop -g hadoop -m -p forma2 && \
	usermod -a -G sudo hadoop

### Exportamos las variables de entorno para el usuario hadoop
### Ya que las variables ENV anteriores no se cargan en el usuario hadoop
USER hadoop:hadoop
# Variables de entorno JAVA
RUN \
 echo ' export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64" ' >> ~/.bashrc && \
 echo ' export PATH="${PATH}:${JAVA_HOME}/bin"                   ' >> ~/.bashrc && \
 echo ' export HADOOP_HOME="/usr/local/hadoop"                   ' >> ~/.bashrc && \
 echo ' export HADOOP_PREFIX=$HADOOP_HOME                        ' >> ~/.bashrc && \
 echo ' export HADOOP_COMMON_HOME=$HADOOP_HOME                   ' >> ~/.bashrc && \
 echo ' export HADOOP_HDFS_HOME=$HADOOP_HOME                     ' >> ~/.bashrc && \
 echo ' export HADOOP_MAPRED_HOME=$HADOOP_HOME                   ' >> ~/.bashrc && \
 echo ' export HADOOP_YARN_HOME=$HADOOP_HOME                     ' >> ~/.bashrc && \
 echo ' export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop         ' >> ~/.bashrc && \
 echo ' export YARN_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop         ' >> ~/.bashrc 

# Modificamos el PATH y volvemos a cargar la shell 
# y agregamos libreria nativa de hadoop (evita WARNING " Unable to load native-hadoop library")
RUN echo "PATH=${PATH}:${HADOOP_HOME}/bin" >> ~/.bashrc    && \
    echo ' ## Agregamos libreria nativa de hadoop '        && \
    echo 'export HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native"' >> ~/.bashrc  

USER root
#  ssh sin password para el root
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key                     && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key                     && \ 
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa                             && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys                         && \   
    chmod 0600 /root/.ssh/authorized_keys                                       
# Copiamos  el fichero config_ssh 
ADD config_ssh.txt /root/.ssh/config

# Copiamos  el fichero con el nombre de los slaves del cluster 
ADD slaves $HADOOP_HOME/etc/hadoop/slaves

# Cambiamos el propietario del dir hadoop
RUN chown hadoop:hadoop /usr/local/hadoop-$HADOOP_VERSION    

USER hadoop
# ssh sin password para usuario hadoop
RUN mkdir  /home/hadoop/.ssh                                         && \
    rm -f /home/hadoop/.ssh/id_rsa /home/hadoop/.ssh/authorized_keys && \ 
    ssh-keygen -t rsa -P '' -f /home/hadoop/.ssh/id_rsa              && \
    cat ~/.ssh/id_rsa.pub >>   /home/hadoop/.ssh/authorized_keys     && \
    chmod 0600 /home/hadoop/.ssh/authorized_keys                     && \
    chown -R hadoop:hadoop /home/hadoop                              
# Copiamos  el fichero config_ssh al user hadoop
ADD --chown=hadoop:hadoop config_ssh.txt /home/hadoop/.ssh/config
  
# Copiamos los ficheros de configuración de hadoop
ADD core-site.xml   $HADOOP_HOME/etc/hadoop/
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/
ADD hdfs-site.xml   $HADOOP_HOME/etc/hadoop/
ADD yarn-site.xml   $HADOOP_HOME/etc/hadoop/

USER root
#Desactivmos IPv6 porque Hadoop no lo admite y Ubuntu lo trae por defecto
RUN echo ' ## Desactivmos IPv6 porque Hadoop no lo admite '               && \ 
    echo 'net.ipv6.conf.all.disable_ipv6 = 1 '     >> /etc/sysctl.conf        && \ 
    echo 'net.ipv6.conf.default.disable_ipv6 = 1 ' >> /etc/sysctl.conf    && \ 
    echo 'net.ipv6.conf.lo.disable_ipv6 = 1 '      >> /etc/sysctl.conf         && \ 
# Actualizamos JAVA_HOME y HADOOP_CONF_DIR en hadoop-env.sh
    sed -i '/export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\n export HADOOP_HOME=${HADOOP_HOME}\n export HADOOP_PREFIX=${HADOOP_PREFIX}:' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh       && \ 
    sed -i '/export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop/:' "$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh"        

# El TareasInicio.sh levanta el ssh 
COPY TareasInicio.sh   /
# Les quitamos a los dos ficheros los caracteres /r que hay al final de cada linea -Fin de linea de Windows -
RUN \ 
    sed -i "s/\r//" /TareasInicio.sh                && \
    /TareasInicio.sh
         
ADD bootstrap.sh /bootstrap.sh
# RUN chmod 700 /etc/bootstrap.sh
# Eliminamos los caracteres /r que hay al final de cada linea -Fin de linea de Windows -
RUN sed -i "s/\r//" /bootstrap.sh 
# En el script bootstrap.sh se formatea el cluster y se lanzan los servicios hadoop
ENTRYPOINT ["/bootstrap.sh", "top"] 
CMD ["-bash"]


# Fijamos el directorio de trabajo 
WORKDIR /home/hadoop
	
EXPOSE  8088 9000 9820 9864 9865 9866 9867 9868 9869  9870 9871 
#!/usr/bin/env /bin/bash
# Levantamos el ssh y rsyslogd
# ( si el ssh no funciona podremos mirar en /var/log/auth.log )
echo ' ###>>> Inicio TareasInicio.sh ###  '
echo ' ## Levantamos el ssh . . . . .  '
/etc/init.d/ssh start
echo ' ## . . . . . . .  y rsyslogd '
# kill -9 $(cat /var/run/rsyslogd.pid)
rsyslogd
# Lanzamos como usuario hadoop el script de configuracion, formateo 
# e inicializacion del cluster hadoop
echo ' ## Lanzamos el script de configuracion de hadoop  ##  '        
echo ' ## config-format-start-hadoop.sh como el usuario "hadoop"  ##  '        
su  --command "/config-format-start-hadoop.sh" --shell /bin/bash  hadoop       
echo ' ## Usuario final al terminar TareasInicio.sh :   ##  '        
whoami
echo ' ###>>>> Fin TareasInicio.sh ###  '
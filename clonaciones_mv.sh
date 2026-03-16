#!/bin/bash
#---Variables---
log="/var/log/scripts/clonaciones_mv/clonaciones_mv.log"
fichero="/var/opt/scripts/clonaciones_mv/clonaciones_mv.txt"
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
echo "-----------"
#--
while IFS=":" read -r id_plantilla id_clon nombre tipo; do
    #--
    if [ "$tipo" = "linked" ]; then
        qm clone $id_plantilla $id_clon --name $nombre --linked 1 > /dev/null 2>&1
    elif [ "$type" = "full" ];then
        qm clone $id_plantilla $id_clon --name $nombre --full 1 > /dev/null 2>&1
    fi
    #--
done < $fichero
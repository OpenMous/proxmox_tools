#!/bin/bash
#---Variables---
log="/var/log/scripts/plantillas_mv/plantillas_mv.log"
fichero="/var/opt/scripts/plantillas_mv/plantillas_mv.txt"
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
echo "-----------"
#--
while IFS=":" read -r id plantilla pools; do
    #--
    if ! qm status $id > /dev/null 2>&1; then
        echo "La mv $id no existe o se ha eliminado" >> $log
        continue
    fi
    #--
    IFS=',' read -ra pool_list <<< "$pools"
    for i in "${pool_list[@]}"; do
        if ! cat /etc/pve/user.cfg | grep -wq -m 1 $i; then
            echo "La pool $i no existía" >> $log
            pvesh create pools -poolid $i > /dev/null 2>&1
        fi
        echo "Apagando maquina $id" >> $log
        qm shutdown $id > /dev/null 2>&1
        echo "Creando plantilla de maquina $id" >> $log
        qm template $id > /dev/null 2>&1
        echo "Asignando de plantilla de la maquina $id a la pool $i" >> $log
        pveum pool modify $i --vms $id --allow-move 1 > /dev/null 2>&1
    done
done < $fichero


#!/bin/bash 
#---Variables---
log="/var/log/scripts/copia_seguridad_pool/copia_seguridad_pool.log"
fichero="/var/opt/scripts/copia_seguridad_pool/copia_seguridad_pool.txt"
bk_creados=""
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
#--
while IFS= read -r pool; do
    if ! pvesh get pools/$pool > /dev/null 2>&1; then
        echo "La pool $pool no existe" >> $log
    else
        vm_ids=$(cat /etc/pve/user.cfg | grep -w $pool cut -d ":" -f4)
        IFS="," read -ra vm_list <<< "$vm_ids"
        for i in "${vm_list[@]}"; do
            if ! qm status $vm_id > /dev/null 2>&1; then
                echo "La mv $vm_id no existe o se ha eliminado" >> $log
            else
                vzdump $vm_id --storage local --compress zstd > /dev/null 2>&1; then
                if [ $? -eq 0 ]; then
                    echo "Se ha creado una copia de seguridad de la maquina $vm_id" >> $log
                    bk_creados="$bk_creados $vm_id"
                else
                    echo "La copia de seguridad de la maquina $vm_id no se ha realiado correctamente" >> $log
                fi
            fi
        done
    fi
done $fichero
echo "Se han creado copias de seguridad de las maquinas $bk_creados"
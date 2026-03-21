#!/bin/bash 
#---Variables---
log="/var/log/scripts/copias_segurdad_vm/copias_segurdad_vm.log"
fichero="/var/opt/scripts/copias_segurdad_vm/copias_segurdad_vm.txt"
bk_creados=""
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
#--
while IFS= read -r vm_id; do
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
done $fichero
echo "Se han creado copias de seguridad de las maquinas $bk_creados"
#!/bin/bash 
#---Variables---
log="/var/log/scripts/usuarios_mv/usuarios_mv.log"
fichero="/var/opt/scripts/usuarios_mv/usuarios_mv.txt"
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
echo "-----------"
#--
while IFS=: read -r user pools; do
    #--
    if ! pveum user list | grep -wq "$usu@pve"; then
        echo "El usuario $user no existia" >> $log
        pveum user add $user@pve --password 'usuario' > /dev/null 2>&1
        echo "Usuario $user añadido" >> $log
    fi
    #--
    IFS=',' read -ra pool_list <<< "$pools"
    for i in "${pool_list[@]}"; do
        echo "Se ha añadido a $usu a la pool $pools" >> $log
        pveum aclmod /pool/$i -user $user@pve -role PVEVMUser > /dev/null 2>&1
        pveum aclmod /pool/$i -user $user@pve -role PVEVMAdmin > /dev/null 2>&1
    done
    #--
done < $fichero
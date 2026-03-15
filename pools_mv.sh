#!/bin/bash 
#---Variables---
log="/var/log/scripts/pools_mv/pools_mv.log"
backup="/tmp/scripts/pools_mv/$(date)"
fichero="/var/opt/scripts/pools_mv/pools_mv.txt"
mvs_movidas=""
#--
echo "-----------"
echo "Se ha ejecutado el script $0 a $(date)" >> $log
echo "Se guardará un backup de el estado actual de las pools en $backup" >> $log
pvesh get /pools > $backup
echo "-----------"
#--
while IFS=: read -r pool vms; do
  #--
  if ! pvesh get pools/$pool > /dev/null 2>&1; then
    pvesh create pools -poolid $pool > /dev/null 2>&1
  fi
  #--
  IFS=',' read -ra vms_list <<< "$vms"
  for i in "${vms_list[@]}"; do
    vms_existentes=$(cat /etc/pve/user.cfg | grep -w $i)
    if ! qm status $i > /dev/null 2>&1; then
      echo "La mv $i no existe o se ha eliminado" >> $log
    else
      if [ $(echo $vms_existentes | cut -d ":" -f 2) = $pool ]; then
        echo "La mv $i ya está en $pool" >> $log
      else
        echo "Traspaso de mv $i a la pool $pool" >> $log
        pvesh set /pools/$pool --vms $if --allow-move 1 > /dev/null 2>&1
        mvs_movidas="$mvs_movidas $i"
      fi
    fi
  done
  #--
done < $fichero
echo "Las maquinas $mvs_movidas se han movido siguiendo el registro en $(echo $fichero)" >> $log
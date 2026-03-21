#!/bin/bash
#----Functions----
menu() {
    clear
    tput cup 0 0
    echo "========= MENÚ PROXMOX ========="
    echo "1. Crear Pool"
    echo "2. Listar Pools"
    echo "3. Crear usuario Proxmox"
    echo "4. Listar usuarios Proxmox"
    echo "5. Asignar usuario a Pool"
    echo "6. Listar Pools de los usuarios"
    echo "7. Crear Plantilla de una MV"
    echo "8. Crear Clonación sobre Plantilla"
    echo "9. Crear copia de seguridad de una MV"
    echo "10. Crear copia de seguridad de una Pool"
    echo "11. Listar copias de seguridad de una Pool"
    echo "12. Listar copias de seguridad de un usuario"
    echo "13. Salir"
    echo "================================"
}
#--
while true; do
    menu
    tput cup 15 0
    read -p "Selecciona una opción: " op
    case $op in
        1)
            read -p "Nombre del pool: " pool
            pvesh create /pools -poolid "$pool"
            ;;
        2)
            pvesh get /pools
            ;;
        3)
            read -p "Usuario: " user
            read -s -p "Password: " pass
            echo
            pveum user add "$user@pveadrian" --password "$pass"
            ;;
        4)
            pveum user list
            ;;
        5)
            read -p "Usuario: " user
            read -p "Pool: " pool
            pvesh set /pools/"$pool" -users "$user@pveadrian"
            ;;
        6)
            pvesh get /pools
            ;;
        7)
            read -p "ID de la VM: " vm_id
            qm template "$vm_id"
            ;;
        8)
            read -p "ID plantilla: " template
            read -p "Nuevo ID VM: " new_id
            read -p "Nombre VM: " name
            read -p "Tipo (full o linked): " type
            if [ $type == "full" ]; then 
                qm clone "$template" "$newid" --name "$name" --full
            else
                qm clone "$template" "$newid" --name "$name"
            fi
            ;;
        9)
            read -p "ID de la VM: " vmid
            vzdump "$vmid" -storage local -compress zstd
            ;;
        10)
            read -p "Nombre del pool: " pool
            if ! pvesh get /pools/"$pool" &> /dev/null; then
                echo "El pool no existe"
            else
                vms=$(pvesh get /pools/"$pool" | grep vmid | awk '{print $2}')
                for vm in $vms; do
                    echo "Backup de VM $vm"
                    vzdump "$vm" -storage local -compress zstd
                done
            fi
            ;;
        11)
            read -p "Nombre del pool: " pool
            ls /var/lib/vz/dump | grep "$pool"
            ;;
        12)
            read -p "Usuario: " user
            grep "$user" /etc/pve/user.cfg
            ;;
        13)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac
    echo
    read -p "Pulsa ENTER para continuar..."
done
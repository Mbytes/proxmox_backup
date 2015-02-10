#!/bin/bash
#

#Backup CONFIGURACION VM MasBytes

ORIGEN=/home/BACKUP/dump

HOST=$(uname -n)
HOY=$(date +%Y%m%d)


#Backup configuracion
rm ${ORIGEN}/backup_sistema_*
tar -cvvzf ${ORIGEN}/backup_sistema_${HOST}_${HOY}.tgz /etc/ /home/prg/

touch /home/prg/mbackup

#Solo realizamos Volcado de maquinas los dias 1
HOY=$(date +%d)

#Forzamos Backup
if test "now" = "$1"
then
 HOY=01
fi

#Es dia 1
if test "${HOY}" = "01"
then

  #Backup OpenVz
  /home/prg/backupVM.sh

  #Backup KVM
  /home/prg/backupKVM.sh
fi

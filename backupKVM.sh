#!/bin/bash
#

#Backup KVM MasBytes

#Mejoras pendientes
#Si esta "stopped" no realizar mas que dias determinados

INISTART=$(date +%s)

#Nombre servidor en Mayusculas y Pwd en Minusculas
USUARIO=$(uname -n | sed 's/\(.*\)/\U\1/')
PASSWORD=$(uname -n)

ORIGEN=/home/BACKUP/dump

HOY=$(date +%Y%m%d)

#Ficheros Temporales
VMID=${ORIGEN}/kvmid.log
VMTIME=${ORIGEN}/kvmid_.backup.log
LISTAVMID=/tmp/kvmid.lista.log

#Borramos logtime viejo
rm ${VMTIME}


#Se realiza desde VM
#Backup configuracion
#rm ${ORIGEN}/backup_sistema_*
#tar -cvvzf ${ORIGEN}/backup_sistema_${HOST}_${HOY}.tgz /etc/ /home/prg/


#Listamos VM existentes
qm list | awk '{print $1}' > ${LISTAVMID}

while read  VMID
do
	if ! test "${VMID}" = "VMID"		#Saltamos linea 1
	then
		
		#Nombre de servidor en Log y en directorio
		HOSTNAME=$(qm list | grep ${VMID} |tail -1 | awk '{print $2}')	
		echo ${HOSTNAME} ${VMID} >> ${VMTIME}
		touch "${ORIGEN}/${VMID}_${HOSTNAME}.txt"
		
		#LOGTIME
		START=$(date +%s)
		FECHA=$(date +%c)
		echo "INICIO ${VMID} -- ${FECHA}" >> ${VMTIME}
		
		#Backup
		#vzdump --mode suspend --stdexcludes --script=/home/prg/backup.script.sh --exclude-path=/home/logs/ --storage BACKUP ${VMID}
		#vzdump --mode suspend --stdexcludes --compress --script=/home/prg/backup.script.sh --exclude-path=/home/logs/ --dumpdir /home/BACKUP ${VMID}
		vzdump --mode suspend --stdexcludes --compress lzo --exclude-path=/home/logs/ --dumpdir ${ORIGEN} ${VMID}

		#LOGTIME VZDUMP END
		END=$(date +%s)
		FECHAFIN=$(date +%c)
		DIFF=$(( $END - $START ))
		echo "DUMP   ${VMID} -- ${DIFF} segundos" >> ${VMTIME}
		
		
		END=$(date +%s)
		FECHAFIN=$(date +%c)
		DIFF=$(( $END - $START ))
		echo "FIN    ${VMID} -- ${FECHAFIN} " >> ${VMTIME}
		echo "TOTAL  ${VMID} = ${DIFF} segundos" >> ${VMTIME}
	
		#Calculo velocidad
		if test ${DIFF} -eq 0
		then
			VELOCIDAD=${FILESIZE}
		else
			VELOCIDAD=$(expr ${FILESIZE} / ${DIFF} )
		fi
	
		#Ajuste Kbytes
		VELOCIDAD=$(expr ${VELOCIDAD} / 1024 )
	
		#echo "${VELOCIDAD} ${FILESIZE} / ${DIFF}" >> ${VMTIME}
		printf "VMID %5s -- %10d segundos - SIZE=%15d - %10d Kbytes/seg \n" ${VMID} ${DIFF} ${FILESIZE} ${VELOCIDAD}  >> ${VMTIME}
	

		echo "============================ " >> ${VMTIME}

	fi
done < ${LISTAVMID}


FINSTART=$(date +%s)
TOTAL=$(( $FINSTART - $INISTART ))
echo "TOTAL BACKUP ${USUARIO} ${TOTAL} Segundos" >> ${VMTIME}




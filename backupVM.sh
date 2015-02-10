#!/bin/bash
#

#Backup VM MasBytes

#Mejoras pendientes
#Si esta "stopped" no realizar mas que dias determinados

INISTART=$(date +%s)

#Nombre servidor en Mayusculas y Pwd en Minusculas
USUARIO=$(uname -n | sed 's/\(.*\)/\U\1/')
PASSWORD=$(uname -n)

ORIGEN=/home/BACKUP/dump

HOST=$(uname -n)

HOY=$(date +%Y%m%d)


#Ficheros Temporales
VMID=${ORIGEN}/vmid.log
VMTIME=${ORIGEN}/vmid.backup.log
LISTAVMID=/tmp/vmid.lista.log

#Borramos logtime viejo
rm ${VMTIME}


#Listamos VM existentes
vzlist -a | awk '{print $1}' > ${LISTAVMID}

while read  VMID
do
	if ! test "${VMID}" = "CTID"		#Saltamos linea 1
	then
	
		#Nombre de servidor en Log y en directorio
		HOSTNAME=$(vzlist -a ${VMID} |tail -1 | awk '{print $5}')	
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




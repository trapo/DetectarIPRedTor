#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
ROJOCLARO='\033[1;31m'
NC='\033[0m'

function BajarDetalleRED {
	if [ ! -f details ]; then
		echo "No existe el archivo de tor details!"
		wget https://onionoo.torproject.org/details
	fi

	mydate=$(ls -all details | awk '{print $8,$7,$10}' | sed 's/ /-/g')

	fechaArchivo=$(date -d $mydate +"%Y-%m-%d")
	fechaActual=$(date +"%Y-%m-%d")

	if [[ "$fechaActual" > "$fechaArchivo" ]]; then
		echo 'Archivo Desactualizado'
		wget https://onionoo.torproject.org/details
	fi

}

function BuscarIP {
	IP=$1

	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e "${BLUE}Detectar ${IP} si es de la red TOR  ${NC}"
	#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	RESULTADO=$(cat details | grep '"or_addresses":\["'$IP)

	if [ "$(cat ipblock.txt | grep $IP)" != "" ]; then
		echo -e "${ORANGE}LA ${IP} INTRODUCIDA YA SE ENCUENTRA EN EL ARCHIVO DE BLOQUEO ipblock.txt${NC}"
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	else

		if
			[ "$RESULTADO" ]
		then
			#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo -e "${RED}${IP} PERTENECE A LA RED TOR${NC}"
			echo $IP >>ipblock.txt
			echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			CONTADORIPTOR=$(expr $CONTADORIPTOR + 1)

		else

			#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo -e "${GREEN}${1} NO PERTENECE A LA RED TOR${NC}"
			echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			CONTADORIPNOTOR=$(expr $CONTADORIPNOTOR + 1)
		fi

	fi

}

IP=$(echo $1 | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

if [ $IP ]; then

	BajarDetalleRED
	BuscarIP "$IP"

else
	if [[ $1 ]]; then
		EXTENSION=$(echo "$1" | cut -d'.' -f2)
		$(rm ips.txt)
		grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" $1 >>ips.txt
		if [[ $EXTENSION == "txt" || $EXTENSION == "log" ]]; then
			BajarDetalleRED
			CONTADORIPTOR=0
			CONTADORIPNOTOR=0
			TOTAL=0
			while IFS= read -r line; do
				#echo "$line"
				V1=$(echo $line | awk -F'.' '{print $1}')
				V4=$(echo $line | awk -F'.' '{print $4}')
				if [[ $V1 != "0" && $V1 != "127" && $V1 != "10" && $V1 != "192" && $V4 != "0" && $V4 != "255" ]]; then
					TOTAL=$(expr $TOTAL + 1)
					BuscarIP "$line"
				fi
			done <ips.txt
			echo -e "${RED} Total IPs Bloqueadas:" $(wc -l ipblock.txt)
			echo -e "${GREEN}CONTADORES :"
			echo -e "${BLUE} -->Total IPs analizadas: $TOTAL "
			echo -e "${RED} -->IPs red Tor: $CONTADORIPTOR "
			echo -e "${GREEN} -->IPs no pertenecientes a la red tor: $CONTADORIPNOTOR ${NC}"

		fi

	else
		echo -e "${BLUE}FORMA DE EJECUCION DEL SCRIPT ./detectariptor2.sh 10.10.10.10 o  ./detectariptor2.sh archivo.log o ./detectariptor2.sh archivo.txt${NC}"
	fi

fi

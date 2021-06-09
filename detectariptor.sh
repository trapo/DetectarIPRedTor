#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

IP=$1
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e "${BLUE} Detectar IP si es de la red TOR ${1} ${NC}"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if [ "$(cat ipblock.txt | grep $IP)" != "" ]; then
    echo -e "${RED}LA IP INTRODUCIDA YA SE ENCUENTRA EN EL ARCHIVO DE BLOQUEO ipblock.txt${NC}"
else
    if [ $IP != "" ]; then

        DATE=$(date '+%Y-%m-%d')
        #echo $DATE
        DATEMENOS=$(date --date='-2 day' +%Y-%m-%d)
        #echo $DATEMENOS

        RESULTADOCURL=$(curl "https://metrics.torproject.org/exonerator.html?ip=$IP&timestamp=$DATEMENOS&lang=en" -m 30 | grep "Result is")
        #echo $RESULTADOCURL

        if
            [ "Result is positive" == "$(echo ${RESULTADOCURL:38:18})" ]
        then
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo -e "${RED}${1} PERTENECE A LA RED TOR${NC}"
            echo $IP >>ipblock.txt
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        else

            if [[ "$(echo $RESULTADOCURL)" == "" ]]; then
                echo -e "${RED}NO SE PUEDE CONECTAR A METRICS TOR PROJECT ${NC}\n \n"
                RESULTADOCURL=$(curl https://www.cual-es-mi-ip.net/geolocalizar-ip-mapa -X POST -H "content-type: application/x-www-form-urlencoded" -d "direccion-ip=$1" -m 3 | grep "Anonymous Proxy" | tr -d "<td>/" | sed "s/srong/ /g")
                if [[ "$(echo $RESULTADOCURL)" == *"Anonymous Proxy"* ]]; then
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                    echo -e "${RED}${1} PERTENECE A LA RED TOR${NC}"
                    echo $IP >>ipblock.txt
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

                else
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                    echo -e "${GREEN}${1} NO PERTENECE A LA RED TOR${NC}"
                    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                fi
            else
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                echo -e "${GREEN}${1} NO PERTENECE A LA RED TOR${NC}"
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            fi

        fi

    else
        echo -e "${BLUE}FORMA DE EJECUCION DEL SCRIPT ./detectariptor.sh 10.10.10.10 ${NC}"

    fi
fi

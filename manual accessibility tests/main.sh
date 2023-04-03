#!/bin/bash

cd /home/tatiana/skrypty/snmp
clear

echo "**********************************************"
echo "*                                            *"
echo "* Konsola testów manualnych sprawności sieci *"
echo "* autorstwa Tatiany Hołycz                   *"
echo "*                                            *"
echo "**********************************************"
echo " "

PS3="Wybierz urządzenie, które chcesz sprawdzić za pomocą protokołu snmp:"

select device in "serwer nas" "serwer wirtualizacji A" "koniec"
do
    case $device in
        "serwer nas")
          bash snmp_nas.sh ;;
        "serwer wirtualizacji A")
          bash snmp_serwerA.sh ;;
        "koniec")
           echo "Testy manualne zostały zakończone"
           break ;;
        *)
           echo "wybrałeś nieprawidłową opcję" ;;
    esac
done
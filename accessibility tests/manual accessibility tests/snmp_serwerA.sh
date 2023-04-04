#!/bin/bash
cd /home/tatiana/skrypty/snmp
clear
echo "**********************************************"
echo "*                                            *"
echo "* Konsola testów manualnych sprawności sieci *" 
echo "* autorstwa Tatiany Hołycz                   *"
echo "* serwer wirtualizacji proxmox A             *"
echo "**********************************************"
echo " "
PS3="wybierz czujnik którego wartość chcesz otrzymać:"

select czujniks in "macierz RAID" "czas funkcjonowania systemu" "koniec"
do
  case $czujniks in
    "macierz RAID")
      RAIDN=$(snmpget -v 2c -c public -O qv 10.20.30.4 .1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.1.1)
      RAIDS=$(snmpget -v 2c -c public -O qv 10.20.30.4 .1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.4.1)
      echo " "
      echo "Ilość macierzy RAID w systemie to: ${RAIDN}"
      echo " "
      if [ $RAIDS == "2" ] 
        then
        echo "Macierz RAID działa poprawnie i jest w stanie ONLINE"
        else
        echo "Macierz RAID nie działa poprawnie i należy sprawdzić jej sprawność"
      fi
      read -n 1 -s -r key
      bash snmp_serwerA.sh ;;          
    "czas funkcjonowania systemu")
      upptime=$(snmpget -v 2c -c public -O qv 10.20.30.4 .1.3.6.1.4.1.674.10892.5.2.5.0)
      upptimes=$(( upptime % 60 ))
      modm=$(( upptime % 3600 ))
      upptimem=$(( modm / 60 ))
      modh=$(( upptime % 86400 ))
      upptimeh=$(( modh / 3600 ))
      modd=$(( upptime - modh ))
      upptimed=$(( modd / 86400 ))
      echo "Czas aktywności systemu to ${upptimed} dni ${upptimeh} godzin ${upptimem} minut ${upptimes} sekund"
      echo "naciśnij dowolny klawisz aby kontynuować"
      read -n 1 -s -r key
      bash snmp_serwerA.sh ;;
    "koniec")
      echo "testy manualne zostały zakończone"
      bash snmp.sh ;;
    *)
      echo "wybrałeś nieprawidłową opcję" ;;
    esac
  done
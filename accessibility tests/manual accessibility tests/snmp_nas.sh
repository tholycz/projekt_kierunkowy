#!/bin/bash
cd /home/tatiana/skrypty/snmp
clear
echo "**********************************************"
echo "*                                            *"
echo "* Konsola testów manualnych sprawności sieci *" 
echo "* autorstwa Tatiany Hołycz                   *"
echo "* serwer nas                                 *"
echo "**********************************************"
echo " "
PS3="wybierz czujnik którego wartość chcesz otrzymać:"

select czujnik in "temperatura HDD" "stan chłodzenia" "stan HDD" "aktualizacje" "koniec"
do
    case $czujnik in
    "temperatura HDD")
    HDD1T=$(snmpget -v 2c -c public -O qv 10.20.31.2 1.3.6.1.4.1.6574.2.1.1.6.0)
    HDD2T=$(snmpget -v 2c -c public -O qv 10.20.31.2 1.3.6.1.4.1.6574.2.1.1.6.1)
    echo " "
    echo "aktualna temperatura dysku twardego nr 1 to: ${HDD1T}"
    echo " "
    echo "aktualna temperatura dysku twardego nr 2 to: ${HDD2T}"
    echo " "
    echo "Naciśnij dowolny klawisz aby powrócić do menu czujników"
    read -n 1 -s -r key
    bash snmp_nas.sh ;;
                
    "stan chłodzenia")
    cpufan=$(snmpget -v 2c -c public -O qv 10.20.31.2  .1.3.6.1.4.1.6574.1.4.2.0)
    sysfan=$(snmpget -v 2c -c public -O qv 10.20.31.2  .1.3.6.1.4.1.6574.1.4.1.0)
    if [ $cpufan == "1" ]
      then
      echo "chłodzenie procesora działa poprawnie"
      echo " "
      else
      echo " "
      echo "chłodzenie procesora działa niepoprawnie"
      echo " "
      fi
    if [ $sysfan == "1" ]
      then
      echo "chłodzenie systemu działa poprawnie"
      echo " "
      else
      echo " "
      echo "chłodzenie systemu działa niepoprawnie"
      echo " "
      fi
      read -n 1 -s -r key
    bash snmp_nas.sh ;;
                
    "stan HDD")
    hdd1s=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.2.1.1.5.0)
    hdd2s=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.2.1.1.5.1)
    if [ $hdd1s == "1" ]
    then
    echo "aktualny stan dysku nr 1 jest poprawny"
    echo " "
    else
    echo " "
    echo "stan dysku nr 1 wymaga uwagi"
    echo " "
    fi
    if [ $hdd2s == "1" ]
    then
    echo "aktualny stan dysku nr 2 jest poprawny"
    echo " "
    else
    echo "stan dysku nr 2 wymaga uwagi"
    echo " "
    fi
    read -n 1 -s -r key
    bash snmp_nas.sh ;;
                
    "aktualizacje")
    sysupp=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.1.5.4.0)
    if [ $sysupp == "0" ]
      then
      echo " "
      echo "system operacyjny serwera nas jest aktualny"
      echo " "
      else
      echo " "
      echo "system operacyjny serwera nas jest nieaktualny"
      echo " "
      fi
      read -n 1 -s -r key
    bash snmp_nas.sh ;;
                
    "koniec")
    echo "testy manualne zostały zakończone"
    bash snmp.sh ;;
                
    *)
    echo "wybrałeś nieprawidłową opcję" ;;
    esac
  done
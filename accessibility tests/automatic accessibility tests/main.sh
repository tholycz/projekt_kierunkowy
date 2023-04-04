#!/bin/bash
cd /home/tatiana/skrypty/snmpauto

#PL: weryfikacja istnienia pliku alert.txt i jeśli nie istnieje utworzenie
#EN: check for existence of alert.txt and if it does not exist create
if [ -f "alert.txt" ]; 
  then
    echo " "
  else
    touch alert.txt
  fi

# PL: weryfikowanie czy temperatura dysków jest mniejsza od 55 stopni
# EN: Check if the temperature of the disks is lower than 55 degrees
declare -i HDD1T=0
declare -i HDD2T=0
HDD1T=$(snmpget -v 2c -c public -O qv 10.20.31.2 1.3.6.1.4.1.6574.2.1.1.6.0)
HDD2T=$(snmpget -v 2c -c public -O qv 10.20.31.2 1.3.6.1.4.1.6574.2.1.1.6.1)
if [ $HDD1T -ge "55" ] ;
then
  echo "Temperatura dysku twardego 1 serwera NAS jest wyższa niż 55°C" >> alert.txt
fi
if [ "$HDD2T" -ge "55" ];
then
  echo "Temperatura dysku twardego 2 serwera NAS jest wyższa niż 55°C" >> alert.txt
fi

# PL: weryfikowanie systemu chłodzenia procesora działa poprawnie
# EN: check that cpu cooling system work properly
cpufan=$(snmpget -v 2c -c public -O qv 10.20.31.2  .1.3.6.1.4.1.6574.1.4.2.0)
if [ $cpufan != "1" ]; then
    echo "chłodzenie procesora serwera NAS działa niepoprawnie" >> alert.txt
  fi    

# PL: weryfikowanie systemu chłodzenia urządzenia działa poprawnie
# EN: check that device cooling system work properly
sysfan=$(snmpget -v 2c -c public -O qv 10.20.31.2  .1.3.6.1.4.1.6574.1.4.1.0)
if [ "$sysfan" != "1" ]; then
  echo "chłodzenie systemu serwera NAS działa niepoprawnie" >> alert.txt
  fi

# PL: weryfikowanie stanu dysku twardego 1 serwera NAS
# EN: check that disk 1 work properly
hdd1s=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.2.1.1.5.0)
if [ $hdd1s != "1" ]; then
  echo "stan dysku nr 1 serwera NAS wymaga pilnej uwagi" >> alert.txt
  fi

# PL: weryfikowanie stanu dysku twardego 2 serwera NAS
# EN: check that disk 2 work properly
hdd2s=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.2.1.1.5.1)
if [ $hdd2s != "1" ]; then
  echo "stan dysku nr 2 serwera NAS wymaga pilnej uwagi" >> alert.txt
  fi

# PL: weryfikacja aktualności systemu operacyjnego
# EN: check that system is up to date
sysupp=$(snmpget -v 2c -c public -O qv 10.20.31.2 .1.3.6.1.4.1.6574.1.5.4.0)
if [ $sysupp != "2" ] ; then
  echo "system serwera nas jest nieaktualny i wymaga  aktualizacji" >> alert.txt
  fi

# PL: weryfikacja stanu macierzy RAID w serwerze wirtualizacji
# EN: check that RAID in proxmox server is working properly
RAIDS=$(snmpget -v 2c -c public -O qv 10.20.30.4 .1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.4.1)
if [ $RAIDS -ne "2" ]; then
    echo "Macierz RAID nie działa poprawnie i należy ją naprawić" >> alert.txt
  fi

# PL: weryfikujemy czy raport alertów zawiera jakieś wpisy
# EN: check that alert file contains any data
if [ -s alert.txt ]; then
    
    #PL: zweryfikuj czy jest zainstalowana aplikacja do obsługi poczty
    #EN: check if the application too send a email is already installed in system
      if [ -x "$(command -v swaks)" ]; then
        
        # PL: wysłanie raportu do osoby monitorującej IT
        # EN: send alert to IT person 
        swaks --body ./alert.txt --to tetiana.wolender@gmail.com --from 	tetiana.holych@wp.pl --server smtp.wp.pl --port 587 --auth LOGIN --auth-user tetiana.holych@wp.pl --auth-password DTsFh3sF6amxCEGP --tls --header "Subject: !!! AWARIA w infrastrukturze IT !!!" >> log.txt
        else
          echo "w systemie nie zainstalowano aplikacji do obsługi poczty swaks, błędne elementy infrastruktury zostaną wyświetlone na ekranie"
          echo " "
          echo "$(cat alert.txt)"
        fi
    
  #PL: czyścimy plik z alertami
  #EN: clean the file alert.txt
  > alert.txt

  #PL: czyścimy i ustawiamy wartość poprawnych testów na 0 w pliku liczbatestow.txt
  #EN: set number of passed tests to 0 and write to file liczbatestow.txt
  declare -i liczbatestow=0
  > liczbatestow.txt
  echo $liczbatestow >> liczbatestow.txt  
  
else
  # PL: powiekszenie zmiennej liczby poprawnych testów o 1 i zapisanie jej do pliku liczbatestow.txt
  # EN: increase the number of passed tests by 1 and write it to the file liczby.txt
  declare -i liczbatestow
  liczbatestow=$( cat liczbatestow.txt )
  liczbatestow=${liczbatestow}+1
  > liczbatestow.txt
  echo $liczbatestow >> liczbatestow.txt
  if [ $liczbatestow -ge "10" ]; then
  
  # PL: wysyłamy informacje o 10 ostatnich poprawnych testach infrastruktury
  # EN: send 10 last passed tests like a info to IT person
  swaks --body "Gratulujemy twoja infrastruktura w całości działa poprawnie a system weryfikacji stale i poprawnie ją weryfikuje" --to tetiana.wolender@gmail.com --from tetiana.holych@wp.pl --server smtp.wp.pl --port 587 --auth LOGIN --auth-user tetiana.holych@wp.pl --auth-password DTsFh3sF6amxCEGP --tls --header "Subject: system monitoringu i całość infrastruktury działa OK" >> log.txt
  
  #PL: czyścimy i ustawiamy wartość poprawnych testów na 0 w pliku liczbatestow.txt
  #EN: set number of passed tests to 0 and write to file liczbatestow.txt
  declare -i liczbatestow=0
  > liczbatestow.txt
  echo $liczbatestow >> liczbatestow.txt  
  fi
fi

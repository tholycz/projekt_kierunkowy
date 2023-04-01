#!/bin/bash

# PL: przejdź do folderu aplikacji celem dostępu do plików roboczych
# EN: Go to the folder where the application is and execute the script 
cd /home/tatiana/skrypty

# PL: pobieramy wartości adresów IP z pliku infB.txt do zmiennej typu tablica o nazwie ipaddr
# EN: read the IP addresses from the file infB.txt into the variable type tabel
readarray -t ipaddr < infB.txt
date=$(date +"%Y-%m-%d %T")
echo "${date} wczytano tablicę adresów IP z pliku infB.txt do zmiennej ipaddr" >> log.txt

# PL: pobieramy wartości nazw urządzeń w sposób analogiczny odpowiadających ich adresom IP z pliku infB_names.txt do zmiennej typu tablica o nazwie names
# EN: read the names of the units from the file infB_names.txt into the variable type tabel named "names", in analogy to ip addreess 
readarray -t names < infB_names.txt
date=$(date +"%Y-%m-%d %T")
echo "${date} wczytano tablicę nazw urządzeń do zmiennej names" >> log.txt

# PL: weryfikujemy, czy dla każdej maszyny istnieje plik służący do raportowania błędów
# EN: check if there is a file for all units in array "names" named "rap_*" in the directory
for i in ${names[@]}; do
  if [ -f "rap_${i}.txt" ]; 
    then
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Plik raportu dla jednostki ${i} istnieje" >> log.txt
    else
      touch "rap_${i}.txt"
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Plik raportu dla jednostki ${i} nie istniał i został utworzony" >> log.txt
    fi
done

# PL: ustawienie zmiennej licznik na wartość zero celem analizy tablicy od jej pierwszego elementu
# EN: set the variable named "licznik" to zero for analyse table from first element
licznik=0
date=$(date +"%Y-%m-%d %T")
echo "${date} ustawiono wartość zmiennej licznik" >> log.txt

# PL: weryfikacja dostępności poszczególnych jednostek z listy adresów IP
# EN: checke the availability of all units in the array named "ipaddr"
for i in ${ipaddr[@]}; do
  echo "rozpoczynam analizę jednostki ${i}" >> log.txt
  if ping -c1 "$i" >> log.txt;
    then
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} o adresie ip ${i} jest dostępna" >> log.txt
      licznik=${licznik}+1
    else
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} jest niedostępna" >> "rap_${names[licznik]}.txt"
      echo "Jednostka ${names[licznik]} o adresie ip ${i} jest niedostępna" >> log.txt
      licznik=${licznik}+1
    fi
done

# PL: utworzenie zmiennej liczbatestow i wczytanie jej wartości z pliku liczba_testów.txt
# EN: create the variable named "liczba_testow" and read its value from the file liczba_testow.txt
declare -i liczbatestow
liczbatestow=$( cat liczbatestow.txt )
liczbatestow=${liczbatestow}+1
> liczbatestow.txt
echo $liczbatestow >> liczbatestow.txt

# PL: weryfikacja czy liczba odbytych testów automatycznych jest większa bądź równa liczbie 5
# EN: check if the number of tests is greater or equal to 5
if [ $liczbatestow -ge 5 ]; 
  then
    
    #PL: czyszczenie pliku files.txt z poprzednią listą plików raportów indywidualnych
    #EN: cleaning the contents of files.txt from the previous run
    > files.txt
    date=$(date +"%Y-%m-%d %T")
    echo "${date} wyczyszczono zawartość pliku files.txt" >> log.txt
    
    # PL: wczytujemy aktualną listę plików raportów indywidualnych i umieszczamy ją w pliku files.txt
    # EN: read the current list of idywidual raport files and put them in file files.txt
    find ./ -maxdepth 1 -type f -name "rap_*" -printf '%f\n' >> files.txt
    date=$(date +"%Y-%m-%d %T")
    echo "${date} wczytano listę plików raportów indywidualnych do pliku files.txt" >> log.txt

    # PL: wczytujemy stworzoną listę plików raportów indywidualnych i umieszczamy ją w zmiennej files
    # EN: read the created list of idywidual raport files and put them in files
    readarray -t files < files.txt
    date=$(date +"%Y-%m-%d %T")
    echo "${date} wczytano listę plików raportów indywidualnych do zmiennej files" >> log.txt

    # PL: analizujemy liczbę błędów w poszczególnych jednostkach w sieci przez zliczenie liczby raportów błędnie wykonanych testów ping
    # EN: analyze the number of errors, counting lines in each of the indyvidual raport
    declare -i err
    for plik in ${files[@]}; do
      err=$( wc -l < $plik )
      err=${err%% *}
      if [ $err -ge 5 ]; then
        jednostka="${plik%????}"
        jednostka="${jednostka#????}"
        echo "!!! ALARM !!! Jednostka ${jednostka} jest niedostępna" >> alert.txt
      fi
    done

    # PL: czyścimy folder z aktualnie przeanalizowanych plików raportów indywidualnych
    # EN: clean the folder with the files of actual analysed indyvidual raport files
    rm rap_*.txt

    #PL: ustawiamy wartość zmiennej liczbatestow na 0
    #EN: set the number of a variable named "liczbatestow" to 0
    liczbatestow=0

    # PL: zmieniamy zawartość pliku zawierającego liczbę przeprowadzonych testów na 0
    # EN: change the contents of the file files.txt to 0
    > liczbatestow.txt
    echo $liczbatestow >> liczbatestow.txt

    #PL: zweryfikuj czy jest zainstalowana aplikacja do obsługi poczty
    #EN: check if the application too send a email is already installed in system
    if [ -x "$(command -v swaks)" ]; 
      then
        # PL: wysyłamy zawartość pliku alert.txt do osoby monitorującej
        # EN: send the contents of the file alert.txt to the person who work in monitoring
        alert=`cat alert.txt`
        echo ${alert}
        swaks --body ./alert.txt --to tetiana.wolender@gmail.com --from 	tetiana.holych@wp.pl --server smtp.wp.pl --port 587 --auth LOGIN --auth-user tetiana.holych@wp.pl --auth-password DTsFh3sF6amxCEGP --tls --header "Subject: !!! AWARIA!!!" >> log.txt
      else
        echo "w systemie nie zainstalowano aplikacji do obsługi poczty swaks, błędne elementy infrastruktury zostaną wyświetlone na ekranie"
        echo " "
        if [ $(cat alert.txt) = "" ]; 
          then
          echo "cała sieć funkcjonuje poprawnie"
          else
          echo "$(cat alert.txt)"
        fi
        
        #PL: czyścimy plik z alertami
        #EN: clean the file alert.txt
        echo ${alert}
        > alert.txt
      fi         
    fi

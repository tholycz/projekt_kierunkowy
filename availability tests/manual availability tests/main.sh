#!/bin/bash

# PL: czyścimy plik z raportami z poprzednich informacji
# EN: clear the report file before start this script from previous results
> raport.txt

# PL: pobieramy wartości adresów IP z pliku infB.txt do zmiennej typu tablica o nazwie ipaddr
# EN: read the IP addresses from the file infB.txt into the variable type tabel
readarray -t ipaddr < infB.txt

# PL: pobieramy wartości nazw urządzeń w sposób analogiczny odpowiadających ich adresom IP z pliku infB_names.txt do zmiennej typu tablica o nazwie names
# EN: read the names of the units from the file infB_names.txt into the variable type tabel named "names", in analogy to ip addreess 
readarray -t names < infB_names.txt

# PL: ustawiamy zmienną licznik do wartości 0 czyli pierwszego elementu w tablicy names, aby móc generować raport zawierający poza adresem IP także informacje o nazwie urządzenia
# EN: set the variable "count" to zero, so that the first element of the array "names", because we will generate the report with the IP address and the unit name
licznik=0

# PL: Wykorzystujemy pętle for dla weryfikacji stanu każdego wcześniej zdefiniowanego adresu IP narzędziem ping
# EN: We use the for loop to calculate the status of all defined previous IP addresses ping tool
for i in ${ipaddr[@]}; do
  if ping -c1 "$i" >/dev/null 2>&1;
    then
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} o adresie IP ${i} jest dostępna" >> "raport.txt"
      licznik=${licznik}+1
    else
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} o adresie IP ${i} jest niedostępna" >> "raport.txt"
      licznik=${licznik}+1
    fi
done

# PL: prezentacja wyników testów przez wyświetlenie zawartości pliku "raport.txt"
# EN: print the results of the test from the "raport.txt" file
date=$(date +"%Y-%m-%d %T")
echo " "
echo "raport wykonanych testów z daty ${date}"
echo " "
cat raport.txt

#!/bin/bash
# czyścimy plik z raportami z poprzednich informacji
> raport.txt

# pobieramy wartości adresów IP z pliku infB.txt do zmiennej typu tablica o nazwie ipaddr
readarray -t ipaddr < infB.txt

# pobieramy wartości nazw urządzeń w sposób analogiczny odpowiadających ich adresom IP z pliku infB_names.txt do zmiennej typu tablica o nazwie names
readarray -t names < infB_names.txt

# weryfikujemy, czy dla każdej maszyny istnieje plik służący do raportowania błędów w jej raportowaniu
for i in ${names[@]}; do
  if [ -f "rap_"$i.txt ]; 
    then
      echo "Plik raportu dla maszyny $i istnieje"
    else
      touch "rap_"$i
      echo "Plik raportu dla maszyny $i został utworzony"
    fi
done

licznik=0
for i in ${ipaddr[@]}; do
  if ping -c1 "$i";
    then
      echo "Jednostka ${names[licznik]} jest dostępna"
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} jest dostępna" >> "raport.txt"
      licznik=${licznik}+1
    else
      echo "Jednostka ${names[licznik]} jest niedostępna"
      date=$(date +"%Y-%m-%d %T")
      echo "${date} Jednostka ${names[licznik]} jest niedostępna" >> "rap_${names[licznik]}.txt"
      echo "${date} Jednostka ${names[licznik]} jest niedostępna" >> "raport.txt"
      licznik=${licznik}+1
    fi
done

date=$(date +"%Y-%m-%d %T")
echo " "
echo "raport wykonanych testów z daty ${date}"
echo " "
cat raport.txt

# var=$(wc -l errors.txt)
# numberr=${var%% *}
# echo "Number of errors: ${numberr}"

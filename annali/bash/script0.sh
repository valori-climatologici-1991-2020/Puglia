#Alcuni file pdf trasformati in file di testo contengono errori che si traducono in un numero 
#eccessivo di colonne dati nel file di testo. Gli anni/annali problematici vanno letti uno a uno
#ed elaborati mediante lo script R "elaboraAnnaliPuglia_excel.R".

#Lo script elaboraAnnaliPuglia_excel.R genera ul file dati.csv-> questo file contiene errori e 
#vanno corretti a mano. Alcuni errori pero' possono essere corretti mediante sed e questo script
#ha proprio lo scopo di correggere gli errori che si trovano per lo pi nelle righe 30 e 31
#di ciascun mese.

#Quindi: si genera il file dati.csv mediante script R.
#Si rinomina dati.csv in dati_orig.csv 
#Si fa girare lo script script0.sh che dal file dati_orig.csv genera il file parzialmente corretto
#dati.csv.

#Utilizzando nuovamente lo script elaboraAnnaliPuglia_excel.R dal file dati.csv si genera un file
#excel. In questo file la prima colonna di ogni foglio indica: 0 (riga corretta), 
#1 (riga sbagliata)

#Attenzione: lo script elaboraAnnaliPuglia_excel.R cerca il file dati.csv e se lo trova lo cancella

#Quindi: si genera mediante script elaboraAnnaliPuglia_excel.R il file dati.csv
# lo si corregge mediante script0.sh
#Si fa rigirare nuovamente elaboraAnnaliPuglia_excel.R ponendo esegui<-FALSE in modo di evitare
#di cancellare il file dati.csv che serve per generare i file excel che servono per apportare
#manualmente le correzioni ai dati.


#!/bin/bash

sed -e 's/;;/;/g' \
-e 's/\(^30;[^N]\+\)\(NA;\)\{3,\}\([0-9].\+$\)/\1\3/g' \
-e 's/^\(30;-\?[0-9]\+\.[0-9];-\?[0-9]\+\.[0-9];\)\([0-9]\+\)/\1NA;NA;\2/g' \
-e 's/^\(31;-\?[0-9]\+\.[0-9];-\?[0-9]\+\.[0-9];\)\([0-9]\+\)/\1NA;NA;\2/g' \
-e 's/\([56789]\)\([0-9]\)/\1;\2/g' \
-e 's/\(\.[0-9]\)\([0-9]\)/\1;\2/g' dati_orig.csv >dati.csv

#Questo script viene fatto girare dal programma R che elabora gli annali in pdf.
#Il programma R legge i pdf e genera un file annale.txt che poi viene elaborato da questo script
#il cui scopo e' quello di generare un unico data.frame per tutte le tabelle con i dati
#di temperatura.

#Il file annale.txt viene elaborato e l'output e' un file dati.csv. Se il file pdf non contiene
#errori alla fine dell'esecuzione del programma R si ottiene un unico data-frame (uno per Tmax e
#uno per Tmin) in cui nella colonna stazione compare il nome della stazione

#Lo script inoltre genera un file di testo dove sono elencate in ordine le stazioni dell'Annale.
#

#!/bin/bash


ps2txt ${1} > annale.txt
grep  -A31 -B1 -E "^ *\\( *T(r|e) *\\) +Bacino" annale.txt |\
grep -E "^ *[1-9].?[0-9]? +" |\
sed -e 's/^ \+//g' |\
sed -e 's/ \{27,42\}/;NA;NA;NA;NA;NA;NA;/g' |\
sed -e 's/ \{17,\}/;NA;NA;/g' |\
sed -e 's/ \+/;/g' |\
sed -e 's/>>/NA/g' |\
sed -e 's/,\?,/./g' |\
sed -e 's/\.\././g' |\
sed -e 's/\.,/./g' > dati.csv
grep -B1 -E "^ *\\( *T(r|e) *\\) +Bacino" annale.txt | grep -v -E "^ *\\( *T(r|e) *\\) +Bacino" | grep -v -E "^-" > nomiStazioni.csv

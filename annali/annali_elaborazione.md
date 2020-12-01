# Elaborazione pdf Annali

Dal 1997 gli Annali della Puglia sono vere tabelle in formato pdf (non scannerizzazioni  degli Annali cartacei).

## Temperatura

La temperatura e' stata estratta prima convertendo i file pdf in formato testo (mediante ps2txt e l'uso di espressioni regolari) e poi rielaborando i testi mediante R.
Poiche' parte dei dati della temperatura erano gi disponibili in formato csv (dati inviati dalla regione Puglia su richiesta via fax), sono stati estratti dai pdf solo
gli anni non disponibili (ovvero gli anni dal 2013 al 2019 ma senza il 2014 che non e' statopossibile elaborare).

Alcune tabelle pdf hanno delle irregolarita' nella formattazione che ne rendono difficile l'importazione in modalita' automatica. Fortunatamente la maggior parte degli anni/pdf 
con le tabelle problematiche erano gi disponibili in formato csv (dati inviati dal Centro Funzionale). Degli anni non disponibili, solo il 2013 ha richiesto un intervento manuale per correggere gli errori 
di importazione (revisione del 2013 da parte di Francesca e Emanuala). **L'uso del pacchetto R `tabulizer` e uno script simile a quello implementato per la precipitazione avrebbe eliminato questi problemi? Sicuramente si**.

Il 2014 e' un pdf particolare: non si riesce a convertire in testo mediante ps2txt. **Provare a leggerlo mediante `tabulizer`**

## Precipitazione

Per la precipitazione la lettura delle tabelle e' avvenuta direttamente dai pdf mediante il pacchetto `tabulizer' senza passare per la conversione in file di testo (mediante ps2txt).
Il pacchetto `tabulizer` consente la lettura delle tabelle che pero' poi richiedono molte rielaborazioni per arrivare alle tabelle finali. Il vantaggio di `tabulizer`
e' che non risente della cattiva formattazione dei pdf (formattazione che crea a volte righe sflasate quando si convertono i pdf in testo mediante ps2txt).

Attenzione: `tabulizer` usa il pacchetto `rJava` quindi la Java Virtual Machine. A volte il codice per l'estrazione dei dati di precipitazione (`tabulizer.R + help.R`)
da degli errori che pero' svaniscono facendo rigirare il programma.

La strategia per utilizzare `tabulizer.R` e':
- fissare la pagina di inizio e di fine delle tabelle di precipitazione nel pdf
- far girare il programma sulla sequenza dei numeri di pagina
- se il programma si intterompe a pagina X, riavviare il programma facendolo ripartire da pagina X-2 (adesempio).



